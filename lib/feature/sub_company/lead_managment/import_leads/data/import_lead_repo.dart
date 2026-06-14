import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/feature/sub_company/lead_managment/import_leads/model/import_leads_model.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/common_model/lead_model.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/staff_model.dart';

abstract class IImportLeadsRepository {
  Future<List<LeadsModel>> fetchCategories();
  Future<List<LeadsModel>> fetchSources();
  Future<List<StaffModel>> fetchStaff();
  Future<List<LeadsModel>> fetchLeadStages();

  // ✅ CHANGED: return type is now Map<String, int> instead of int
  Future<Map<String, int>> importFromCsv({
    required Uint8List csvBytes,
    required Map<String, int> fieldPositions,
    required ImportLeadModel defaults,
    required bool hasCountryCode,
  });

  // ✅ NEW: pre-check duplicates without importing
  Future<int> countDuplicates({
    required Uint8List csvBytes,
    required Map<String, int> fieldPositions,
  });
}

class ImportLeadsRepository implements IImportLeadsRepository {
  final FirebaseFirestore _firestore;

  ImportLeadsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _leadsCollection =>
      _firestore.collection('LEADS');

  CollectionReference<Map<String, dynamic>> get _categoryCollection =>
      _firestore.collection('LEADS CATEGORY');

  CollectionReference<Map<String, dynamic>> get _sourceCollection =>
      _firestore.collection('LEAD SOURCE');

  CollectionReference<Map<String, dynamic>> get _staffCollection =>
      _firestore.collection('STAFF');

  CollectionReference<Map<String, dynamic>> get _leadStagesCollection =>
      _firestore.collection('LEADS STAGE');

  String _generateDateId(String prefix, {int? rowIndex}) {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final String id = now.millisecondsSinceEpoch.toString();
    final suffix = rowIndex != null ? '-$rowIndex' : ''; // ✅ FIXED
    return '$prefix-$datePart-$id$suffix';
  }

  @override
  Future<List<LeadsModel>> fetchCategories() async {
    try {
      final snap = await _categoryCollection
          .orderBy('createdAt', descending: false)
          .get();
      return snap.docs
          .map((d) => LeadsModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e, st) {
      log('[ImportLeadsRepo] fetchCategories error: $e', stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<LeadsModel>> fetchSources() async {
    try {
      final snap = await _sourceCollection
          .orderBy('createdAt', descending: false)
          .get();
      return snap.docs
          .map((d) => LeadsModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e, st) {
      log('[ImportLeadsRepo] fetchSources error: $e', stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<LeadsModel>> fetchLeadStages() async {
    try {
      final snap = await _leadStagesCollection
          .orderBy('createdAt', descending: false)
          .get();
      return snap.docs
          .map((d) => LeadsModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e, st) {
      log('[ImportLeadsRepo] fetchLeadStages error: $e', stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<StaffModel>> fetchStaff() async {
    try {
      final snap = await _staffCollection.orderBy('name').get();
      return snap.docs.map((d) => StaffModel.fromFirestore(d)).toList();
    } catch (e, st) {
      log('[ImportLeadsRepo] fetchStaff error: $e', stackTrace: st);
      rethrow;
    }
  }

  // ✅ NEW METHOD: only counts duplicates, does NOT write anything
  @override
  Future<int> countDuplicates({
    required Uint8List csvBytes,
    required Map<String, int> fieldPositions,
  }) async {
    String rawContent = utf8.decode(csvBytes, allowMalformed: true);
    if (rawContent.startsWith('\uFEFF')) rawContent = rawContent.substring(1);

    final csvTable = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(rawContent);

    if (csvTable.length <= 1) return 0;

    final dataRows = csvTable.skip(1).toList();

    final existingSnap = await _leadsCollection
        .get(const GetOptions(source: Source.server));

    final existingNumbers = existingSnap.docs
        .map((d) => (d.data()['contactNumber'] ?? '').toString().trim())
        .where((n) => n.isNotEmpty)
        .toSet();

    int duplicateCount = 0;
    for (final rawRow in dataRows) {
      final row = rawRow.map((e) => e.toString()).toList();
      final phoneIdx = fieldPositions['phone'];
      if (phoneIdx == null || phoneIdx >= row.length) continue;
      final phone = row[phoneIdx].trim();
      if (phone.isNotEmpty && existingNumbers.contains(phone)) {
        duplicateCount++;
      }
    }
    return duplicateCount;
  }

  // ✅ CHANGED: now returns Map<String, int> with 'imported' and 'skipped'
  @override
  Future<Map<String, int>> importFromCsv({
    required Uint8List csvBytes,
    required Map<String, int> fieldPositions,
    required ImportLeadModel defaults,
    required bool hasCountryCode,
  }) async {
    String rawContent = utf8.decode(csvBytes, allowMalformed: true);
    if (rawContent.startsWith('\uFEFF')) {
      rawContent = rawContent.substring(1);
    }

    final List<List<dynamic>> csvTable = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(rawContent);

    if (csvTable.isEmpty) throw Exception('CSV file is empty.');

    final dataRows = csvTable.skip(1).toList();
    if (dataRows.isEmpty) throw Exception('CSV file contains no data rows.');

    const int maxRows = 1000;
    final rowsToProcess =
        dataRows.length > maxRows ? dataRows.sublist(0, maxRows) : dataRows;

    log('[ImportLeadsRepo] CSV rows to process: ${rowsToProcess.length}');

    final existingSnap = await _leadsCollection
        .get(const GetOptions(source: Source.server));

    final existingNumbers = existingSnap.docs
        .map((d) => (d.data()['contactNumber'] ?? '').toString().trim())
        .where((n) => n.isNotEmpty)
        .toSet();

    log('[ImportLeadsRepo] Existing leads count: ${existingNumbers.length}');

    int importedCount = 0;
    int skippedCount = 0;
    WriteBatch batch = _firestore.batch();
    int batchCount = 0;
    const int batchLimit = 500;

    for (int i = 0; i < rowsToProcess.length; i++) {
      final rawRow = rowsToProcess[i];
      final row = rawRow.map((e) => e.toString()).toList();

      if (row.every((cell) => cell.trim().isEmpty)) continue;

      final lead = ImportLeadModel.fromCsvRow(
        row: row,
        positions: fieldPositions,
        defaults: defaults,
      );

      if (lead.clientName.isEmpty && lead.contactNumber.isEmpty) continue;

      if (lead.contactNumber.isNotEmpty &&
          existingNumbers.contains(lead.contactNumber.trim())) {
        log('[ImportLeadsRepo] Duplicate skipped: ${lead.contactNumber}');
        skippedCount++;
        continue;
      }

      final String docId = _generateDateId('LEAD', rowIndex: i);
      final docRef = _leadsCollection.doc(docId);

      batch.set(docRef, lead.toFirestore());
      batchCount++;
      importedCount++;

      if (batchCount == batchLimit) {
        await batch.commit();
        batch = _firestore.batch();
        batchCount = 0;
      }
    }

    if (batchCount > 0) await batch.commit();

    log('[ImportLeadsRepo] Imported: $importedCount, Skipped: $skippedCount');

    // ✅ CHANGED: return both counts
    return {'imported': importedCount, 'skipped': skippedCount};
  }
}