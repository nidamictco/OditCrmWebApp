import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class LeadsMigrationHelper {
  static Future<void> migrateLeads(BuildContext context) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                "Migrating Leads",
                style: AppTextStyle.heading(size: 14),
              ),
              const SizedBox(height: 8),
              Text(
                "Processing companies and updating leads with correct IDs. Please do not close the app.",
                textAlign: TextAlign.center,
                style: AppTextStyle.small(
                  color: AppColors.grey,
                  size: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    int updatedLeadsCount = 0;
    int totalLeadsCount = 0;
    int updatedCompaniesCount = 0;

    try {
      final firestore = FirebaseFirestore.instance;
      final companiesSnap = await firestore.collection('COMPANY').get();

      for (var companyDoc in companiesSnap.docs) {
        final companyId = companyDoc.id;
        final companyRef = companyDoc.reference;
        log('Starting lead fields migration for company: $companyId');

        // 1. Fetch Lead Sources
        final Map<String, String> sourceMap = {};
        final sourcesSnap = await companyRef.collection('LEAD SOURCE').get();
        for (var doc in sourcesSnap.docs) {
          final name = (doc.data()['name'] as String?)?.toUpperCase().trim();
          if (name != null) {
            sourceMap[name] = doc.id;
          }
        }

        // 2. Fetch Lead Categories and Subcategories
        final Map<String, String> categoryMap = {};
        final Map<String, Map<String, String>> categorySubCategoryMap = {};
        final categoriesSnap = await companyRef.collection('LEADS CATEGORY').get();
        for (var doc in categoriesSnap.docs) {
          final catId = doc.id;
          final catName = (doc.data()['name'] as String?)?.toUpperCase().trim();
          if (catName != null) {
            categoryMap[catName] = catId;
          }

          final subCatsSnap = await doc.reference.collection('SUB CATEGORY').get();
          final Map<String, String> subCatMap = {};
          for (var subDoc in subCatsSnap.docs) {
            final subName = (subDoc.data()['name'] as String?)?.toUpperCase().trim();
            if (subName != null) {
              subCatMap[subName] = subDoc.id;
            }
          }
          categorySubCategoryMap[catId] = subCatMap;
        }

        // 3. Fetch Lead Stages and Tags
        final Map<String, String> stageMap = {};
        final Map<String, Map<String, String>> stageTagMap = {};
        final stagesSnap = await companyRef.collection('LEADS STAGE').get();
        for (var doc in stagesSnap.docs) {
          final stageId = doc.id;
          final stageName = (doc.data()['name'] as String?)?.toUpperCase().trim();
          if (stageName != null) {
            stageMap[stageName] = stageId;
          }

          final tagsSnap = await doc.reference.collection('LEADS TAG').get();
          final Map<String, String> tagMap = {};
          for (var tagDoc in tagsSnap.docs) {
            final tagName = (tagDoc.data()['name'] as String?)?.toUpperCase().trim();
            if (tagName != null) {
              tagMap[tagName] = tagDoc.id;
            }
          }
          stageTagMap[stageId] = tagMap;
        }

        // 4. Fetch all Leads in LEADS collection
        final leadsSnap = await companyRef.collection('LEADS').get();
        if (leadsSnap.docs.isNotEmpty) {
          updatedCompaniesCount++;
        }

        var batch = firestore.batch();
        int batchCount = 0;

        for (var leadDoc in leadsSnap.docs) {
          totalLeadsCount++;
          final leadData = leadDoc.data();

          final leadSource = (leadData['leadSource'] as String?)?.toUpperCase().trim() ?? '';
          final leadCategory = (leadData['leadCategory'] as String?)?.toUpperCase().trim() ?? '';
          final leadSubCategory = (leadData['leadSubCategory'] as String?)?.toUpperCase().trim() ?? '';
          final leadStage = (leadData['leadStage'] as String?)?.toUpperCase().trim() ?? '';
          final leadTag = (leadData['leadTag'] as String?)?.toUpperCase().trim() ?? '';

          final leadSourceId = sourceMap[leadSource] ?? '';
          final leadCategoryId = categoryMap[leadCategory] ?? '';
          
          String leadSubCategoryId = '';
          if (leadCategoryId.isNotEmpty && categorySubCategoryMap.containsKey(leadCategoryId)) {
            leadSubCategoryId = categorySubCategoryMap[leadCategoryId]![leadSubCategory] ?? '';
          }
          if (leadSubCategoryId.isEmpty && leadSubCategory.isNotEmpty) {
            // Fallback: search across all subcategories
            for (var subMap in categorySubCategoryMap.values) {
              if (subMap.containsKey(leadSubCategory)) {
                leadSubCategoryId = subMap[leadSubCategory]!;
                break;
              }
            }
          }

          final leadStageId = stageMap[leadStage] ?? '';

          String leadTagId = '';
          if (leadStageId.isNotEmpty && stageTagMap.containsKey(leadStageId)) {
            leadTagId = stageTagMap[leadStageId]![leadTag] ?? '';
          }
          if (leadTagId.isEmpty && leadTag.isNotEmpty) {
            // Fallback: search across all stage tags
            for (var tagMap in stageTagMap.values) {
              if (tagMap.containsKey(leadTag)) {
                leadTagId = tagMap[leadTag]!;
                break;
              }
            }
          }

          // Check if any of these fields are missing or different to avoid unnecessary writes
          final currentSourceId = leadData['leadSourceId'] ?? '';
          final currentCategoryId = leadData['leadCategoryId'] ?? '';
          final currentSubCategoryId = leadData['leadSubCategoryId'] ?? '';
          final currentStageId = leadData['leadStageId'] ?? '';
          final currentTagId = leadData['leadTagId'] ?? '';

          if (currentSourceId != leadSourceId ||
              currentCategoryId != leadCategoryId ||
              currentSubCategoryId != leadSubCategoryId ||
              currentStageId != leadStageId ||
              currentTagId != leadTagId) {
            
            batch.update(leadDoc.reference, {
              'leadSourceId': leadSourceId,
              'leadCategoryId': leadCategoryId,
              'leadSubCategoryId': leadSubCategoryId,
              'leadStageId': leadStageId,
              'leadTagId': leadTagId,
            });
            batchCount++;
            updatedLeadsCount++;

            // Commit batch if it reaches the Firestore limit of 500
            if (batchCount >= 500) {
              await batch.commit();
              batch = firestore.batch();
              batchCount = 0;
            }
          }

          // Fetch and update FOLLOW_UPS subcollection for this lead
          final followUpsSnap = await leadDoc.reference.collection('FOLLOW_UPS').get();
          for (var followUpDoc in followUpsSnap.docs) {
            final followUpData = followUpDoc.data();

            final fCategory = (followUpData['leadCategory'] as String?)?.toUpperCase().trim() ?? '';
            final fStage = (followUpData['leadStage'] as String?)?.toUpperCase().trim() ?? '';
            final fTag = (followUpData['leadTag'] as String?)?.toUpperCase().trim() ?? '';

            final fCategoryId = categoryMap[fCategory] ?? '';
            final fStageId = stageMap[fStage] ?? '';

            String fTagId = '';
            if (fStageId.isNotEmpty && stageTagMap.containsKey(fStageId)) {
              fTagId = stageTagMap[fStageId]![fTag] ?? '';
            }
            if (fTagId.isEmpty && fTag.isNotEmpty) {
              // Fallback: search across all stage tags
              for (var tagMap in stageTagMap.values) {
                if (tagMap.containsKey(fTag)) {
                  fTagId = tagMap[fTag]!;
                  break;
                }
              }
            }

            final currentFCategoryId = followUpData['leadCategoryId'] ?? '';
            final currentFStageId = followUpData['leadStageId'] ?? '';
            final currentFTagId = followUpData['leadTagId'] ?? '';

            if (currentFCategoryId != fCategoryId ||
                currentFStageId != fStageId ||
                currentFTagId != fTagId) {
              batch.update(followUpDoc.reference, {
                'leadCategoryId': fCategoryId,
                'leadStageId': fStageId,
                'leadTagId': fTagId,
              });
              batchCount++;

              if (batchCount >= 500) {
                await batch.commit();
                batch = firestore.batch();
                batchCount = 0;
              }
            }
          }
        }

        if (batchCount > 0) {
          await batch.commit();
        }
        log('Company $companyId migration completed.');
      }

      // Close the loading dialog
      if (!context.mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Migration Successful", style: AppTextStyle.heading(size: 14)),
          content: Text(
            "Successfully updated $updatedLeadsCount out of $totalLeadsCount leads across $updatedCompaniesCount companies.\n\n"
            "Added/Updated fields:\n"
            "- leadSourceId\n"
            "- leadCategoryId\n"
            "- leadSubCategoryId\n"
            "- leadStageId\n"
            "- leadTagId",
            style: AppTextStyle.small(size: 11.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

    } catch (e, stackTrace) {
      log("Error during lead migration: $e", stackTrace: stackTrace);
      // Close the loading dialog if open
      if (!context.mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Migration Failed", style: AppTextStyle.heading(size: 14)),
          content: Text(
            "An error occurred during migration: $e",
            style: AppTextStyle.small(size: 11.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}
