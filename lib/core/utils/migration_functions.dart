

import 'dart:developer';

import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ── ONE-TIME MIGRATION ───────────────────────────────────────────────────


/// ── ONE-TIME MIGRATION ───────────────────────────────────────────────────
/// Backfills leadCategoryId / leadSubCategoryId / leadStageId on existing
/// TRANSFER_LEADS subcollection docs that were written before these ID
/// fields existed on TransferDetails. Resolves the old raw name strings
/// (leadCategory / leadSubCategory / leadStage) against the current
/// LEADS CATEGORY, SUB CATEGORY, and LEADS STAGE collections.
///
/// Safe to re-run: any doc that already has a non-empty leadCategoryId
/// is skipped entirely (no re-write, no re-lookup).
///
/// Run this once, manually, from a debug button or a one-off script —
/// not on every app start.
Future<void> migrateTransferLeadsCategoryIds() async {
  final db = FirebaseFirestore.instance;

  // ── 1. Preload category name → id map (case-insensitive) ────────────────
  final categorySnap =
      await FirestorePath.companyCollection('LEADS CATEGORY').get();
  final Map<String, String> categoryNameToId = {
    for (final doc in categorySnap.docs)
      (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
  };

  // ── 2. Preload stage name → id map (case-insensitive) ───────────────────
  final stageSnap =
      await FirestorePath.companyCollection('LEADS STAGE').get();
  final Map<String, String> stageNameToId = {
    for (final doc in stageSnap.docs)
      (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
  };

  // ── 3. Sub-category lookups are scoped per-category — cache lazily ──────
  // categoryId -> { subCategoryNameUpper -> subCategoryId }
  final Map<String, Map<String, String>> subCategoryCachePerCategory = {};

  Future<Map<String, String>> getSubCategoryMap(String categoryId) async {
    if (subCategoryCachePerCategory.containsKey(categoryId)) {
      return subCategoryCachePerCategory[categoryId]!;
    }
    final subSnap = await FirestorePath.companyCollection('LEADS CATEGORY')
        .doc(categoryId)
        .collection('SUB CATEGORY')
        .get();
    final map = {
      for (final doc in subSnap.docs)
        (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
    };
    subCategoryCachePerCategory[categoryId] = map;
    return map;
  }

  // ── 4. Walk every Lead's TRANSFER_LEADS subcollection ────────────────────
  final leadsSnap = await FirestorePath.companyCollection('LEADS').get();

  int scanned = 0;
  int updated = 0;
  int skippedAlreadyDone = 0;
  int unresolvedCategory = 0;
  int unresolvedStage = 0;

  final List<DocumentReference<Map<String, dynamic>>> pendingRefs = [];
  final List<Map<String, dynamic>> pendingUpdates = [];

  for (final leadDoc in leadsSnap.docs) {
    final transferSnap = await leadDoc.reference
        .collection('TRANSFER_LEADS')
        .get();

    for (final transferDoc in transferSnap.docs) {
      scanned++;
      final data = transferDoc.data();

      // Skip if already backfilled.
      final existingCategoryId = (data['leadCategoryId'] as String? ?? '');
      if (existingCategoryId.isNotEmpty) {
        skippedAlreadyDone++;
        continue;
      }

      final rawCategory =
          (data['leadCategory'] as String? ?? '').trim().toUpperCase();
      final rawSubCategory =
          (data['leadSubCategory'] as String? ?? '').trim().toUpperCase();
      final rawStage =
          (data['leadStage'] as String? ?? '').trim().toUpperCase();

      final resolvedCategoryId = categoryNameToId[rawCategory] ?? '';
      final resolvedStageId = stageNameToId[rawStage] ?? '';

      String resolvedSubCategoryId = '';
      if (resolvedCategoryId.isNotEmpty && rawSubCategory.isNotEmpty) {
        final subMap = await getSubCategoryMap(resolvedCategoryId);
        resolvedSubCategoryId = subMap[rawSubCategory] ?? '';
      }

      if (rawCategory.isNotEmpty && resolvedCategoryId.isEmpty) {
        unresolvedCategory++;
        log('[migrateTransferLeadsCategoryIds] Could not resolve category '
            '"$rawCategory" for transfer doc ${transferDoc.id} '
            '(lead ${leadDoc.id}) — likely renamed/deleted since. Leaving blank.');
      }
      if (rawStage.isNotEmpty && resolvedStageId.isEmpty) {
        unresolvedStage++;
        log('[migrateTransferLeadsCategoryIds] Could not resolve stage '
            '"$rawStage" for transfer doc ${transferDoc.id} '
            '(lead ${leadDoc.id}) — likely renamed/deleted since. Leaving blank.');
      }

      // Only write if we resolved at least one ID — no point writing all-blank.
      if (resolvedCategoryId.isEmpty &&
          resolvedSubCategoryId.isEmpty &&
          resolvedStageId.isEmpty) {
        continue;
      }

      pendingRefs.add(transferDoc.reference);
      pendingUpdates.add({
        if (resolvedCategoryId.isNotEmpty) 'leadCategoryId': resolvedCategoryId,
        if (resolvedSubCategoryId.isNotEmpty)
          'leadSubCategoryId': resolvedSubCategoryId,
        if (resolvedStageId.isNotEmpty) 'leadStageId': resolvedStageId,
      });
    }
  }

  // ── 5. Batch-write in chunks of 450 ──────────────────────────────────────
  const chunkSize = 450;
  for (var i = 0; i < pendingRefs.length; i += chunkSize) {
    final end =
        (i + chunkSize > pendingRefs.length) ? pendingRefs.length : i + chunkSize;
    final batch = db.batch();
    for (var j = i; j < end; j++) {
      batch.update(pendingRefs[j], pendingUpdates[j]);
    }
    await batch.commit();
    updated += (end - i);
    log('[migrateTransferLeadsCategoryIds] Committed batch '
        '${(i ~/ chunkSize) + 1} (${end - i} docs)');
  }

  log('[migrateTransferLeadsCategoryIds] DONE — '
      'scanned:$scanned updated:$updated '
      'skippedAlreadyDone:$skippedAlreadyDone '
      'unresolvedCategory:$unresolvedCategory unresolvedStage:$unresolvedStage');
}

/// Read-only diagnostic — lists every TRANSFER_LEADS doc that still has
/// no leadCategoryId, along with the lead it belongs to and the raw
/// category name string, so you can decide how to resolve each one.
Future<void> listUnresolvedTransferCategories() async {
  final leadsSnap = await FirestorePath.companyCollection('LEADS').get();

  for (final leadDoc in leadsSnap.docs) {
    final transferSnap =
        await leadDoc.reference.collection('TRANSFER_LEADS').get();

    for (final t in transferSnap.docs) {
      final data = t.data();
      final categoryId = data['leadCategoryId'] as String? ?? '';
      if (categoryId.isEmpty) {
        log('[unresolved] lead=${leadDoc.id} '
            'leadName=${data['leadName']} '
            'transferDoc=${t.id} '
            'rawCategory="${data['leadCategory']}" '
            'rawSubCategory="${data['leadSubCategory']}" '
            'transferTime=${data['transferTime']}');
      }
    }
  }
}



/// Backfills leadCategoryId / leadSubCategoryId / leadStageId inside each
/// map entry of the `transferLeads` array field on LEADS documents.
///
/// Firestore cannot patch a single field inside one array element — the
/// only way to change anything inside an array is to read the whole array,
/// rebuild every entry in memory, and overwrite the entire field. This does
/// exactly that, using the same name→id resolution maps as the
/// TRANSFER_LEADS subcollection migration, so results stay consistent
/// between the two copies of this data.
///
/// Safe to re-run: any array entry that already has a non-empty
/// leadCategoryId is left untouched (still rebuilt into the new array,
/// but with its existing values preserved, not overwritten).
Future<void> migrateLeadTransferArrayCategoryIds() async {
  final db = FirebaseFirestore.instance;

  // ── 1. Preload category name → id map (case-insensitive) ────────────────
  final categorySnap =
      await FirestorePath.companyCollection('LEADS CATEGORY').get();
  final Map<String, String> categoryNameToId = {
    for (final doc in categorySnap.docs)
      (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
  };

  // ── 2. Preload stage name → id map (case-insensitive) ───────────────────
  final stageSnap =
      await FirestorePath.companyCollection('LEADS STAGE').get();
  final Map<String, String> stageNameToId = {
    for (final doc in stageSnap.docs)
      (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
  };

  // ── 3. Sub-category lookups are scoped per-category — cache lazily ──────
  final Map<String, Map<String, String>> subCategoryCachePerCategory = {};

  Future<Map<String, String>> getSubCategoryMap(String categoryId) async {
    if (subCategoryCachePerCategory.containsKey(categoryId)) {
      return subCategoryCachePerCategory[categoryId]!;
    }
    final subSnap = await FirestorePath.companyCollection('LEADS CATEGORY')
        .doc(categoryId)
        .collection('SUB CATEGORY')
        .get();
    final map = {
      for (final doc in subSnap.docs)
        (doc.data()['name'] as String? ?? '').trim().toUpperCase(): doc.id,
    };
    subCategoryCachePerCategory[categoryId] = map;
    return map;
  }

  // ── 4. Walk every Lead doc that actually has a transferLeads array ──────
  final leadsSnap = await FirestorePath.companyCollection('LEADS').get();

  int scannedLeads = 0;
  int scannedEntries = 0;
  int updatedLeads = 0;
  int alreadyDoneEntries = 0;
  int unresolvedCategory = 0;
  int unresolvedStage = 0;

  final List<DocumentReference<Map<String, dynamic>>> pendingRefs = [];
  final List<List<Map<String, dynamic>>> pendingArrays = [];

  for (final leadDoc in leadsSnap.docs) {
    final data = leadDoc.data();
    final rawList = data['transferLeads'];
    if (rawList == null || rawList is! List || rawList.isEmpty) continue;

    scannedLeads++;
    bool anyChanged = false;

    final rebuiltArray = <Map<String, dynamic>>[];

    for (final item in rawList) {
      scannedEntries++;
      if (item is! Map<String, dynamic>) {
        // Shouldn't happen, but don't drop unknown shapes — keep as-is.
        rebuiltArray.add(Map<String, dynamic>.from(item as Map));
        continue;
      }

      final entry = Map<String, dynamic>.from(item);

      final existingCategoryId = (entry['leadCategoryId'] as String? ?? '');
      if (existingCategoryId.isNotEmpty) {
        alreadyDoneEntries++;
        rebuiltArray.add(entry); // preserve as-is
        continue;
      }

      final rawCategory =
          (entry['leadCategory'] as String? ?? '').trim().toUpperCase();
      final rawSubCategory =
          (entry['leadSubCategory'] as String? ?? '').trim().toUpperCase();
      final rawStage =
          (entry['leadStage'] as String? ?? '').trim().toUpperCase();

      final resolvedCategoryId = categoryNameToId[rawCategory] ?? '';
      final resolvedStageId = stageNameToId[rawStage] ?? '';

      String resolvedSubCategoryId = '';
      if (resolvedCategoryId.isNotEmpty && rawSubCategory.isNotEmpty) {
        final subMap = await getSubCategoryMap(resolvedCategoryId);
        resolvedSubCategoryId = subMap[rawSubCategory] ?? '';
      }

      if (rawCategory.isNotEmpty && resolvedCategoryId.isEmpty) {
        unresolvedCategory++;
        log('[migrateLeadTransferArrayCategoryIds] lead=${leadDoc.id} '
            'Could not resolve category "$rawCategory" in array entry — leaving blank.');
      }
      if (rawStage.isNotEmpty && resolvedStageId.isEmpty) {
        unresolvedStage++;
        log('[migrateLeadTransferArrayCategoryIds] lead=${leadDoc.id} '
            'Could not resolve stage "$rawStage" in array entry — leaving blank.');
      }

      if (resolvedCategoryId.isNotEmpty) {
        entry['leadCategoryId'] = resolvedCategoryId;
        anyChanged = true;
      }
      if (resolvedSubCategoryId.isNotEmpty) {
        entry['leadSubCategoryId'] = resolvedSubCategoryId;
        anyChanged = true;
      }
      if (resolvedStageId.isNotEmpty) {
        entry['leadStageId'] = resolvedStageId;
        anyChanged = true;
      }

      rebuiltArray.add(entry);
    }

    if (anyChanged) {
      pendingRefs.add(leadDoc.reference);
      pendingArrays.add(rebuiltArray);
    }
  }

  // ── 5. Overwrite the whole array field, chunked at 450 per batch ────────
  const chunkSize = 450;
  for (var i = 0; i < pendingRefs.length; i += chunkSize) {
    final end =
        (i + chunkSize > pendingRefs.length) ? pendingRefs.length : i + chunkSize;
    final batch = db.batch();
    for (var j = i; j < end; j++) {
      // Full field overwrite — NOT arrayUnion. arrayUnion only adds new
      // elements and cannot replace existing ones, so it can't be used here.
      batch.update(pendingRefs[j], {'transferLeads': pendingArrays[j]});
    }
    await batch.commit();
    updatedLeads += (end - i);
    log('[migrateLeadTransferArrayCategoryIds] Committed batch '
        '${(i ~/ chunkSize) + 1} (${end - i} lead docs)');
  }

  log('[migrateLeadTransferArrayCategoryIds] DONE — '
      'scannedLeads:$scannedLeads scannedEntries:$scannedEntries '
      'updatedLeads:$updatedLeads alreadyDoneEntries:$alreadyDoneEntries '
      'unresolvedCategory:$unresolvedCategory unresolvedStage:$unresolvedStage');
}

/// Manually resolves one specific old raw category name to a specific
/// current category ID — fixing BOTH copies of the data at once:
///   1. TRANSFER_LEADS subcollection docs (leadCategory == oldRawCategoryName)
///   2. The transferLeads array field on the parent LEADS document
///
/// Use this only after confirming by eye (via listUnresolvedTransferCategories
/// or the Firebase console) which current category the old name should map to.
///
/// Safe to re-run: docs/entries that already carry correctCategoryId are
/// simply overwritten with the same value again — no harm, no duplication.
Future<void> manuallyResolveTransferCategoryEverywhere({
  required String oldRawCategoryName,   // exactly as stored, e.g. "MAY VIST"
  required String correctCategoryId,    // real LEADS CATEGORY doc id
  required String correctCategoryName,  // its current display name
}) async {
  final db = FirebaseFirestore.instance;
  final leadsSnap = await FirestorePath.companyCollection('LEADS').get();

  final List<DocumentReference<Map<String, dynamic>>> subDocRefs = [];
  final List<DocumentReference<Map<String, dynamic>>> leadRefsToRewriteArray = [];
  final List<List<Map<String, dynamic>>> rebuiltArrays = [];

  int matchedSubDocs = 0;
  int matchedArrayEntries = 0;

  for (final leadDoc in leadsSnap.docs) {
    // ── 1. TRANSFER_LEADS subcollection ──────────────────────────────────
    final transferSnap = await leadDoc.reference
        .collection('TRANSFER_LEADS')
        .where('leadCategory', isEqualTo: oldRawCategoryName)
        .get();
    if (transferSnap.docs.isNotEmpty) {
      subDocRefs.addAll(transferSnap.docs.map((d) => d.reference));
      matchedSubDocs += transferSnap.docs.length;
    }

    // ── 2. transferLeads array on the Lead doc ───────────────────────────
    final data = leadDoc.data();
    final rawList = data['transferLeads'];
    if (rawList is List && rawList.isNotEmpty) {
      bool changed = false;
      final rebuilt = <Map<String, dynamic>>[];

      for (final item in rawList) {
        if (item is! Map<String, dynamic>) {
          rebuilt.add(Map<String, dynamic>.from(item as Map));
          continue;
        }
        final entry = Map<String, dynamic>.from(item);
        if ((entry['leadCategory'] as String? ?? '') == oldRawCategoryName) {
          entry['leadCategoryId'] = correctCategoryId;
          entry['leadCategory'] = correctCategoryName;
          changed = true;
          matchedArrayEntries++;
        }
        rebuilt.add(entry);
      }

      if (changed) {
        leadRefsToRewriteArray.add(leadDoc.reference);
        rebuiltArrays.add(rebuilt);
      }
    }
  }

  // ── Batch-write both sets, chunked at 450 ────────────────────────────────
  const chunkSize = 450;

  for (var i = 0; i < subDocRefs.length; i += chunkSize) {
    final end = (i + chunkSize > subDocRefs.length) ? subDocRefs.length : i + chunkSize;
    final batch = db.batch();
    for (var j = i; j < end; j++) {
      batch.update(subDocRefs[j], {
        'leadCategoryId': correctCategoryId,
        'leadCategory': correctCategoryName,
      });
    }
    await batch.commit();
  }

  for (var i = 0; i < leadRefsToRewriteArray.length; i += chunkSize) {
    final end = (i + chunkSize > leadRefsToRewriteArray.length)
        ? leadRefsToRewriteArray.length
        : i + chunkSize;
    final batch = db.batch();
    for (var j = i; j < end; j++) {
      batch.update(leadRefsToRewriteArray[j], {'transferLeads': rebuiltArrays[j]});
    }
    await batch.commit();
  }

  log('[manuallyResolveTransferCategoryEverywhere] "$oldRawCategoryName" → '
      '$correctCategoryId ("$correctCategoryName") — '
      'subDocsUpdated:$matchedSubDocs arrayEntriesUpdated:$matchedArrayEntries');
}

/// ── ONE-TIME MIGRATION ───────────────────────────────────────────────────
/// Backfills the `isDeleted` field on every existing LEADS document that
/// doesn't already have it. Required because AddLeadModel.fromFirestore
/// already defaults missing `isDeleted` to `false` in memory — but the
/// actual Firestore documents still lack the field, which matters for:
///   • fetchDeletedLeads() — queries `where('isDeleted', isEqualTo: true)`,
///     which Firestore can only match against documents that HAVE the field.
///   • Any other direct Firestore query filtering on `isDeleted`.
///
/// Safe to re-run: any document that already has `isDeleted` is skipped
/// entirely, so running this multiple times causes no harm and does not
/// overwrite leads that have already been soft-deleted.
Future<void> migrateIsDeletedField() async {
  final db = FirebaseFirestore.instance;
  final leadsSnap =
      await FirestorePath.companyCollection('LEADS').get();

  int updated = 0;
  int skipped = 0;

  const chunkSize = 450;
  final List<DocumentReference<Map<String, dynamic>>> pendingRefs = [];

  for (final leadDoc in leadsSnap.docs) {
    final data = leadDoc.data();

    // Skip if the field already exists — whether true or false.
    if (data.containsKey('isDeleted')) {
      skipped++;
      continue;
    }

    pendingRefs.add(leadDoc.reference);
  }

  // ── Batch-write in chunks of 450 to stay under Firestore's 500 limit ────
  for (var i = 0; i < pendingRefs.length; i += chunkSize) {
    final end =
        (i + chunkSize > pendingRefs.length) ? pendingRefs.length : i + chunkSize;
    final batch = db.batch();
    for (var j = i; j < end; j++) {
      batch.update(pendingRefs[j], {
        'isDeleted': false,
        // Only set deletedAt if it doesn't already exist; leaving it
        // untouched here since `update()` won't overwrite fields not
        // included in the map — no risk of clobbering an existing value.
      });
    }
    await batch.commit();
    updated += (end - i);
    print(
      '[migrateIsDeletedField] Committed batch ${(i ~/ chunkSize) + 1} '
      '(${end - i} lead docs)',
    );
  }

  print(
    '[migrateIsDeletedField] Migration complete. '
    'Updated: $updated, Skipped (already had field): $skipped',
  );
}