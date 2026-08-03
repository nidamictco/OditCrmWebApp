import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/add_lead_model.dart';
import '../../../../../core/constant/firebase_const.dart';
import '../../../reports/staff_reports/screen/staff_profile_screen.dart';

import '../../../dashboard/models/dashboard_count_model.dart';
import '../../follow_up/models/follow_up_activities_model.dart';
import '../../follow_up/models/staff_handler_model.dart';

abstract class IAddLeadRepository {
  Future<String> addLead(AddLeadModel lead);
  Future<List<AddLeadModel>> fetchLeads({
    required String staffId,
    required String role,
  });
  Future<List<AddLeadModel>> fetchDashboardLeads({
    required String staffId,
    required String role,
    required String fromCard,
    required DateTime? selectedDate,
    DateTime? toDate,
  });
  Future<void> updateLead(String id, AddLeadModel lead);
  Future<void> deleteLead(String id);
  Future<void> moveToDeleted(AddLeadModel lead);
  // Future<List<AddLeadModel>> fetchDeletedLeads();
  // Future<String> restoreLead(AddLeadModel lead);
  Future<void> permanentlyDeleteLead(String id);
  Future<void> assignStaff(String leadId, String staffId, String staffName);
  Future<AddLeadModel> getLeadById(String leadId);
  Future<void> deleteFollowUp({
    required String leadId,
    required String followUpId,
    required String changedByName,
    required String changedById,
    required String leadName,
    required String leadPhone,
  });
  Future<void> addFollowUp(
    String leadId,
    FollowUpModel followUp, {
    String? previousStage, // pass current lead's stage before update
    String? previousCategory,
    String? previousPriority,
    String changedByName = '',
    String changedById = '',
    String leadName = '',
    String leadPhone = '',
  });
  Future<DashboardCountModel> fetchLeadCounts({
    required String staffId,
    DateTime? selectedDate,
    DateTime? toDate,
    required String role,
    bool forceStaffFilter = false,
  });
  Future<void> transferLead(
    String leadId,
    TransferDetails transfer, {
    required String changedByName,
    required String changedById,
  });
  Future<void> _logActivity(String leadId, ActivityModel activity);
  Future<void> logLeadCreated({
    required String leadId,
    required String createdByName,
    required String createdById,
    required String assignedTo,
    required String leadStage,
    required String priority,
    required String leadCategory,
  });
  Future<void> logLeadUpdated({
    required String leadId,
    required String changedByName,
    required String changedById,
    required AddLeadModel previous,
    required AddLeadModel updated,
  });
  Future<List<LeadStaffHandler>> getLeadHandledStaffs(AddLeadModel lead);

  Future<Map<String, int>> fetchLeadCountsByCategory({
    required String staffId,
    required String role,
    required DateTime selectedDate,
    DateTime? toDate,
  });
  Future<List<LeadCategoryTableRow>> fetchLeadCategoryTableRows({
    required String staffId,
    required String role,
    required DateTime selectedDate,
    DateTime? toDate,
  });
  Future<Map<String, int>> fetchCallStatusCounts({
    required String staffId,
    required String role,
    DateTime? selectedDate,
    DateTime? toDate,
  });
  Future<bool> isContactNumberExists(String contactNumber);
  Future<bool> isWhatsappNumberExists(String whatsappNumber);
  Future<bool> isContactNumberExistsForOther(
    String contactNumber,
    String currentLeadId,
  );
  Future<bool> isWhatsappNumberExistsForOther(
    String whatsappNumber,
    String currentLeadId,
  );
  Future<List<ActivityModel>> fetchRecentActivities({
    required String staffId,
    required String role,
    int limit = 5,
  });
    Future<void> softDeleteLead(String leadId);
  Future<void> archiveDeletedLead(String leadId);
  Future<void> restoreLead(String leadId);
  Future<void> permanentlyDeleteArchivedLead(String leadId);
  Future<List<AddLeadModel>> fetchDeletedLeads();
}


enum _ArchiveOpType { set, delete }

class _ArchiveOp {
  final _ArchiveOpType type;
  final DocumentReference<Map<String, dynamic>> ref;
  final Map<String, dynamic>? data;

  _ArchiveOp.set(this.ref, this.data) : type = _ArchiveOpType.set;
  _ArchiveOp.delete(this.ref) : type = _ArchiveOpType.delete, data = null;
}

class AddLeadRepository implements IAddLeadRepository {
  final FirebaseFirestore _firestore;

  AddLeadRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS');
  CollectionReference<Map<String, dynamic>> get _deletedCollection =>
      FirestorePath.companyCollection('DELETED_LEADS');

  String _generateDateId(String prefix) {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final timePart = DateFormat('HHmmss').format(now);
    final ms =
        now.millisecondsSinceEpoch % 1000; 
    final id = now.millisecondsSinceEpoch.toString();
    return '$prefix-$datePart-$id';
  }

  @override
  Future<String> addLead(AddLeadModel lead) async {
    if (lead.clientName.trim().isEmpty) {
      throw ArgumentError('Client name cannot be empty.');
    }
    if (lead.contactNumber.trim().isEmpty) {
      throw ArgumentError('Contact number cannot be empty.');
    }

    await _collection.doc(lead.id).set(lead.toFirestore());
    log('[AddLeadRepository] Lead added with ID: ${lead.id}');

    return lead.id!;
  }

  @override
  Future<List<AddLeadModel>> fetchLeads({
    required String staffId,
    required String role,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection;

      if (role.toLowerCase() != 'admin') {
        query = query.where('assignedStaffId', isEqualTo: staffId);
      }

      final snap = await query.orderBy('createdAt', descending: true).get();

      // return snap.docs
      //     .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
      //     .toList();
      /// FETCH LEADS + FOLLOWUPS
      final List<AddLeadModel> allLeads = await Future.wait(
        snap.docs.map((leadDoc) async {
          /// MAIN LEAD
          final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

          /// FETCH FOLLOWUP SUBCOLLECTION
          final followUpSnap = await _collection
              .doc(leadDoc.id)
              .collection('FOLLOW_UPS')
              .orderBy('createdAt', descending: true)
              .get();

          /// CONVERT FOLLOWUPS
          final followUps = followUpSnap.docs.map((fupDoc) {
            return FollowUpModel.fromFirestore(fupDoc.data(), fupDoc.id);
          }).toList();

          /// RETURN LEAD WITH FOLLOWUPS
          return lead.copyWith(followUp: followUps);
        }),
      );
      // return allLeads;
     return allLeads.where((lead) => !lead.isDeleted).toList();
    } on FirebaseException catch (e) {
      debugPrint('[fetchLeads] Firebase error: ${e.code} — ${e.message}');
      rethrow;
    } catch (e, st) {
      debugPrint('[fetchLeads] Unexpected error: $e\n$st');
      rethrow;
    }
  }

  Future<List<AddLeadModel>> fetchDashboardLeadsOld({
    required String staffId,
    required String role,
    required String fromCard,
    required DateTime selectedDate,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    /// ---------------- ROLE FILTER ----------------
    /// Admin -> all leads
    /// Staff -> only assigned leads

    if (role.toLowerCase() != 'admin') {
      query = query.where('assignedStaffId', isEqualTo: staffId);
    }

    log("ddddddddddddddddddd");

    try {
      final snap = await query.orderBy('createdAt', descending: true).get();

      final allLeads = snap.docs
          .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
          .toList();

          final activeLeads = allLeads.where((lead) => !lead.isDeleted).toList();
// then use `activeLeads` instead of `allLeads` in every case below

      /// ---------------- DATE FILTER HELPER ----------------

      bool isSameDay(DateTime? date) {
        if (date == null) return false;

        return date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
      }

      /// ---------------- CARD FILTER ----------------

      switch (fromCard.toUpperCase()) {
        /// NEW LEADS
        case 'NEW':
          return activeLeads.where((lead) {
            return isSameDay(lead.createdAt);
          }).toList();

        /// FOLLOWUP LEADS
        case 'FOLLOWUP':
          return activeLeads.where((lead) {
            return isSameDay(lead.followUpDate);
          }).toList();

        /// CLOSED LEADS
        case 'CLOSED':
          return activeLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'CLOSED';
          }).toList();

        /// TOTAL CALLED
        case 'TOTAL':
          return activeLeads.where((lead) {
            return isSameDay(lead.calledDate);
          }).toList();

        /// MISSED / REJECTED
        case 'MISSED':
          return activeLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'REJECTED';
          }).toList();

        /// TRANSFERRED LEADS
        case 'TRANSFERRED':
          return activeLeads.where((lead) {
            if (lead.transferLeads == null || lead.transferLeads!.isEmpty) {
              return false;
            }

            return lead.transferLeads!.any((item) {
              final transferredTime = item.transferTime;
              // item['transferredTime'];

              if (transferredTime == null) {
                return false;
              }

              DateTime transferDate;

              // if (transferredTime is Timestamp) {
              //
              //   transferDate = transferredTime.toDate();
              //
              // } else
              transferDate = transferredTime;

              return isSameDay(transferDate);
            });
          }).toList();

        default:
          return activeLeads;
      }
    } catch (e) {
      log("error in fetchDashboardLeads ::: $e");
    }
    return [];
  }

  @override
  Future<List<AddLeadModel>> fetchDashboardLeads({
    required String staffId,
    required String role,
    required String fromCard,
    required DateTime? selectedDate,
    DateTime? toDate,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    /// ROLE FILTER
    if (role.toLowerCase() != 'admin') {
      query = query.where('assignedStaffId', isEqualTo: staffId);
    }

    try {
      final snap = await query.orderBy('createdAt', descending: true).get();

      /// FETCH LEADS + FOLLOWUPS
      final List<AddLeadModel> allLeads = await Future.wait(
        snap.docs.map((leadDoc) async {
          /// MAIN LEAD
          final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

          /// FETCH FOLLOWUP SUBCOLLECTION
          final followUpSnap = await _collection
              .doc(leadDoc.id)
              .collection('FOLLOW_UPS')
              .orderBy('createdAt', descending: true)
              .get();

          /// CONVERT FOLLOWUPS
          final followUps = followUpSnap.docs.map((fupDoc) {
            return FollowUpModel.fromFirestore(fupDoc.data(), fupDoc.id);
          }).toList();

          /// RETURN LEAD WITH FOLLOWUPS
          return lead.copyWith(followUp: followUps);
        }),
      );

      /// DATE FILTER HELPER
     
     final activeLeads = allLeads.where((lead) => !lead.isDeleted).toList();
// then use `activeLeads` instead of `allLeads` in every case below

      final effectiveTo = toDate ?? DateTime.now(); //selectedDate ??
      final DateTime? fromDay = selectedDate != null
          ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
          : null;
      final DateTime toDay = DateTime(
        effectiveTo.year,
        effectiveTo.month,
        effectiveTo.day,
        23,
        59,
        59,
      );

      bool isInRange(DateTime? date) {
        if (date == null) return false;
        if (selectedDate == null) {
          return date.isBefore(toDay);
        }
        return !date.isBefore(fromDay!) && !date.isAfter(toDay);
      }

      bool isbeforeFromDay(DateTime? date) {
        if (date == null) return false;
        if (selectedDate == null) {
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          return date.isBefore(todayStart);
        }
        return date.isBefore(fromDay!);
      }

      // bool isAfterToDay(DateTime? date) {
      //   if (date == null) return false;
      //   return date.isAfter(toDay);
      // }

      /// CARD FILTER
      switch (fromCard.toUpperCase()) {
        /// NEW LEADS
        case 'NEW':
          return activeLeads.where((lead) {
            return isInRange(lead.createdAt) &&
                lead.leadStage.toUpperCase() == 'NEW' &&
                // lead.followUp!.isEmpty;
                (lead.followUp == null || lead.followUp!.isEmpty);
          }).toList();

        /// FOLLOWUP LEADS
        case 'FOLLOWUP':
          return activeLeads.where((lead) {
            return isInRange(lead.followUpDate) &&
                (lead.leadStage.toUpperCase() == 'FOLLOWUP' ||
                    lead.leadStage.toUpperCase() == 'TRANSFERRED');
          }).toList();

        /// CLOSED LEADS
        case 'CLOSED':
          return activeLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'CLOSED' &&
                isInRange(lead.calledDate);
          }).toList();

        /// TOTAL CALLED
        case 'TOTAL':
          final List<AddLeadModel> result = [];
          for (final lead in activeLeads) {
            final matchingFollowUps =
                lead.followUp?.where((fup) {
                  final inRange = isInRange(fup.calledDate);
                  if (role.toLowerCase() != 'admin') {
                    return inRange && fup.createdById == staffId;
                  }
                  return inRange;
                }).toList() ??
                [];
            if (matchingFollowUps.isNotEmpty) {
              for (final fup in matchingFollowUps) {
                result.add(
                  lead.copyWith(
                    calledDate: fup.calledDate,
                    leadStage: fup.leadStage,
                    leadCategory: fup.leadCategory,
                    priority: fup.priority,
                    followUpDate: fup.nextFollowUpDate,
                    remarks: fup.remarks,
                    callResult: fup.calledStatus,
                  ),
                );
              }
            } else if (isInRange(lead.calledDate)) {
              result.add(lead);
            }
          }
          // Sort the expanded calls list by calledDate descending so latest call comes first
          result.sort((a, b) {
            if (a.calledDate == null && b.calledDate == null) return 0;
            if (a.calledDate == null) return 1;
            if (b.calledDate == null) return -1;
            return b.calledDate!.compareTo(a.calledDate!);
          });
          return result;

        /// MISSED / REJECTED
        case 'MISSED':
          return activeLeads.where((lead) {
            if (lead.leadStage.toUpperCase() == 'NEW') {
              if (lead.createdAt == null) return false;
              return isbeforeFromDay(lead.createdAt);
            }
            if (lead.leadStage.toUpperCase() == 'FOLLOWUP' ||
                lead.leadStage.toUpperCase() == 'TRANSFERRED') {
              if (lead.followUpDate == null) return false;
              return isbeforeFromDay(lead.followUpDate);
            }
            return false;
            // return (lead.leadStage.toUpperCase() == 'NEW' &&
            //         isbeforeFromDay(lead.createdAt)) ||
            // (lead.leadStage.toUpperCase() == 'FOLLOWUP' ||
            //         // lead.leadStage.toUpperCase() == 'NEW' ||
            //         lead.leadStage.toUpperCase() == 'TRANSFERRED') &&
            //     isbeforeFromDay(lead.followUpDate);
          }).toList();

        /// TRANSFERRED
        case 'TRANSFERRED':
          return activeLeads.where((lead) {
            if (lead.transferLeads == null || lead.transferLeads!.isEmpty) {
              return false;
            }

            return lead.transferLeads!.any((item) {
              final transferredTime = item.transferTime;

              if (transferredTime == null) {
                return false;
              }

              return isInRange(transferredTime);
            });
          }).toList();

        default:
          return activeLeads;
      }
    } catch (e) {
      log("error in fetchDashboardLeads ::: $e");

      return [];
    }
  }

  @override
  Future<void> updateLead(String id, AddLeadModel lead) async {
    if (id.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

    //    final data = lead.toFirestore();
    // data.remove('createdAt'); // ✅ prevent createdAt from being overwritten
    // data['updatedAt'] = FieldValue.serverTimestamp();

    await _collection.doc(id).update(lead.toUpdateMap());
  }

  @override
  Future<void> deleteLead(String id) async {
    if (id.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
    await _collection.doc(id).delete();
  }

  @override
  Future<void> moveToDeleted(AddLeadModel lead) async {
    assert(lead.id != null, 'ID must not be null');

    final deletedLead = lead.copyWith(deletedAt: DateTime.now());

    await _deletedCollection.add(deletedLead.toFirestore());
    await _collection.doc(lead.id).delete();

    log('[StaffRepository] Staff moved to DELETED_STAFF: ${lead.id}');
  }

  // @override
  // Future<String> restoreLead(AddLeadModel lead) async {
  //   if (lead.clientName.trim().isEmpty) {
  //     throw ArgumentError('Client name cannot be empty.');
  //   }
  //   if (lead.contactNumber.trim().isEmpty) {
  //     throw ArgumentError('Contact number cannot be empty.');
  //   }
  //   final doc = await _collection.add(lead.toFirestore());
  //   await _deletedCollection.doc(lead.id).delete();
  //   return doc.id;
  // }

  // @override
  // Future<List<AddLeadModel>> fetchDeletedLeads() async {
  //   final snap = await _deletedCollection
  //       .orderBy('deletedAt', descending: true)
  //       .get();
  //   return snap.docs
  //       .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
  //       .toList();
  // }

  @override
  Future<void> permanentlyDeleteLead(String id) async {
    await _deletedCollection.doc(id).delete();
    log('[AddLeadRepository] Lead permanently deleted: $id');
  }

  @override
  Future<void> assignStaff(
    String leadId,
    String staffId,
    String staffName,
  ) async {
    if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
    await _collection.doc(leadId).update({
      'assignedStaffId': staffId,
      'assignedStaff': staffName,
    });
    log('[AddLeadRepository] Staff assigned to lead: $leadId → $staffId');
  }

  @override
  Future<void> addFollowUp(
    String leadId,
    FollowUpModel followUp, {
    String? previousStage, // pass current lead's stage before update
    String? previousCategory,
    String? previousPriority,
    String changedByName = '',
    String changedById = '',
    String leadName = '',
    String leadPhone = '',
  }) async {
    if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

    final batch = FirebaseFirestore.instance.batch();
    final activityRef = _collection.doc(leadId).collection('ACTIVITIES');

    // 1. Write the follow-up document
    final String followUpId = followUp.id ?? _generateDateId('FUP');
    final syncedFollowUp = followUp.copyWith(id: followUpId);
    final fupRef = _collection
        .doc(leadId)
        .collection('FOLLOW_UPS')
        .doc(followUpId);
    batch.set(fupRef, syncedFollowUp.toFirestore(), SetOptions(merge: true));

    // 2. Update lead document
    final leadRef = _collection.doc(leadId);
    // batch.update(leadRef, {
    //   'leadStage': followUp.leadStage,
    //   'priority': followUp.priority,
    //   'leadCategory': followUp.leadCategory,
    //   'nextFollowUpDate': followUp.nextFollowUpDate,
    //   'lastCalledDate': followUp.calledDate,
    //   'callResult': followUp.calledStatus,
    //   'leadTag': followUp.leadTag,
    //   'updatedAt': FieldValue.serverTimestamp(),
    //   // 'remarks' : followUp.remarks,
    // });
    final Map<String, dynamic> leadUpdates = {
      'leadStage': followUp.leadStage,
      'leadStageId':followUp.leadStageId,
      'priority': followUp.priority,
      'leadCategory': followUp.leadCategory,
      'leadCategoryId':followUp.leadCategoryId,
      'leadSubCategory':followUp.leadSubCategory,
      'leadSubCategoryId':followUp.leadSubCategoryId,
      'nextFollowUpDate': followUp.nextFollowUpDate,
      'lastCalledDate': followUp.calledDate,
      'callResult': followUp.calledStatus,
      'leadTag': followUp.leadTag,
      'leadTagId':followUp.leadTagId,
      'updatedAt': FieldValue.serverTimestamp(),
      'hasFollowUp': true,
    };
    if ((followUp.adress ?? '').isNotEmpty) {
      leadUpdates['address'] = followUp.adress;
    }
    if ((followUp.email ?? '').isNotEmpty) {
      leadUpdates['email'] = followUp.email;
    }
    if ((followUp.remarks ?? '').isNotEmpty) {
      leadUpdates['remarks'] = followUp.remarks;
    }
    if((followUp.leadWhatsappNo ?? '').isNotEmpty) {
      leadUpdates['whatsappNumber'] = followUp.leadWhatsappNo;
    }
    batch.update(leadRef, leadUpdates);

    final now = DateTime.now();

    // Helper to add an activity doc in the batch
    // void logActivity(ActivityModel activity) {
    //   batch.set(activityRef.doc(), activity.toFirestore());
    // }

    void logActivity(ActivityModel activity) {
  final ref = activityRef.doc(); // ← was activityRef.doc() inline, discard-and-lose-id
  batch.set(ref, ActivityModel(
    id: ref.id, // ← sync
    type: activity.type,
    changedBy: activity.changedBy,
    changedById: activity.changedById,
    changedAt: activity.changedAt,
    previousValue: activity.previousValue,
    newValue: activity.newValue,
    leadId: activity.leadId,
    leadName: activity.leadName,
    leadPhone: activity.leadPhone,
    description: activity.description,
  ).toFirestore());
}

    // 3. Always log the follow-up added activity
    logActivity(
      ActivityModel(
        id: '',
        type: ActivityType.followupAdded,
        changedBy: changedByName,
        changedById: changedById,
        changedAt: now,
        previousValue: followUp.calledStatus,
        leadId: leadId, // ← add
        leadName: leadName, // ← add
        leadPhone: leadPhone, // ← add
        newValue: DateFormat(
          'dd-MM-yyyy HH:mm',
        ).format(followUp.nextFollowUpDate),
        description:
            'Follow-up added. Call status: ${followUp.calledStatus}. '
            'Next follow-up scheduled to '
            '${DateFormat('dd-MM-yyyy HH:mm').format(followUp.nextFollowUpDate)}.',
      ),
    );

    // 4. Log status change only if it actually changed
    if (previousStage != null &&
        previousStage.isNotEmpty &&
        previousStage != followUp.leadStage) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.statusChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousStage,
          newValue: followUp.leadStage,
          description:
              'Status changed from $previousStage to ${followUp.leadStage}.',
        ),
      );
    }

    // 5. Log category change only if it changed
    if (previousCategory != null &&
        previousCategory.isNotEmpty &&
        previousCategory != followUp.leadCategory &&
        followUp.leadCategory.isNotEmpty) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.categoryChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousCategory,
          newValue: followUp.leadCategory,
          description:
              'Lead category updated from $previousCategory to ${followUp.leadCategory}.',
        ),
      );
    }

    // 6. Log priority change only if it changed
    if (previousPriority != null &&
        previousPriority.isNotEmpty &&
        previousPriority != followUp.priority &&
        followUp.priority.isNotEmpty) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.priorityChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousPriority,
          newValue: followUp.priority,
          description:
              'Priority updated from $previousPriority to ${followUp.priority}.',
        ),
      );
    }

    await batch.commit();
    log('[AddLeadRepository] FollowUp + activities written for lead: $leadId');
  }

  @override
  Future<void> transferLead(
    String leadId,
    TransferDetails transfer, {
    required String changedByName,
    required String changedById,
  }) async {
    if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

    final batch = FirebaseFirestore.instance.batch();
    final String transferId = _generateDateId('TRF');

     final syncedTransfer = transfer.copyWith(id: transferId);

    // 1. Add to TRANSFER_LEADS subcollection
    final transferRef = _collection
        .doc(leadId)
        .collection('TRANSFER_LEADS')
        .doc(transferId);
    batch.set(transferRef, syncedTransfer.toFirestore());

    // 2. Update the lead document
    final leadRef = _collection.doc(leadId);
    batch.update(leadRef, {
      'assignedStaff': transfer.toStaff,
      'assignedStaffId': transfer.toStaffId,
      'leadStage': 'TRANSFERRED',
       'leadStageId':transfer.leadStageId,
      'transferLeads': FieldValue.arrayUnion([transfer.toFirestore()]),
    });

    // 3. Log the transfer activity
    final activityRef = _collection.doc(leadId).collection('ACTIVITIES').doc();
    batch.set(
      activityRef,
      ActivityModel(
        id:activityRef.id,
        type: ActivityType.staffAssigned,
        changedBy: changedByName,
        changedById: changedById,
        changedAt: DateTime.now(),
        previousValue: transfer.fromStaff,
        newValue: transfer.toStaff,
        description:
            'Lead transferred from ${transfer.fromStaff} to ${transfer.toStaff}.',
      ).toFirestore(),
    );

    await batch.commit();
    log('[AddLeadRepository] Lead transferred: $leadId → ${transfer.toStaff}');
  }

  // Future<void> transferLead(String leadId, TransferDetails transfer) async {
  //   if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
  //
  //   final String transferId = _generateDateId('TRF');
  //
  //   // ── Add to subcollection ──────────────────────────────────────────────
  //   await _collection
  //       .doc(leadId)
  //       .collection('TRANSFER_LEADS')
  //       .doc(transferId)
  //       .set(transfer.toFirestore());
  //
  //   // ── Update the lead document ──────────────────────────────────────────
  //   await _collection.doc(leadId).update({
  //     'assignedStaff':   transfer.toStaff,
  //     'assignedStaffId': transfer.toStaffId,
  //     'transferLeads': FieldValue.arrayUnion([transfer.toFirestore()]),
  //   });
  //
  //   log('[AddLeadRepository] Lead transferred: $leadId → ${transfer.toStaff}');
  // }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isBeforeDay(DateTime d1, DateTime d2) {
    final day1 = DateTime(d1.year, d1.month, d1.day);
    final day2 = DateTime(d2.year, d2.month, d2.day);
    return day1.isBefore(day2);
  }


  // @override
  // Future<DashboardCountModel> fetchLeadCounts({
  //   required String staffId,
  //   DateTime? selectedDate,
  //   DateTime? toDate,
  //   required String role,
  //   bool forceStaffFilter = false,
  // }) async {
  //   final sw = Stopwatch()..start();

  //   final now = DateTime.now();
  //   final todayStart = DateTime(now.year, now.month, now.day);
  //   final startOfDay = selectedDate != null
  //       ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
  //       : null;
  //   final endOfDay = selectedDate != null
  //       ? DateTime(
  //           selectedDate.year,
  //           selectedDate.month,
  //           selectedDate.day,
  //           23,
  //           59,
  //           59,
  //         )
  //       : DateTime(now.year, now.month, now.day, 23, 59, 59);

  //   // ── Single query, no composite index needed ──────────────────────────────
  //   Query<Map<String, dynamic>> base = _collection;
  //   if (forceStaffFilter && staffId.isNotEmpty) {
  //     base = base.where('assignedStaffId', isEqualTo: staffId);
  //   } else if (role.toLowerCase() != 'admin') {
  //     base = base.where('assignedStaffId', isEqualTo: staffId);
  //   }

  //   // ONE round-trip to Firestore — no subcollection reads at all
  //   final snap = await base.get();
  //   log('[fetchLeadCounts...............] docs: ${snap.docs.length}');

  //   final activeLeadIds = snap.docs.map((doc) => doc.id).toSet();
  //   int newLeadCount = 0;
  //   int followUpCount = 0;
  //   int closedLeadCount = 0;
  //   // int totalCalledCount = await getTotalCalledCount(
  //   //   startOfDay,
  //   //   endOfDay,
  //   //   staffId,
  //   //   role,
  //   // );
  //   int totalCalledCount = await findTotalCalledCount(
  //     staffId,
  //     role,
  //     selectedDate,
  //     endOfDay,
  //   );
  //   int missedLeadCount = 0;
  //   int transferredCount = 0;

  //   for (final doc in snap.docs) {
  //     final data = doc.data();
  //     if (data['isDeleted'] == true) continue;
  //     final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();

  //     // ── NEW ────────────────────────────────────────────────────────────
  //     if (leadStage == 'NEW') {
  //       final createdAt = data['createdAt'];
  //       if (createdAt != null) {
  //         final createdDate = (createdAt as Timestamp).toDate();
  //         final inRange = selectedDate != null
  //             ? _isInRange(createdDate, startOfDay!, endOfDay)
  //             : !createdDate.isAfter(endOfDay);
  //         if (inRange) {
  //           final hasFollowUp = data['hasFollowUp'] as bool? ?? false;
  //           if (!hasFollowUp) newLeadCount++;
  //         }
  //       }
  //     }

  //     // ── FOLLOWUP ───────────────────────────────────────────────────────
  //     if (leadStage == 'FOLLOWUP') {
  //       final nextFollowUpDate = data['nextFollowUpDate'];
  //       if (nextFollowUpDate != null) {
  //         final followDate = (nextFollowUpDate as Timestamp).toDate();
  //         final inRange = selectedDate != null
  //             ? _isInRange(followDate, startOfDay!, endOfDay)
  //             : !followDate.isAfter(endOfDay);
  //         if (inRange) followUpCount++;
  //       }
  //     }

  //     // ── CLOSED ─────────────────────────────────────────────────────────
  //     if (leadStage == 'CLOSED') {
  //       final lastCalledDate = data['lastCalledDate'];
  //       final createdAt = data['createdAt'];
  //       if (lastCalledDate != null) {
  //         final calledDate = (lastCalledDate as Timestamp).toDate();
  //         final inRange = selectedDate != null
  //             ? _isInRange(calledDate, startOfDay!, endOfDay)
  //             : !calledDate.isAfter(endOfDay);
  //         if (inRange) closedLeadCount++;
  //       } else if (createdAt != null) {
  //         final createdDate = (createdAt as Timestamp).toDate();
  //         final inRange = selectedDate != null
  //             ? _isInRange(createdDate, startOfDay!, endOfDay)
  //             : !createdDate.isAfter(endOfDay);
  //         if (inRange) closedLeadCount++;
  //       }
  //     }

  //     // ── TOTAL CALLED ───────────────────────────────────────────────────
  //     // Handled outside the loop above to avoid N+1 queries.

  //     // ── MISSED ─────────────────────────────────────────────────────────
  //     if (leadStage == 'NEW') {
  //       final createdAt = data['createdAt'];
  //       if (createdAt != null) {
  //         final createdDate = (createdAt as Timestamp).toDate();
  //         final baseline = selectedDate != null ? startOfDay! : todayStart;
  //         if (_isBeforeDay(createdDate, baseline)) {
  //           missedLeadCount++;
  //         }
  //       }
  //     }
  //     if (leadStage == 'FOLLOWUP') {
  //       final nextFollowUpDate = data['nextFollowUpDate'];
  //       if (nextFollowUpDate != null) {
  //         final followDate = (nextFollowUpDate as Timestamp).toDate();
  //         final baseline = selectedDate != null ? startOfDay! : todayStart;
  //         if (_isBeforeDay(followDate, baseline)) {
  //           missedLeadCount++;
  //         }
  //       }
  //     }
  //     if (leadStage == 'TRANSFERRED') {
  //       final nextFollowUpDate = data['nextFollowUpDate'];
  //       if (nextFollowUpDate != null) {
  //         final followDate = (nextFollowUpDate as Timestamp).toDate();
  //         final baseline = selectedDate != null ? startOfDay! : todayStart;
  //         if (_isBeforeDay(followDate, baseline)) {
  //           missedLeadCount++;
  //         }
  //       }
  //     }

  //     // if (leadStage == 'FOLLOWUP' || leadStage == 'NEW') {
  //     //   final nextFollowUpDate = data['nextFollowUpDate'];
  //     //   if (nextFollowUpDate != null) {
  //     //     final followDate = (nextFollowUpDate as Timestamp).toDate();
  //     //     final baseline = selectedDate != null ? startOfDay! : todayStart;
  //     //     if (_isBeforeDay(followDate, baseline)) missedLeadCount++;
  //     //   }
  //     // }

  //     // ── TRANSFERRED ────────────────────────────────────────────────────
  //     if (leadStage == 'TRANSFERRED') {
  //       final transferredList = data['transferLeads'];
  //       if (transferredList is List) {
  //         bool counted = false;
  //         for (final item in transferredList) {
  //           if (counted) break;
  //           if (item is Map<String, dynamic>) {
  //             final t = item['transferTime'];
  //             if (t != null) {
  //               final td = (t as Timestamp).toDate();
  //               final inRange = selectedDate != null
  //                   ? _isInRange(td, startOfDay!, endOfDay)
  //                   : !td.isAfter(endOfDay);
  //               if (inRange) {
  //                 transferredCount++;
  //                 counted = true;
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }
  //   }

  //   sw.stop();
  //   log(
  //     '[fetchLeadCounts] new:$newLeadCount followUp:$followUpCount '
  //     'closed:$closedLeadCount total:$totalCalledCount '
  //     'missed:$missedLeadCount transferred:$transferredCount '
  //     '— ${sw.elapsedMilliseconds}ms',
  //   );

  //   return DashboardCountModel(
  //     newLeadCount: newLeadCount,
  //     followUpCount: followUpCount,
  //     closedLeadCount: closedLeadCount,
  //     totalCalledCount: totalCalledCount,
  //     missedLeadCount: missedLeadCount,
  //     transferredCount: transferredCount,
  //   );
  // }

@override
Future<DashboardCountModel> fetchLeadCounts({
  required String staffId,
  DateTime? selectedDate,
  DateTime? toDate, // NEW
  required String role,
  bool forceStaffFilter = false,
}) async {
  final sw = Stopwatch()..start();

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  final startOfDay = selectedDate != null
      ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
      : null;

  // CHANGED: endOfDay now respects a real range end (toDate), falling back
  // to selectedDate (single-day case) then to "now" (no filter case).
  final effectiveEnd = toDate ?? selectedDate ?? now;
  final endOfDay = DateTime(
    effectiveEnd.year,
    effectiveEnd.month,
    effectiveEnd.day,
    23, 59, 59,
  );

  Query<Map<String, dynamic>> base = _collection;
  if (forceStaffFilter && staffId.isNotEmpty) {
    base = base.where('assignedStaffId', isEqualTo: staffId);
  } else if (role.toLowerCase() != 'admin') {
    base = base.where('assignedStaffId', isEqualTo: staffId);
  }

  final snap = await base.get();
  log('[fetchLeadCounts...............] docs: ${snap.docs.length}');

  final activeLeadIds = snap.docs.map((doc) => doc.id).toSet();
  int newLeadCount = 0;
  int followUpCount = 0;
  int closedLeadCount = 0;

  // CHANGED: pass the real toDate through (not a synthetic single-day endOfDay)
  int totalCalledCount = await findTotalCalledCount(
    staffId,
    role,
    selectedDate,
    toDate, // was: endOfDay
  );

  int missedLeadCount = 0;
  int transferredCount = 0;

  // ── everything below this line is UNCHANGED — it already uses
  //    startOfDay/endOfDay/_isInRange generically, so it now naturally
  //    spans the full range instead of a single day ──────────────────────
  for (final doc in snap.docs) {
    final data = doc.data();
    if (data['isDeleted'] == true) continue;
    final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();

    if (leadStage == 'NEW') {
      final createdAt = data['createdAt'];
      if (createdAt != null) {
        final createdDate = (createdAt as Timestamp).toDate();
        final inRange = selectedDate != null
            ? _isInRange(createdDate, startOfDay!, endOfDay)
            : !createdDate.isAfter(endOfDay);
        if (inRange) {
          final hasFollowUp = data['hasFollowUp'] as bool? ?? false;
          if (!hasFollowUp) newLeadCount++;
        }
      }
    }

    // if (leadStage == 'FOLLOWUP') {
    //   final nextFollowUpDate = data['nextFollowUpDate'];
    //   if (nextFollowUpDate != null) {
    //     final followDate = (nextFollowUpDate as Timestamp).toDate();
    //     final inRange = selectedDate != null
    //         ? _isInRange(followDate, startOfDay!, endOfDay)
    //         : !followDate.isAfter(endOfDay);
    //     if (inRange) followUpCount++;
    //   }
    // }

    // CHANGED: TRANSFERRED-stage leads with a pending nextFollowUpDate now
    // also count toward Follow-up, same as FOLLOWUP-stage leads.
    if (leadStage == 'FOLLOWUP' || leadStage == 'TRANSFERRED') {
      final nextFollowUpDate = data['nextFollowUpDate'];
      if (nextFollowUpDate != null) {
        final followDate = (nextFollowUpDate as Timestamp).toDate();
        final inRange = selectedDate != null
            ? _isInRange(followDate, startOfDay!, endOfDay)
            : !followDate.isAfter(endOfDay);
        if (inRange) followUpCount++;
      }
    }

    if (leadStage == 'CLOSED') {
      final lastCalledDate = data['lastCalledDate'];
      final createdAt = data['createdAt'];
      if (lastCalledDate != null) {
        final calledDate = (lastCalledDate as Timestamp).toDate();
        final inRange = selectedDate != null
            ? _isInRange(calledDate, startOfDay!, endOfDay)
            : !calledDate.isAfter(endOfDay);
        if (inRange) closedLeadCount++;
      } else if (createdAt != null) {
        final createdDate = (createdAt as Timestamp).toDate();
        final inRange = selectedDate != null
            ? _isInRange(createdDate, startOfDay!, endOfDay)
            : !createdDate.isAfter(endOfDay);
        if (inRange) closedLeadCount++;
      }
    }

    if (leadStage == 'NEW') {
      final createdAt = data['createdAt'];
      if (createdAt != null) {
        final createdDate = (createdAt as Timestamp).toDate();
        final baseline = selectedDate != null ? startOfDay! : todayStart;
        if (_isBeforeDay(createdDate, baseline)) missedLeadCount++;
      }
    }
    if (leadStage == 'FOLLOWUP') {
      final nextFollowUpDate = data['nextFollowUpDate'];
      if (nextFollowUpDate != null) {
        final followDate = (nextFollowUpDate as Timestamp).toDate();
        final baseline = selectedDate != null ? startOfDay! : todayStart;
        if (_isBeforeDay(followDate, baseline)) missedLeadCount++;
      }
    }
    if (leadStage == 'TRANSFERRED') {
      final nextFollowUpDate = data['nextFollowUpDate'];
      if (nextFollowUpDate != null) {
        final followDate = (nextFollowUpDate as Timestamp).toDate();
        final baseline = selectedDate != null ? startOfDay! : todayStart;
        if (_isBeforeDay(followDate, baseline)) missedLeadCount++;
      }
    }

    if (leadStage == 'TRANSFERRED') {
      final transferredList = data['transferLeads'];
      if (transferredList is List) {
        bool counted = false;
        for (final item in transferredList) {
          if (counted) break;
          if (item is Map<String, dynamic>) {
            final t = item['transferTime'];
            if (t != null) {
              final td = (t as Timestamp).toDate();
              final inRange = selectedDate != null
                  ? _isInRange(td, startOfDay!, endOfDay)
                  : !td.isAfter(endOfDay);
              if (inRange) {
                transferredCount++;
                counted = true;
              }
            }
          }
        }
      }
    }
  }

  sw.stop();
  log(
    '[fetchLeadCounts] new:$newLeadCount followUp:$followUpCount '
    'closed:$closedLeadCount total:$totalCalledCount '
    'missed:$missedLeadCount transferred:$transferredCount '
    '— ${sw.elapsedMilliseconds}ms',
  );

  return DashboardCountModel(
    newLeadCount: newLeadCount,
    followUpCount: followUpCount,
    closedLeadCount: closedLeadCount,
    totalCalledCount: totalCalledCount,
    missedLeadCount: missedLeadCount,
    transferredCount: transferredCount,
  );
}

  // ── Add this helper if not already present ──────────────────────────────────
  bool _isInRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  Future<int> findTotalCalledCount(
    String staffId,
    String role,
    DateTime? selectedDate,
    DateTime? toDate,
  ) async {
    Query<Map<String, dynamic>> query = _collection;

    /// ROLE FILTER
    if (role.toLowerCase() != 'admin') {
      query = query.where('assignedStaffId', isEqualTo: staffId);
    }

    try {
      final snap = await query.orderBy('createdAt', descending: true).get();

      /// FETCH LEADS + FOLLOWUPS
      final List<AddLeadModel> allLeads = await Future.wait(
        snap.docs.map((leadDoc) async {
          /// MAIN LEAD
          final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

          /// FETCH FOLLOWUP SUBCOLLECTION
          final followUpSnap = await _collection
              .doc(leadDoc.id)
              .collection('FOLLOW_UPS')
              .orderBy('createdAt', descending: true)
              .get();

          /// CONVERT FOLLOWUPS
          final followUps = followUpSnap.docs.map((fupDoc) {
            return FollowUpModel.fromFirestore(fupDoc.data(), fupDoc.id);
          }).toList();

          /// RETURN LEAD WITH FOLLOWUPS
          return lead.copyWith(followUp: followUps);
        }),
      );

      // final activeLeads = allLeads.where((lead) => !lead.isDeleted).toList();

      // final effectiveTo = toDate ?? DateTime.now(); //selectedDate ??
      // final DateTime? fromDay = selectedDate != null
      //     ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
      //     : null;
      // final DateTime toDay = DateTime(
      //   effectiveTo.year,
      //   effectiveTo.month,
      //   effectiveTo.day,
      //   23,
      //   59,
      //   59,
      // );

      // bool isInRange(DateTime? date) {
      //   if (date == null) return false;
      //   if (selectedDate == null) {
      //     return date.isBefore(toDay);
      //   }
      //   return !date.isBefore(fromDay!) && !date.isAfter(toDay);
      // }

      final activeLeads = allLeads.where((lead) => !lead.isDeleted).toList();

      // CHANGED: when no filter is active, default the range to "today only"
      // instead of "before end of today" (which matched every past call).
      final now = DateTime.now();
      final DateTime fromDay = selectedDate != null
          ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
          : DateTime(now.year, now.month, now.day);
      final DateTime effectiveTo = toDate ?? selectedDate ?? now;
      final DateTime toDay = DateTime(
        effectiveTo.year,
        effectiveTo.month,
        effectiveTo.day,
        23,
        59,
        59,
      );

      bool isInRange(DateTime? date) {
        if (date == null) return false;
        return !date.isBefore(fromDay) && !date.isAfter(toDay);
      }

      final List<AddLeadModel> result = [];

      int totalCount = 0;
      for (final lead in activeLeads) {
        final matchingFollowUps =
            lead.followUp?.where((fup) {
              final inRange = isInRange(fup.calledDate);
              if (role.toLowerCase() != 'admin') {
                return inRange && fup.createdById == staffId;
              }
              return inRange;
            }).toList() ??
            [];
        if (matchingFollowUps.isNotEmpty) {
          for (final fup in matchingFollowUps) {
            totalCount++;
          }
        } else if (isInRange(lead.calledDate)) {
          totalCount++;
          // result.add(lead);
        }
      }
      log("totalCount $totalCount");
      // Sort the expanded calls list by calledDate descending so latest call comes first

      return totalCount;
    } catch (e) {
      log("error in fetchDashboardLeads ::: $e");

      return 0;
    }
  }

  Future<int> getTotalCalledCount(
    DateTime startOfDay,
    DateTime endOfDay,
    String staffId,
    String role,
  ) async {
    int totalCalledCount = 0;
    try {
      final startTs = Timestamp.fromDate(startOfDay);
      final endTs = Timestamp.fromDate(endOfDay);
      Query<Map<String, dynamic>> fupQuery = _firestore.collectionGroup(
        'FOLLOW_UPS',
      );
      // Query on calledDate to match exactly how leadlistscreen filters follow-ups.
      // Use single-field query to avoid requiring composite indexes on Firestore.
      fupQuery = fupQuery
          .where('calledDate', isGreaterThanOrEqualTo: startTs)
          .where('calledDate', isLessThanOrEqualTo: endTs);
      final fupSnap = await fupQuery.get();

      int count = 0;
      for (final doc in fupSnap.docs) {
        final data = doc.data();
        if (role.toLowerCase() != 'admin') {
          if (data['createdById'] == staffId) {
            count++;
          }
        } else {
          count++;
        }
      }
      totalCalledCount = count;
    } catch (e) {
      log('Error fetching follow-up counts in fetchLeadCounts: $e');
    }
    return totalCalledCount;
  }

  // @override
  // Future<void> _logActivity(String leadId, ActivityModel activity) async {
  //   await _collection
  //       .doc(leadId)
  //       .collection('ACTIVITIES')
  //       .doc()
  //       .set(activity.toFirestore());
  // }

@override
Future<void> _logActivity(String leadId, ActivityModel activity) async {
  final ref = _collection.doc(leadId).collection('ACTIVITIES').doc();
  await ref.set(
    ActivityModel(
      id: ref.id, // ← was activity.id (always '')
      type: activity.type,
      changedBy: activity.changedBy,
      changedById: activity.changedById,
      changedAt: activity.changedAt,
      previousValue: activity.previousValue,
      newValue: activity.newValue,
      description: activity.description,
      leadId: activity.leadId,
      leadName: activity.leadName,
      leadPhone: activity.leadPhone,
    ).toFirestore(),
  );
}

  Future<void> logLeadCreated({
    required String leadId,
    required String createdByName,
    required String createdById,
    required String assignedTo,
    required String leadStage,
    required String priority,
    required String leadCategory,
  }) async {
    await _logActivity(
      leadId,
      ActivityModel(
        id: '',
        type: ActivityType.leadCreated,
        changedBy: createdByName,
        changedById: createdById,
        changedAt: DateTime.now(),
        previousValue: null,
        newValue: leadStage,
        description:
            'Lead created. Assigned to $assignedTo.'
            '${leadStage.isNotEmpty ? ' Stage: $leadStage.' : ''}'
            '${priority.isNotEmpty ? ' Priority: $priority.' : ''}'
            '${leadCategory.isNotEmpty ? ' Category: $leadCategory.' : ''}',
      ),
    );
  }

  Future<void> logLeadUpdated({
    required String leadId,
    required String changedByName,
    required String changedById,
    required AddLeadModel previous,
    required AddLeadModel updated,
  }) async {
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    final activityRef = _collection.doc(leadId).collection('ACTIVITIES');

    void log(
      ActivityType type,
      String field,
      String prev,
      String next,
      String desc,
    ) {
      if (prev == next || next.isEmpty) return;
      final ref = activityRef.doc();
      batch.set(
       ref,
        ActivityModel(
          id: ref.id,
          type: type,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: prev,
          newValue: next,
          description: desc,
        ).toFirestore(),
      );
    }

    log(
      ActivityType.statusChanged,
      'stage',
      previous.leadStage,
      updated.leadStage,
      'Status changed from ${previous.leadStage} to ${updated.leadStage}.',
    );
    log(
      ActivityType.categoryChanged,
      'category',
      previous.leadCategory,
      updated.leadCategory,
      'Category updated from ${previous.leadCategory} to ${updated.leadCategory}.',
    );
    log(
      ActivityType.priorityChanged,
      'priority',
      previous.priority,
      updated.priority,
      'Priority updated from ${previous.priority} to ${updated.priority}.',
    );
    log(
      ActivityType.staffAssigned,
      'staff',
      previous.assignedStaff,
      updated.assignedStaff,
      'Assigned staff changed from ${previous.assignedStaff} to ${updated.assignedStaff}.',
    );
    // log(ActivityType.costUpdated,     'cost',     previous.cost ?? '',   updated.cost ?? '',   'Cost updated from ${previous.cost} to ${updated.cost}.');
    log(
      ActivityType.remarkUpdated,
      'remarks',
      previous.remarks ?? '',
      updated.remarks ?? '',
      'Remark updated.',
    );

    // Only commit if there's at least one change
    final ops = batch; // batch will be a no-op if nothing was added
    await ops.commit();
  }

  Future<List<LeadStaffHandler>> getLeadHandledStaffs(AddLeadModel lead) async {
    // Collect raw staff entries: {staffId -> staffName}
    // Order matters — insertion order = chronological
    final Map<String, String> staffMap = {};

    // 1. Lead creator is always first
    if (lead.createdById.isNotEmpty) {
      staffMap[lead.createdById] = lead.createdBy ?? '';
    }

    // 2. Assigned staff (may be same as creator — dedup handled by map key)
    if (lead.assignedStaffId.isNotEmpty) {
      staffMap[lead.assignedStaffId] = lead.assignedStaff;
    }

    // 3. All transfer participants (fromStaff and toStaff)
    final transferSnap = await _collection
        .doc(lead.id)
        .collection('TRANSFER_LEADS')
        .orderBy('transferTime')
        .get();

    for (final doc in transferSnap.docs) {
      final data = doc.data();
      final fromId = data['fromStaffId'] as String? ?? '';
      final fromName = data['fromStaff'] as String? ?? '';
      final toId = data['toStaffId'] as String? ?? '';
      final toName = data['toStaff'] as String? ?? '';
      if (fromId.isNotEmpty) staffMap.putIfAbsent(fromId, () => fromName);
      if (toId.isNotEmpty) staffMap.putIfAbsent(toId, () => toName);
    }

    // 4. Count follow-ups per staff (activity count)
    final fupSnap = await _collection
        .doc(lead.id)
        .collection('FOLLOW_UPS')
        .get();

    final Map<String, int> fupCount = {};
    for (final doc in fupSnap.docs) {
      final creatorId = doc.data()['createdById'] as String? ?? '';
      if (creatorId.isNotEmpty) {
        fupCount[creatorId] = (fupCount[creatorId] ?? 0) + 1;
      }
    }

    // 5. Fetch phone numbers from STAFF collection in parallel
    final staffIds = staffMap.keys.toList();
    final phoneMap = <String, String>{};

    await Future.wait(
      staffIds.map((id) async {
        try {
          final doc = await FirestorePath.companyCollection(
            'STAFF',
          ).doc(id).get();
          phoneMap[id] = doc.data()?['phone'] as String? ?? '';
        } catch (_) {
          phoneMap[id] = '';
        }
      }),
    );

    // 6. Build result list — same order as staffMap insertion
    return staffIds.map((id) {
      return LeadStaffHandler(
        staffId: id,
        staffName: staffMap[id] ?? '',
        phone: phoneMap[id] ?? '',
        // +1 for the lead creation itself by the creator
        activityCount: (fupCount[id] ?? 0) + (id == lead.createdById ? 1 : 0),
        isCurrentAssignee: id == lead.assignedStaffId,
      );
    }).toList();
  }

  Future<Map<String, int>> fetchLeadCountsByCategory({
    required String staffId,
    required String role,
    required DateTime selectedDate,
    DateTime? toDate,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (staffId.isNotEmpty) {
      query = query.where(
        'assignedStaffId',
        isEqualTo: staffId,
      ); // ← always filter
    }

    // ── Date filter ──────────────────────────────────────────────────────
    final from = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final to = toDate != null
        ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
        : DateTime(from.year, from.month, from.day, 23, 59, 59);

    query = query
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
    // ─────────────────────────────────────────────────────────────────────

    final snap = await query.get();

    final Map<String, int> counts = {
      'New': 0,
      'Follow Up': 0,
      'Rejected': 0,
      'Closed': 0,
      'Transferred': 0,
    };

    for (final doc in snap.docs) {
      final data = doc.data();
      if(data['isDeleted']==true) continue;
      final stage = (data['leadStage'] ?? '').toString().toUpperCase();

      switch (stage) {
        case 'NEW':
          counts['New'] = (counts['New'] ?? 0) + 1;
          break;
        case 'FOLLOW UP':
        case 'FOLLOWUP':
          counts['Follow Up'] = (counts['Follow Up'] ?? 0) + 1;
          break;
        case 'REJECTED':
          counts['Rejected'] = (counts['Rejected'] ?? 0) + 1;
          break;
        case 'CLOSED':
          counts['Closed'] = (counts['Closed'] ?? 0) + 1;
          break;
        case 'TRANSFERRED':
          counts['Transferred'] = (counts['Transferred'] ?? 0) + 1;
          break;
        default:
          counts['Pending'] = (counts['Pending'] ?? 0) + 1;
          break;
      }
    }

    return counts;
  }

  // In your AddLeadRepository
  Future<List<LeadCategoryTableRow>> fetchLeadCategoryTableRows({
    required String staffId,
    required String role,
    required DateTime selectedDate,
    DateTime? toDate,
  }) async {
    // ← Remove the date filter, fetch all leads for this staff
    Query<Map<String, dynamic>> query = _collection;

    // Always filter by staffId for staff profile view
    if (staffId.isNotEmpty) {
      query = query.where('assignedStaffId', isEqualTo: staffId);
    }

    // ── Date filter ──────────────────────────────────────────────────────
    final from = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final to = toDate != null
        ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
        : DateTime(from.year, from.month, from.day, 23, 59, 59);

    query = query
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
    // ─────────────────────────────────────────────────────────────────────

    final snapshot = await query.get();

    // Group by leadCategory → then count by leadStage
    final Map<String, Map<String, int>> grouped = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if(data['isDeleted']==true) continue;
      final category = (data['leadCategory'] as String? ?? 'Uncategorized')
          .trim()
          .toUpperCase();
      final stage = (data['leadStage'] as String? ?? '').trim().toUpperCase();

      // Use display-friendly category name
      final displayCategory = category.isEmpty ? 'Uncategorized' : category;

      grouped.putIfAbsent(
        displayCategory,
        () => {'NEW': 0, 'FOLLOW UP': 0, 'REJECTED': 0, 'CLOSED': 0},
      );

      if (stage == 'NEW') {
        grouped[displayCategory]!['NEW'] =
            (grouped[displayCategory]!['NEW'] ?? 0) + 1;
      } else if (stage == 'FOLLOW UP' || stage == 'FOLLOWUP') {
        grouped[displayCategory]!['FOLLOW UP'] =
            (grouped[displayCategory]!['FOLLOW UP'] ?? 0) + 1;
      } else if (stage == 'REJECTED') {
        grouped[displayCategory]!['REJECTED'] =
            (grouped[displayCategory]!['REJECTED'] ?? 0) + 1;
      } else if (stage == 'CLOSED') {
        grouped[displayCategory]!['CLOSED'] =
            (grouped[displayCategory]!['CLOSED'] ?? 0) + 1;
      }
    }

    // Sort by total count descending so most active categories appear first
    final rows = grouped.entries
        .map(
          (e) => LeadCategoryTableRow(
            category: e.key,
            newCount: e.value['NEW'] ?? 0,
            followUpCount: e.value['FOLLOW UP'] ?? 0,
            rejectedCount: e.value['REJECTED'] ?? 0,
            closedCount: e.value['CLOSED'] ?? 0,
          ),
        )
        .toList();

    rows.sort((a, b) {
      final totalA =
          a.newCount + a.followUpCount + a.rejectedCount + a.closedCount;
      final totalB =
          b.newCount + b.followUpCount + b.rejectedCount + b.closedCount;
      return totalB.compareTo(totalA);
    });

    return rows;
  }

  static const Map<String, bool> callResultConnectionMap = {
    'connected': true,
    'answered': true,
    'busy': false,
    'not attended': false,
    'notattended': false,
    'out of coverage area': false,
    'outofcoveragearea': false,
    'rejected': false,
    'switched off': false,
    'switchedoff': false,
    'no answer': false,
    'noanswer': false,
  };

  static bool isCallConnected(String status) {
    final normalized = status.toLowerCase().trim();
    if (normalized.isEmpty) return false;
    if (callResultConnectionMap.containsKey(normalized)) {
      return callResultConnectionMap[normalized]!;
    }
    // Fallback: If it contains 'connect' or 'answer', assume connected; otherwise, not connected.
    if (normalized.contains('connect') || normalized.contains('answer')) {
      return true;
    }
    return false;
  }

  Future<Map<String, int>> fetchCallStatusCounts({
    required String staffId,
    required String role,
    DateTime? selectedDate,
    DateTime? toDate,
  }) async {
    Timestamp? fromTs;
    Timestamp? toTs;
    if (selectedDate != null) {
      final from = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final to = toDate != null
          ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
          : DateTime(from.year, from.month, from.day, 23, 59, 59);
      fromTs = Timestamp.fromDate(from);
      toTs = Timestamp.fromDate(to);
    }

    // Query FOLLOW_UPS subcollection across all leads
    Query<Map<String, dynamic>> query = _firestore.collectionGroup(
      'FOLLOW_UPS',
    );


final deletedIdsSnap = await _collection.where('isDeleted', isEqualTo: true).get();
final deletedIds = deletedIdsSnap.docs.map((d) => d.id).toSet();



    if (fromTs != null && toTs != null) {
      query = query
          .where('calledDate', isGreaterThanOrEqualTo: fromTs)
          .where('calledDate', isLessThanOrEqualTo: toTs);
    }

    final snap = await query.get();

    int totalCalled = 0;
    int connected = 0;
    int notConnected = 0;
    final Map<String, int> detailedCounts = {};

    for (final doc in snap.docs) {
      final data = doc.data();
     if (deletedIds.contains(data['leadId'])) continue;
      if (role.toLowerCase() != 'admin') {
        if (data['createdById'] != staffId) {
          continue;
        }
      }
      final calledStatus = (data['calledStatus'] as String? ?? '').trim();

      if (calledStatus.isNotEmpty) {
        // Capitalize first letter of each word to look clean on UI
        final normalized = calledStatus
            .split(RegExp(r'\s+'))
            .map((word) {
              if (word.isEmpty) return '';
              return word[0].toUpperCase() + word.substring(1).toLowerCase();
            })
            .join(' ');

        if (normalized.isNotEmpty) {
          detailedCounts[normalized] = (detailedCounts[normalized] ?? 0) + 1;
        }

        totalCalled++;

        if (isCallConnected(calledStatus)) {
          connected++;
        } else {
          notConnected++;
        }
      }
    }

    return {
      'totalCalled': totalCalled,
      'connected': connected,
      'notConnected': notConnected,
      ...detailedCounts,
    };
  }

  Future<AddLeadModel> getLeadById(String leadId) async {
    try {
      final leadDoc = await _collection.doc(leadId).get();

      if (!leadDoc.exists) {
        throw Exception('Lead not found');
      }

      final followUpSnap = await _collection
          .doc(leadId)
          .collection('FOLLOW_UPS')
          .orderBy('createdAt', descending: true)
          .get();

      final followUps = followUpSnap.docs
          .map((e) => FollowUpModel.fromFirestore(e.data(), e.id))
          .toList();

      final lead = AddLeadModel.fromFirestore(leadDoc.data()!, leadDoc.id);

      return lead.copyWith(followUp: followUps);
    } catch (e) {
      throw Exception('Failed to fetch lead: $e');
    }
  }

  // Future<void> deleteFollowUp({
  //   required String leadId,
  //   required String followUpId,
  // }) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('LEADS')
  //         .doc(leadId)
  //         .collection('FOLLOW_UPS')
  //         .doc(followUpId)
  //         .delete();
  //   } catch (e) {
  //     throw Exception('Failed to delete follow-up: $e');
  //   }
  // }

  Future<void> deleteFollowUp({
    required String leadId,
    required String followUpId,
    required String changedByName,
    required String changedById,
    required String leadName,
    required String leadPhone,
  }) async {
    final leadRef = _collection.doc(leadId);

    final activityRef = leadRef.collection('ACTIVITIES');

    // Read followup BEFORE deleting
    final deletedDoc = await leadRef
        .collection('FOLLOW_UPS')
        .doc(followUpId)
        .get();

    if (!deletedDoc.exists) {
      throw Exception('Follow-up not found');
    }

    final deletedFollowup = FollowUpModel.fromFirestore(
      deletedDoc.data()!,
      deletedDoc.id,
    );

    // Delete followup
    await deletedDoc.reference.delete();

    // Find the next latest followup
    final remaining = await leadRef
        .collection('FOLLOW_UPS')
        .orderBy('calledDate', descending: true)
        .limit(1)
        .get();

    if (remaining.docs.isNotEmpty) {
      final latest = FollowUpModel.fromFirestore(
        remaining.docs.first.data(),
        remaining.docs.first.id,
      );

      await leadRef.update({
        'leadStage': latest.leadStage,
        'leadStageId':latest.leadStageId,
        'priority': latest.priority,
        'leadCategory': latest.leadCategory,
        'leadCategoryId':latest.leadCategoryId,
        'leadSubCategory':latest.leadSubCategory,
        'leadSubCategoryId':latest.leadSubCategoryId,
        'followUpDate': latest.nextFollowUpDate,
        'calledDate': latest.calledDate,
        'callResult': latest.calledStatus,
        'remarks': latest.remarks,
      });
    }

    // Log activity
    final activityDoc = activityRef.doc();
    await activityRef.add(
      ActivityModel(
        id: activityDoc.id,
        type: ActivityType.followupDeleted,
        changedBy: changedByName,
        changedById: changedById,
        changedAt: DateTime.now(),
        leadId: leadId,
        leadName: leadName,
        leadPhone: leadPhone,
        previousValue: deletedFollowup.calledStatus,
        newValue: '',
        description:
            'Deleted follow-up. Status: ${deletedFollowup.leadStage}, '
            'Call Result: ${deletedFollowup.calledStatus}, '
            'Scheduled Date: ${DateFormat('dd-MM-yyyy HH:mm').format(deletedFollowup.nextFollowUpDate)}',
      ).toFirestore(),
    );
  }

  @override
  Future<bool> isContactNumberExists(String contactNumber) async {
    final snap = await _collection
        .where('contactNumber', isEqualTo: contactNumber.trim())
        .limit(1)
        .get();
    // return snap.docs.isNotEmpty;
    return snap.docs.any((d) => (d.data()['isDeleted'] ?? false) != true);
  }

  @override
  Future<bool> isWhatsappNumberExists(String whatsappNumber) async {
    if (whatsappNumber.trim().isEmpty) return false;
    final snap = await _collection
        .where('whatsappNumber', isEqualTo: whatsappNumber.trim())
        .limit(1)
        .get();
    // return snap.docs.isNotEmpty;
     return snap.docs.any((d) => (d.data()['isDeleted'] ?? false) != true);
  }

  @override
  Future<bool> isContactNumberExistsForOther(
    String contactNumber,
    String currentLeadId,
  ) async {
    if (contactNumber.trim().isEmpty) return false;
    final snap = await _collection
        .where('contactNumber', isEqualTo: contactNumber.trim())
        .get();
    // return snap.docs.any((doc) => doc.id != currentLeadId);
     return snap.docs.any((doc) =>
      doc.id != currentLeadId && (doc.data()['isDeleted'] ?? false) != true);
  }

  @override
  Future<bool> isWhatsappNumberExistsForOther(
    String whatsappNumber,
    String currentLeadId,
  ) async {
    if (whatsappNumber.trim().isEmpty) return false;
    final snap = await _collection
        .where('whatsappNumber', isEqualTo: whatsappNumber.trim())
        .get();
    // return snap.docs.any((doc) => doc.id != currentLeadId);
     return snap.docs.any((doc) =>
      doc.id != currentLeadId && (doc.data()['isDeleted'] ?? false) != true);
  }

  @override
  Future<List<ActivityModel>> fetchRecentActivities({
    required String staffId,
    required String role,
    int limit = 5,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection;
      if (role.toLowerCase() != 'admin') {
        query = query.where('assignedStaffId', isEqualTo: staffId);
      }
      final snap = await query.get();

      final List<AddLeadModel> leads = snap.docs
          .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
          .toList();
      
      final activeLeads = leads.where((lead) => !lead.isDeleted).toList();

      if (activeLeads.isEmpty) {
        return [];
      }

      DateTime getLatestTime(AddLeadModel lead) {
        DateTime latest = lead.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (lead.calledDate != null && lead.calledDate!.isAfter(latest)) {
          latest = lead.calledDate!;
        }
        if (lead.updatedAt != null && lead.updatedAt!.isAfter(latest)) {
          latest = lead.updatedAt!;
        }
        return latest;
      }
      // sort leads by latest activity time
      activeLeads.sort((a, b) => getLatestTime(b).compareTo(getLatestTime(a)));

      final List<ActivityModel> allActivities = [];
      final topLeads = activeLeads.take(10).toList();

      final activityFutures = topLeads.map((lead) async {
        try {
          final activitySnap = await _collection
              .doc(lead.id)
              .collection('ACTIVITIES')
              .orderBy('changedAt', descending: true)
              .limit(limit)
              .get();

          return activitySnap.docs.map((d) {
            final data = d.data();
            final act = ActivityModel.fromFirestore(data, d.id);
            return ActivityModel(
              id: act.id,
              type: act.type,
              changedBy: act.changedBy,
              changedById: act.changedById,
              changedAt: act.changedAt,
              previousValue: act.previousValue,
              newValue: act.newValue,
              description: act.description,
              leadId: lead.id,
              leadName: lead.clientName,
              leadPhone: lead.contactNumber,
            );
          }).toList();
        } catch (e) {
          log('Error fetching activities for lead ${lead.id}: $e');
          return <ActivityModel>[];
        }
      });

      final results = await Future.wait(activityFutures);
      for (final acts in results) {
        allActivities.addAll(acts);
      }

      allActivities.sort((a, b) => b.changedAt.compareTo(a.changedAt));
      return allActivities.take(limit).toList();
    } catch (e) {
      log('Error in fetchRecentActivities: $e');
      return [];
    }
  }
  //  ---------------------------------------------------------------------

  Future<void> _commitBatchOps(List<_ArchiveOp> ops, {int chunkSize = 450}) async {
  for (var i = 0; i < ops.length; i += chunkSize) {
    final end = (i + chunkSize > ops.length) ? ops.length : i + chunkSize;
    final batch = _firestore.batch();
    for (var j = i; j < end; j++) {
      final op = ops[j];
      if (op.type == _ArchiveOpType.set) {
        batch.set(op.ref, op.data!);
      } else {
        batch.delete(op.ref);
      }
    }
    await batch.commit();
  }
}

@override
Future<void> softDeleteLead(String leadId) async {
  if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
  await _collection.doc(leadId).update({
    'isDeleted': true,
    'deletedAt': FieldValue.serverTimestamp(),
  });
  log('[AddLeadRepository] Lead soft-deleted: $leadId');
}

@override
Future<void> restoreLead(String leadId) async {
  if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
  await _collection.doc(leadId).update({
    'isDeleted': false,
    'deletedAt': null,
  });
  log('[AddLeadRepository] Lead restored: $leadId');
}

@override
Future<void> archiveDeletedLead(String leadId) async {
  if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

  final leadRef = _collection.doc(leadId);
  final archiveRef = _deletedCollection.doc(leadId); // same doc ID, preserved

  final leadSnap = await leadRef.get();
  if (!leadSnap.exists) {
    throw Exception('Lead not found. It may already be archived or removed.');
  }
  final leadData = Map<String, dynamic>.from(leadSnap.data()!);

  const subcollections = ['FOLLOW_UPS', 'ACTIVITIES', 'TRANSFER_LEADS'];

  final writeOps = <_ArchiveOp>[_ArchiveOp.set(archiveRef, leadData)];
  final deleteOps = <_ArchiveOp>[];

  for (final sub in subcollections) {
    final subSnap = await leadRef.collection(sub).get();
    for (final doc in subSnap.docs) {
      writeOps.add(
        _ArchiveOp.set(archiveRef.collection(sub).doc(doc.id), doc.data()),
      );
      deleteOps.add(_ArchiveOp.delete(leadRef.collection(sub).doc(doc.id)));
    }
  }

  // Copy everything FIRST. Only if every archive write succeeds do we
  // touch the original — a failure here leaves LEADS completely intact.
  await _commitBatchOps(writeOps);

  deleteOps.add(_ArchiveOp.delete(leadRef)); // delete parent doc last
  await _commitBatchOps(deleteOps);

  log('[AddLeadRepository] Lead archived + removed from LEADS: $leadId');
}

@override
Future<void> permanentlyDeleteArchivedLead(String leadId) async {
  // Purges an already-archived DELETED_LEADS/{id} doc and its subcollections.
  // Not currently wired to any button — available if you later want a
  // separate "empty the archive" admin action.
  if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

  final archiveRef = _deletedCollection.doc(leadId);
  const subcollections = ['FOLLOW_UPS', 'ACTIVITIES', 'TRANSFER_LEADS'];

  final deleteOps = <_ArchiveOp>[];
  for (final sub in subcollections) {
    final subSnap = await archiveRef.collection(sub).get();
    for (final doc in subSnap.docs) {
      deleteOps.add(_ArchiveOp.delete(archiveRef.collection(sub).doc(doc.id)));
    }
  }
  deleteOps.add(_ArchiveOp.delete(archiveRef));

  await _commitBatchOps(deleteOps);
  log('[AddLeadRepository] Archived lead purged permanently: $leadId');
}


@override
Future<List<AddLeadModel>> fetchDeletedLeads() async {
  final snap = await _collection
      .where('isDeleted', isEqualTo: true)
      .orderBy('deletedAt', descending: true)
      .get();
  return snap.docs
      .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
      .toList();
}

// ─── One-time migration: backfill missing `id` field ─────────────────────

/// Adds the `id` field to every LEADS / DELETED_LEADS document, and to
/// every FOLLOW_UPS / TRANSFER_LEADS / ACTIVITIES subcollection document,
/// for records created before `toFirestore()` started writing `id`.
///
/// Idempotent — docs whose `id` already matches `doc.id` are skipped,
/// so it's safe to re-run.
Future<void> migrateMissingLeadIds() async {
  await _backfillCollectionIds(_collection, label: 'LEADS');
  await _backfillCollectionIds(_deletedCollection, label: 'DELETED_LEADS');

  await _backfillCollectionGroupIds('FOLLOW_UPS');
  await _backfillCollectionGroupIds('TRANSFER_LEADS');
  await _backfillCollectionGroupIds('ACTIVITIES');
}

Future<void> _backfillCollectionIds(
  CollectionReference<Map<String, dynamic>> collection, {
  required String label,
}) async {
  final snap = await collection.get();
  await _backfillDocs(snap.docs, label: label);
}

Future<void> _backfillCollectionGroupIds(String collectionGroupName) async {
  final snap = await _firestore.collectionGroup(collectionGroupName).get();
  await _backfillDocs(snap.docs, label: collectionGroupName);
}

Future<void> _backfillDocs(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
  required String label,
}) async {
  final toFix = docs.where((doc) {
    final existingId = doc.data()['id'] as String?;
    return existingId == null || existingId != doc.id;
  }).toList();

  if (toFix.isEmpty) {
    log('[AddLeadRepository] migrateMissingLeadIds: $label already up to date '
        '(${docs.length} docs checked)');
    return;
  }

  const chunkSize = 450;
  for (var i = 0; i < toFix.length; i += chunkSize) {
    final end = (i + chunkSize > toFix.length) ? toFix.length : i + chunkSize;
    final chunk = toFix.sublist(i, end);

    final batch = _firestore.batch();
    for (final doc in chunk) {
      batch.update(doc.reference, {'id': doc.id});
    }
    await batch.commit();

    log('[AddLeadRepository] migrateMissingLeadIds: $label batch '
        '${(i ~/ chunkSize) + 1} — ${chunk.length} docs updated');
  }

  log('[AddLeadRepository] migrateMissingLeadIds: $label done — '
      '${toFix.length}/${docs.length} docs backfilled');
}
 
}
