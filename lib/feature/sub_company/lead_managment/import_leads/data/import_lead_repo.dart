import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/data/add_lead_repo.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/model/import_leads_model.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import '../../follow_up/models/follow_up_activities_model.dart';

abstract class IImportLeadsRepository {
  Future<List<LeadsModel>> fetchCategories();
  Future<List<LeadsModel>> fetchSources();
  Future<List<StaffModel>> fetchStaff();
  Future<List<LeadsModel>> fetchLeadStages();
  Future<List<LeadsModel>> fetchSubCategories(String categoryId);

  // ✅ CHANGED: return type is now Map<String, int> instead of int
  Future<Map<String, int>> importFromCsv({
    required Uint8List csvBytes,
    required Map<String, int> fieldPositions,
    required AddLeadModel defaults,
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
  final IAddLeadRepository _leadRepository;   // NEW

  ImportLeadsRepository({
    FirebaseFirestore? firestore,
    IAddLeadRepository? leadRepository,       // NEW
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _leadRepository = leadRepository ?? AddLeadRepository();

  CollectionReference<Map<String, dynamic>> get _leadsCollection =>
      FirestorePath.companyCollection('LEADS');

  CollectionReference<Map<String, dynamic>> get _categoryCollection =>
      FirestorePath.companyCollection('LEADS CATEGORY');

  CollectionReference<Map<String, dynamic>> get _sourceCollection =>
      FirestorePath.companyCollection('LEAD SOURCE');

  CollectionReference<Map<String, dynamic>> get _staffCollection =>
      FirestorePath.companyCollection('STAFF');

  CollectionReference<Map<String, dynamic>> get _leadStagesCollection =>
      FirestorePath.companyCollection('LEADS STAGE');

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
  Future<List<LeadsModel>> fetchSubCategories(String categoryId) async {
    try {
      final snap = await FirestorePath.companyCollection('LEADS CATEGORY')
          .doc(categoryId)
          .collection(
            'SUB CATEGORY',
          ) // ← match your actual SubCategoryRepository path
          .orderBy('createdAt', descending: false)
          .get();
      return snap.docs
          .map((d) => LeadsModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e, st) {
      log('[ImportLeadsRepo] fetchSubCategories error: $e', stackTrace: st);
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

    final existingSnap = await _leadsCollection.get(
      const GetOptions(source: Source.server),
    );

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
    required AddLeadModel defaults,
    required bool hasCountryCode,
  }) async {
     log('[Repo] importFromCsv received defaults.followUpDate=${defaults.followUpDate}, '
      'defaults.leadStage="${defaults.leadStage}"');
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
    final rowsToProcess = dataRows.length > maxRows
        ? dataRows.sublist(0, maxRows)
        : dataRows;

    log('[ImportLeadsRepo] CSV rows to process: ${rowsToProcess.length}');

    final existingSnap = await _leadsCollection.get(
      const GetOptions(source: Source.server),
    );

    final existingNumbers = existingSnap.docs
        .map((d) => (d.data()['contactNumber'] ?? '').toString().trim())
        .where((n) => n.isNotEmpty)
        .toSet();

    log('[ImportLeadsRepo] Existing leads count: ${existingNumbers.length}');

    int importedCount = 0;
    int skippedCount = 0;

    WriteBatch batch = _firestore.batch();
    int batchCount = 0;
    const int batchLimit = 450;

    Future<void> commitIfNeeded() async {
      if (batchCount >= batchLimit) {
        await batch.commit();
        batch = _firestore.batch();
        batchCount = 0;
      }
    }

    final createdByName = defaults.createdBy;
    final createdById = defaults.createdById;

    for (int i = 0; i < rowsToProcess.length; i++) {
      final rawRow = rowsToProcess[i];
      final row = rawRow.map((e) => e.toString()).toList();

      if (row.every((cell) => cell.trim().isEmpty)) continue;

      final lead = AddLeadModel.fromCsvRow(
        row: row,
        positions: fieldPositions,
        defaults: defaults,
      );
log('[Repo] row $i — lead.followUpDate=${lead.followUpDate}, '
    'lead.leadStage="${lead.leadStage}", lead.id="${lead.id}"');

      if (lead.clientName.isEmpty && lead.contactNumber.isEmpty) continue;

      if (lead.contactNumber.isNotEmpty &&
          existingNumbers.contains(lead.contactNumber.trim())) {
        log('[ImportLeadsRepo] Duplicate skipped: ${lead.contactNumber}');
        skippedCount++;
        continue;
      }

      final normalizedStage =
          lead.leadStage.toUpperCase().replaceAll(' ', '');
      // final isFollowUpStage = normalizedStage == 'FOLLOWUP';
final needsFollowUp = normalizedStage != 'NEW';

      log('[Repo] row $i — normalizedStage="$normalizedStage" needsFollowUp=$needsFollowUp');   // ← ADD

      final String docId = _generateDateId('LEAD', rowIndex: i);
      final docRef = _leadsCollection.doc(docId);

      batch.set(docRef, lead.toFirestore());
      batchCount++;
      importedCount++;

      if (needsFollowUp) {

          final resolvedFollowUpDate =
      lead.followUpDate ?? DateTime.now().add(const Duration(hours: 2));

        log('[Repo] row $i — building FollowUp for docId=$docId, '
      'followUpDate=${lead.followUpDate}'); 

        // addFollowUp() does `leadRef.update(...)` internally, which
        // requires the lead doc to already exist server-side. Commit
        // now so this row's lead is persisted before we touch it.
        if (batchCount > 0) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
        }

        final String followUpId = _generateDateId('FUP', rowIndex: i);
        final followUp = FollowUpModel(
          id: followUpId,
          leadId: docId,
          leadName: lead.clientName,
          leadWhatsappNo: lead.contactNumber,
          leadWhatsappDialCode: lead.contactDialCode,
          nextFollowUpDate: resolvedFollowUpDate,
          leadTag: '',
          calledStatus: 'Connected',
          calledDate: DateTime.now(),
          leadStage: lead.leadStage,
          leadCategory: lead.leadCategory,
          leadSubCategory: lead.leadSubCategory,
          priority: lead.priority,
          remarks: '',
          adress: lead.address,
          email: lead.email,
          assignedStaff: lead.assignedStaff,
          assignedStaffId: lead.assignedStaffId,
          createdById: lead.createdById,
          createdAt: DateTime.now(),
          leadCategoryId: lead.leadCategoryId,
          leadSubCategoryId: lead.leadSubCategoryId,
          leadStageId: lead.leadStageId,
          leadTagId: lead.leadTagId,
        );


          log('[Repo] row $i — followUp built: id=${followUp.id}, '
      'nextFollowUpDate=${followUp.nextFollowUpDate}, '
      'calledDate=${followUp.calledDate}');

        // Reuse the exact same method the manual Add Lead flow uses —
        // writes FOLLOW_UPS, updates the lead doc (leadStage,
        // nextFollowUpDate, hasFollowUp, etc.), and logs the
        // followupAdded ACTIVITIES entry, all in one call.
        await _leadRepository.addFollowUp(
          docId,
          followUp,
          changedByName: createdByName,
          changedById: createdById,
          leadName: lead.clientName,
          leadPhone: lead.contactNumber,
        );
      }

      // Same lead-created activity logger the manual Add Lead flow uses.
      // Safe regardless of batch-commit timing — it only ever .set()s a
      // new ACTIVITIES subdoc, which doesn't require the parent to exist.
      await _leadRepository.logLeadCreated(
        leadId: docId,
        createdByName: createdByName,
        createdById: createdById,
        assignedTo: lead.assignedStaff,
        leadStage: lead.leadStage,
        priority: lead.priority,
        leadCategory: lead.leadCategory,
      );

      await commitIfNeeded();
    }

    if (batchCount > 0) await batch.commit();

    log('[ImportLeadsRepo] Imported: $importedCount, Skipped: $skippedCount');

    return {'imported': importedCount, 'skipped': skippedCount};
  }
}


