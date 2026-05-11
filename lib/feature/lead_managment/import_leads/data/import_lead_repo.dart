import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:oxdo/feature/lead_managment/import_leads/model/import_leads_model.dart';
import 'package:oxdo/feature/rightside_menu/common_model/lead_model.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';

// ── Abstract contract ─────────────────────────────────────────────────────────

abstract class IImportLeadsRepository {
  /// Fetch all lead categories from Firestore.
  Future<List<LeadsModel>> fetchCategories();

  /// Fetch all lead sources from Firestore.
  Future<List<LeadsModel>> fetchSources();

  /// Fetch all active staff members from Firestore.
  Future<List<StaffModel>> fetchStaff();

  Future<List<LeadsModel>> fetchLeadStages();

  /// Parse [csvBytes] and write each valid row to the LEADS collection.
  /// Returns the number of records successfully imported.
  Future<int> importFromCsv({
    required Uint8List csvBytes,
    required Map<String, int> fieldPositions,
    required ImportLeadModel defaults,
    required bool hasCountryCode,
  });
}

// ── Concrete implementation ───────────────────────────────────────────────────

class ImportLeadsRepository implements IImportLeadsRepository {
  final FirebaseFirestore _firestore;

  ImportLeadsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Collection refs ───────────────────────────────────────────────────────

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

  // ── Fetch helpers ─────────────────────────────────────────────────────────

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
      log('fetchLeadStages');
      final snap = await _leadStagesCollection
          .orderBy('createdAt', descending: false)
          .get();
          log("lead stages ${snap.docs.length}");
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

  // ── CSV import ────────────────────────────────────────────────────────────

  @override
  Future<int> importFromCsv({
    required Uint8List csvBytes,
    required Map<String, int> fieldPositions,
    required ImportLeadModel defaults,
    required bool hasCountryCode,
  }) async {
    // ── 1. Read & parse CSV ─────────────────────────────────────────────────
    // ✅ FIX: handle BOM (byte-order mark) that some CSV exports prepend
    String rawContent = utf8.decode(csvBytes, allowMalformed: true);
    if (rawContent.startsWith('\uFEFF')) {
      rawContent = rawContent.substring(1);
    }

    final List<List<dynamic>> csvTable = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(rawContent);

    if (csvTable.isEmpty) {
      throw Exception('CSV file is empty.');
    }

    // Skip header row (row 0)
    final dataRows = csvTable.skip(1).toList();

    if (dataRows.isEmpty) {
      throw Exception('CSV file contains no data rows.');
    }

    // Enforce 1000-row limit
    const int maxRows = 1000;
    final rowsToProcess = dataRows.length > maxRows
        ? dataRows.sublist(0, maxRows)
        : dataRows;

    log('[ImportLeadsRepo] CSV rows to process: ${rowsToProcess.length}');

    // ── 2. Batch write to Firestore (500 per batch — Firestore limit) ───────
    int importedCount = 0;
    WriteBatch batch = _firestore.batch();
    int batchCount = 0;
    const int batchLimit = 500;

    for (final rawRow in rowsToProcess) {
      final row = rawRow.map((e) => e.toString()).toList();

      // Skip completely empty rows
      if (row.every((cell) => cell.trim().isEmpty)) continue;

      final lead = ImportLeadModel.fromCsvRow(
        row: row,
        positions: fieldPositions,
        defaults: defaults,
      );

      // Skip rows with no client name and no phone
      if (lead.clientName.isEmpty && lead.contactNumber.isEmpty) {
        log('[ImportLeadsRepo] Skipping row with no name/phone: $row');
        continue;
      }

      final docRef = _leadsCollection.doc();
      batch.set(docRef, lead.toFirestore());
      batchCount++;
      importedCount++;

      // Commit when reaching batch limit and start a new batch
      if (batchCount == batchLimit) {
        await batch.commit();
        log('[ImportLeadsRepo] Batch committed: $importedCount records so far');
        batch = _firestore.batch();
        batchCount = 0;
      }
    }

    // Commit remaining records
    if (batchCount > 0) {
      await batch.commit();
      log('[ImportLeadsRepo] Final batch committed: $importedCount total');
    }

    return importedCount;
  }
}
