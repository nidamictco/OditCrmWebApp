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
  Future<List<AddLeadModel>> fetchDeletedLeads();
  Future<String> restoreLead(AddLeadModel lead);
  Future<void> permanentlyDeleteLead(String id);
  Future<void> assignStaff(String leadId, String staffId, String staffName);
  Future<AddLeadModel> getLeadById(String leadId);
  Future<void> deleteFOLLOW-UP({
    required String leadId,
    required String FOLLOW-UPId,
    required String changedByName,
    required String changedById,
    required String leadName,
    required String leadPhone,
  });
  Future<void> addFOLLOW-UP(
    String leadId,
    FOLLOW-UPModel FOLLOW-UP, {
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
        now.millisecondsSinceEpoch % 1000; // last 3 digits for uniqueness
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
      /// FETCH LEADS + FOLLOW-UPS
      final List<AddLeadModel> allLeads = await Future.wait(
        snap.docs.map((leadDoc) async {
          /// MAIN LEAD
          final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

          /// FETCH FOLLOW-UP SUBCOLLECTION
          final FOLLOW-UPSnap = await _collection
              .doc(leadDoc.id)
              .collection('FOLLOW_UPS')
              .orderBy('createdAt', descending: true)
              .get();

          /// CONVERT FOLLOW-UPS
          final FOLLOW-UPs = FOLLOW-UPSnap.docs.map((fupDoc) {
            return FOLLOW-UPModel.fromFirestore(fupDoc.data(), fupDoc.id);
          }).toList();

          /// RETURN LEAD WITH FOLLOW-UPS
          return lead.copyWith(FOLLOW-UP: FOLLOW-UPs);
        }),
      );
      return allLeads;
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
          return allLeads.where((lead) {
            return isSameDay(lead.createdAt);
          }).toList();

        /// FOLLOW-UP LEADS
        case 'FOLLOW-UP':
          return allLeads.where((lead) {
            return isSameDay(lead.FOLLOW-UPDate);
          }).toList();

        /// CLOSED LEADS
        case 'CLOSED':
          return allLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'CLOSED';
          }).toList();

        /// TOTAL CALLED
        case 'TOTAL':
          return allLeads.where((lead) {
            return isSameDay(lead.calledDate);
          }).toList();

        /// MISSED / REJECTED
        case 'MISSED':
          return allLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'REJECTED';
          }).toList();

        /// TRANSFERRED LEADS
        case 'TRANSFERRED':
          return allLeads.where((lead) {
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
          return allLeads;
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

      /// FETCH LEADS + FOLLOW-UPS
      final List<AddLeadModel> allLeads = await Future.wait(
        snap.docs.map((leadDoc) async {
          /// MAIN LEAD
          final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

          /// FETCH FOLLOW-UP SUBCOLLECTION
          final FOLLOW-UPSnap = await _collection
              .doc(leadDoc.id)
              .collection('FOLLOW_UPS')
              .orderBy('createdAt', descending: true)
              .get();

          /// CONVERT FOLLOW-UPS
          final FOLLOW-UPs = FOLLOW-UPSnap.docs.map((fupDoc) {
            return FOLLOW-UPModel.fromFirestore(fupDoc.data(), fupDoc.id);
          }).toList();

          /// RETURN LEAD WITH FOLLOW-UPS
          return lead.copyWith(FOLLOW-UP: FOLLOW-UPs);
        }),
      );

      /// DATE FILTER HELPER
      // bool isSameDay(DateTime? date) {
      //   if (date == null) return false;

      //   return date.year == selectedDate.year &&
      //       date.month == selectedDate.month &&
      //       date.day == selectedDate.day;
      // }

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
          return allLeads.where((lead) {
            return isInRange(lead.createdAt) &&
                lead.leadStage.toUpperCase() == 'NEW' &&
                // lead.FOLLOW-UP!.isEmpty;
                (lead.FOLLOW-UP == null || lead.FOLLOW-UP!.isEmpty);
          }).toList();

        /// FOLLOW-UP LEADS
        case 'FOLLOW-UP':
          return allLeads.where((lead) {
            return isInRange(lead.FOLLOW-UPDate) &&
                lead.leadStage.toUpperCase() == 'FOLLOW-UP'; // &&
            // lead.leadStage.toUpperCase() != 'CLOSED'&&
            // lead.leadStage.toUpperCase() != 'REJECTED'&& ;
          }).toList();

        /// CLOSED LEADS
        case 'CLOSED':
          return allLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'CLOSED' &&
                isInRange(lead.calledDate);
          }).toList();

        /// TOTAL CALLED
        case 'TOTAL':
          final List<AddLeadModel> result = [];
          for (final lead in allLeads) {
            final matchingFOLLOW-UPs =
                lead.FOLLOW-UP?.where((fup) {
                  final inRange = isInRange(fup.calledDate);
                  if (role.toLowerCase() != 'admin') {
                    return inRange && fup.createdById == staffId;
                  }
                  return inRange;
                }).toList() ??
                [];
            if (matchingFOLLOW-UPs.isNotEmpty) {
              for (final fup in matchingFOLLOW-UPs) {
                result.add(
                  lead.copyWith(
                    calledDate: fup.calledDate,
                    leadStage: fup.leadStage,
                    leadCategory: fup.leadCategory,
                    priority: fup.priority,
                    FOLLOW-UPDate: fup.nextFOLLOW-UPDate,
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
          return allLeads.where((lead) {
            if (lead.leadStage.toUpperCase() == 'NEW') {
              if (lead.createdAt == null) return false;
              return isbeforeFromDay(lead.createdAt);
            }
            if (lead.leadStage.toUpperCase() == 'FOLLOW-UP' ||
                lead.leadStage.toUpperCase() == 'TRANSFERRED') {
              if (lead.FOLLOW-UPDate == null) return false;
              return isbeforeFromDay(lead.FOLLOW-UPDate);
            }
            return false;
            // return (lead.leadStage.toUpperCase() == 'NEW' &&
            //         isbeforeFromDay(lead.createdAt)) ||
            // (lead.leadStage.toUpperCase() == 'FOLLOW-UP' ||
            //         // lead.leadStage.toUpperCase() == 'NEW' ||
            //         lead.leadStage.toUpperCase() == 'TRANSFERRED') &&
            //     isbeforeFromDay(lead.FOLLOW-UPDate);
          }).toList();

        /// TRANSFERRED
        case 'TRANSFERRED':
          return allLeads.where((lead) {
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
          return allLeads;
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

  @override
  Future<String> restoreLead(AddLeadModel lead) async {
    if (lead.clientName.trim().isEmpty) {
      throw ArgumentError('Client name cannot be empty.');
    }
    if (lead.contactNumber.trim().isEmpty) {
      throw ArgumentError('Contact number cannot be empty.');
    }
    final doc = await _collection.add(lead.toFirestore());
    await _deletedCollection.doc(lead.id).delete();
    return doc.id;
  }

  @override
  Future<List<AddLeadModel>> fetchDeletedLeads() async {
    final snap = await _deletedCollection
        .orderBy('deletedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
        .toList();
  }

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
  Future<void> addFOLLOW-UPOld(String leadId, FOLLOW-UPModel FOLLOW-UP) async {
    if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

    final String FOLLOW-UPId = _generateDateId('FUP');
    await _collection
        .doc(leadId)
        .collection('FOLLOW_UPS')
        .doc(FOLLOW-UPId)
        .set(FOLLOW-UP.toFirestore());

    await _collection.doc(leadId).update({
      'leadStage': FOLLOW-UP.leadStage,
      'priority': FOLLOW-UP.priority,
      'leadCategory': FOLLOW-UP.leadCategory,
      'nextFOLLOW-UPDate': FOLLOW-UP.nextFOLLOW-UPDate,
      'lastCalledDate': FOLLOW-UP.calledDate,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    log('[AddLeadRepository] FOLLOW-UP added for lead: $leadId');
  }

  @override
  Future<void> addFOLLOW-UP(
    String leadId,
    FOLLOW-UPModel FOLLOW-UP, {
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
    final String FOLLOW-UPId = FOLLOW-UP.id ?? _generateDateId('FUP');
    final fupRef = _collection
        .doc(leadId)
        .collection('FOLLOW_UPS')
        .doc(FOLLOW-UPId);
    batch.set(fupRef, FOLLOW-UP.toFirestore(), SetOptions(merge: true));

    // 2. Update lead document
    final leadRef = _collection.doc(leadId);
    // batch.update(leadRef, {
    //   'leadStage': FOLLOW-UP.leadStage,
    //   'priority': FOLLOW-UP.priority,
    //   'leadCategory': FOLLOW-UP.leadCategory,
    //   'nextFOLLOW-UPDate': FOLLOW-UP.nextFOLLOW-UPDate,
    //   'lastCalledDate': FOLLOW-UP.calledDate,
    //   'callResult': FOLLOW-UP.calledStatus,
    //   'leadTag': FOLLOW-UP.leadTag,
    //   'updatedAt': FieldValue.serverTimestamp(),
    //   // 'remarks' : FOLLOW-UP.remarks,
    // });
    final Map<String, dynamic> leadUpdates = {
      'leadStage': FOLLOW-UP.leadStage,
      'priority': FOLLOW-UP.priority,
      'leadCategory': FOLLOW-UP.leadCategory,
      'nextFOLLOW-UPDate': FOLLOW-UP.nextFOLLOW-UPDate,
      'lastCalledDate': FOLLOW-UP.calledDate,
      'callResult': FOLLOW-UP.calledStatus,
      'leadTag': FOLLOW-UP.leadTag,
      'updatedAt': FieldValue.serverTimestamp(),
      'hasFOLLOW-UP': true,
    };
    if ((FOLLOW-UP.adress ?? '').isNotEmpty) {
      leadUpdates['address'] = FOLLOW-UP.adress;
    }
    if ((FOLLOW-UP.email ?? '').isNotEmpty) {
      leadUpdates['email'] = FOLLOW-UP.email;
    }
    if ((FOLLOW-UP.remarks ?? '').isNotEmpty) {
      leadUpdates['remarks'] = FOLLOW-UP.remarks;
    }
    batch.update(leadRef, leadUpdates);

    final now = DateTime.now();

    // Helper to add an activity doc in the batch
    void logActivity(ActivityModel activity) {
      batch.set(activityRef.doc(), activity.toFirestore());
    }

    // 3. Always log the follow-up added activity
    logActivity(
      ActivityModel(
        id: '',
        type: ActivityType.FOLLOW-UPAdded,
        changedBy: changedByName,
        changedById: changedById,
        changedAt: now,
        previousValue: FOLLOW-UP.calledStatus,
        leadId: leadId, // ← add
        leadName: leadName, // ← add
        leadPhone: leadPhone, // ← add
        newValue: DateFormat(
          'dd-MM-yyyy HH:mm',
        ).format(FOLLOW-UP.nextFOLLOW-UPDate),
        description:
            'Follow-up added. Call status: ${FOLLOW-UP.calledStatus}. '
            'Next follow-up scheduled to '
            '${DateFormat('dd-MM-yyyy HH:mm').format(FOLLOW-UP.nextFOLLOW-UPDate)}.',
      ),
    );

    // 4. Log status change only if it actually changed
    if (previousStage != null &&
        previousStage.isNotEmpty &&
        previousStage != FOLLOW-UP.leadStage) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.statusChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousStage,
          newValue: FOLLOW-UP.leadStage,
          description:
              'Status changed from $previousStage to ${FOLLOW-UP.leadStage}.',
        ),
      );
    }

    // 5. Log category change only if it changed
    if (previousCategory != null &&
        previousCategory.isNotEmpty &&
        previousCategory != FOLLOW-UP.leadCategory &&
        FOLLOW-UP.leadCategory.isNotEmpty) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.categoryChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousCategory,
          newValue: FOLLOW-UP.leadCategory,
          description:
              'Lead category updated from $previousCategory to ${FOLLOW-UP.leadCategory}.',
        ),
      );
    }

    // 6. Log priority change only if it changed
    if (previousPriority != null &&
        previousPriority.isNotEmpty &&
        previousPriority != FOLLOW-UP.priority &&
        FOLLOW-UP.priority.isNotEmpty) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.priorityChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousPriority,
          newValue: FOLLOW-UP.priority,
          description:
              'Priority updated from $previousPriority to ${FOLLOW-UP.priority}.',
        ),
      );
    }

    await batch.commit();
    log('[AddLeadRepository] FOLLOW-UP + activities written for lead: $leadId');
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

    // 1. Add to TRANSFER_LEADS subcollection
    final transferRef = _collection
        .doc(leadId)
        .collection('TRANSFER_LEADS')
        .doc(transferId);
    batch.set(transferRef, transfer.toFirestore());

    // 2. Update the lead document
    final leadRef = _collection.doc(leadId);
    batch.update(leadRef, {
      'assignedStaff': transfer.toStaff,
      'assignedStaffId': transfer.toStaffId,
      'leadStage': 'TRANSFERRED',
      'transferLeads': FieldValue.arrayUnion([transfer.toFirestore()]),
    });

    // 3. Log the transfer activity
    final activityRef = _collection.doc(leadId).collection('ACTIVITIES').doc();
    batch.set(
      activityRef,
      ActivityModel(
        id: '',
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

  //   @override
  //   Future<DashboardCountModel> fetchLeadCounts({
  //     required String staffId,
  //     required DateTime selectedDate,
  //     required String role,
  //     bool forceStaffFilter = false, // ← new flag
  //   }) async {
  //     final startOfDay = DateTime(
  //       selectedDate.year,
  //       selectedDate.month,
  //       selectedDate.day,
  //     );
  //     final endOfDay = DateTime(
  //       selectedDate.year,
  //       selectedDate.month,
  //       selectedDate.day,
  //       23,
  //       59,
  //       59,
  //     );

  //     // If forceStaffFilter=true (staff profile screen), ALWAYS filter by staffId
  //     // regardless of role. Otherwise use the original admin/staff logic.
  //     Query<Map<String, dynamic>> query = _collection;
  //     if (forceStaffFilter && staffId.isNotEmpty) {
  //       query = query.where('assignedStaffId', isEqualTo: staffId);
  //       log(
  //         '[fetchLeadCounts] Staff profile mode: filtering by staffId=$staffId',
  //       );
  //     } else if (role.toLowerCase() != 'admin') {
  //       query = query.where('assignedStaffId', isEqualTo: staffId);
  //       log('[fetchLeadCounts] Staff mode: filtering by staffId=$staffId');
  //     } else {
  //       log('[fetchLeadCounts] Admin dashboard mode: fetching all leads');
  //     }

  //     final snap = await query.get();
  //     log('[fetchLeadCounts] Total docs fetched: ${snap.docs.length}');

  //     int newLeadCount = 0;
  //     int FOLLOW-UPCount = 0;
  //     int closedLeadCount = 0;
  //     int totalCalledCount = 0;
  //     int missedLeadCount = 0;
  //     int transferredCount = 0;

  //     for (final doc in snap.docs) {
  //       final data = doc.data();
  //       final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();
  //       final FOLLOW-UPs =
  //           (await doc.reference.collection('FOLLOW_UPS').get()).docs;

  //       // NEW
  //       final createdAt = data['createdAt'];
  //       if (createdAt != null) {
  //         final createdDate = (createdAt as Timestamp).toDate();
  //         // if (_isSameDay(createdDate, selectedDate) &&
  //         //     leadStage == 'NEW' &&
  //         //     FOLLOW-UPs.isEmpty) {
  //         //   newLeadCount++;
  //         // }
  // //         if (leadStage == 'NEW' && createdDate != null && _isSameDay(createdDate, selectedDate)) {
  // //   // only fetch follow-ups when the lead is actually a candidate
  // //   final FOLLOW-UPs = (await doc.reference.collection('FOLLOW_UPS').get()).docs;
  // //   if (FOLLOW-UPs.isEmpty) newLeadCount++;
  // // }
  // final hasFOLLOW-UP = data['hasFOLLOW-UP'] as bool? ?? false;
  // if (leadStage == 'NEW' && _isSameDay(createdDate, selectedDate)) {
  //   if (!hasFOLLOW-UP) newLeadCount++;
  // }
  //       }

  //       // FOLLOW-UP
  //       final nextFOLLOW-UPDate = data['nextFOLLOW-UPDate'];
  //       if (nextFOLLOW-UPDate != null) {
  //         final followDate = (nextFOLLOW-UPDate as Timestamp).toDate();
  //         if (_isSameDay(followDate, selectedDate) &&
  //             leadStage != 'CLOSED' &&
  //             leadStage != 'REJECTED' &&
  //             leadStage != 'NEW') {
  //           FOLLOW-UPCount++;
  //         }
  //       }

  //       // final calledDate = data['lastCalledDate'] ;
  //       // CLOSED
  //       final lastCalledDate = data['lastCalledDate'];
  //       if (lastCalledDate != null) {
  //         final calledDate = (lastCalledDate as Timestamp).toDate();
  //         if (leadStage == 'CLOSED' && _isSameDay(calledDate, selectedDate)) {
  //           closedLeadCount++;
  //         }
  //       } else {
  //         if (createdAt != null) {
  //           final createdDate = (createdAt as Timestamp).toDate();
  //           if (leadStage == 'CLOSED' && _isSameDay(createdDate, selectedDate)) {
  //             closedLeadCount++;
  //           }
  //         }
  //       }
  //       //&& _isSameDay(calledDate, selectedDate)) closedLeadCount++;

  //       // MISSED / REJECTED
  //       if (nextFOLLOW-UPDate != null) {
  //         final followDate = (nextFOLLOW-UPDate as Timestamp).toDate();
  //         if ((leadStage == 'FOLLOW-UP' || leadStage == 'NEW') &&
  //             _isBeforeDay(followDate, selectedDate)) {
  //           missedLeadCount++;
  //         }
  //       }

  //       // TOTAL CALLED
  //       // final lastCalledDate = data['lastCalledDate'];
  //       if (lastCalledDate != null) {
  //         final calledDate = (lastCalledDate as Timestamp).toDate();
  //         if (_isSameDay(calledDate, selectedDate)) totalCalledCount++;
  //       }

  //       // TRANSFERRED
  //       final transferredList = data['transferLeads'];
  //       if (transferredList != null && transferredList is List) {
  //         bool alreadyCounted = false;
  //         for (final item in transferredList) {
  //           if (item is Map<String, dynamic>) {
  //             final transferredTime = item['transferTime'];
  //             if (transferredTime != null) {
  //               final transferDate = (transferredTime as Timestamp).toDate();
  //               if (_isSameDay(transferDate, selectedDate) && !alreadyCounted) {
  //                 transferredCount++;
  //                 alreadyCounted = true;
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }

  //     log(
  //       '[fetchLeadCounts] Results — new:$newLeadCount FOLLOW-UP:$FOLLOW-UPCount '
  //       'closed:$closedLeadCount total:$totalCalledCount missed:$missedLeadCount '
  //       'transferred:$transferredCount',
  //     );

  //     return DashboardCountModel(
  //       newLeadCount: newLeadCount,
  //       FOLLOW-UPCount: FOLLOW-UPCount,
  //       closedLeadCount: closedLeadCount,
  //       totalCalledCount: totalCalledCount,
  //       missedLeadCount: missedLeadCount,
  //       transferredCount: transferredCount,
  //     );
  //   }
  @override
  Future<DashboardCountModel> fetchLeadCounts({
    required String staffId,
    DateTime? selectedDate,
    required String role,
    bool forceStaffFilter = false,
  }) async {
    final sw = Stopwatch()..start();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final startOfDay = selectedDate != null
        ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        : null;
    final endOfDay = selectedDate != null
        ? DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            23,
            59,
            59,
          )
        : DateTime(now.year, now.month, now.day, 23, 59, 59);

    // ── Single query, no composite index needed ──────────────────────────────
    Query<Map<String, dynamic>> base = _collection;
    if (forceStaffFilter && staffId.isNotEmpty) {
      base = base.where('assignedStaffId', isEqualTo: staffId);
    } else if (role.toLowerCase() != 'admin') {
      base = base.where('assignedStaffId', isEqualTo: staffId);
    }

    // ONE round-trip to Firestore — no subcollection reads at all
    final snap = await base.get();
    log('[fetchLeadCounts...............] docs: ${snap.docs.length}');

    final activeLeadIds = snap.docs.map((doc) => doc.id).toSet();
    int newLeadCount = 0;
    int FOLLOW-UPCount = 0;
    int closedLeadCount = 0;
    // int totalCalledCount = await getTotalCalledCount(
    //   startOfDay,
    //   endOfDay,
    //   staffId,
    //   role,
    // );
    int totalCalledCount = await findTotalCalledCount(
      staffId,
      role,
      selectedDate,
      endOfDay,
    );
    int missedLeadCount = 0;
    int transferredCount = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();

      // ── NEW ────────────────────────────────────────────────────────────
      if (leadStage == 'NEW') {
        final createdAt = data['createdAt'];
        if (createdAt != null) {
          final createdDate = (createdAt as Timestamp).toDate();
          final inRange = selectedDate != null
              ? _isInRange(createdDate, startOfDay!, endOfDay)
              : !createdDate.isAfter(endOfDay);
          if (inRange) {
            final hasFOLLOW-UP = data['hasFOLLOW-UP'] as bool? ?? false;
            if (!hasFOLLOW-UP) newLeadCount++;
          }
        }
      }

      // ── FOLLOW-UP ───────────────────────────────────────────────────────
      if (leadStage == 'FOLLOW-UP') {
        final nextFOLLOW-UPDate = data['nextFOLLOW-UPDate'];
        if (nextFOLLOW-UPDate != null) {
          final followDate = (nextFOLLOW-UPDate as Timestamp).toDate();
          final inRange = selectedDate != null
              ? _isInRange(followDate, startOfDay!, endOfDay)
              : !followDate.isAfter(endOfDay);
          if (inRange) FOLLOW-UPCount++;
        }
      }

      // ── CLOSED ─────────────────────────────────────────────────────────
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

      // ── TOTAL CALLED ───────────────────────────────────────────────────
      // Handled outside the loop above to avoid N+1 queries.

      // ── MISSED ─────────────────────────────────────────────────────────
      if (leadStage == 'NEW') {
        final createdAt = data['createdAt'];
        if (createdAt != null) {
          final createdDate = (createdAt as Timestamp).toDate();
          final baseline = selectedDate != null ? startOfDay! : todayStart;
          if (_isBeforeDay(createdDate, baseline)) {
            missedLeadCount++;
          }
        }
      }
      if (leadStage == 'FOLLOW-UP') {
        final nextFOLLOW-UPDate = data['nextFOLLOW-UPDate'];
        if (nextFOLLOW-UPDate != null) {
          final followDate = (nextFOLLOW-UPDate as Timestamp).toDate();
          final baseline = selectedDate != null ? startOfDay! : todayStart;
          if (_isBeforeDay(followDate, baseline)) {
            missedLeadCount++;
          }
        }
      }
      if (leadStage == 'TRANSFERRED') {
        final nextFOLLOW-UPDate = data['nextFOLLOW-UPDate'];
        if (nextFOLLOW-UPDate != null) {
          final followDate = (nextFOLLOW-UPDate as Timestamp).toDate();
          final baseline = selectedDate != null ? startOfDay! : todayStart;
          if (_isBeforeDay(followDate, baseline)) {
            missedLeadCount++;
          }
        }
      }

      // if (leadStage == 'FOLLOW-UP' || leadStage == 'NEW') {
      //   final nextFOLLOW-UPDate = data['nextFOLLOW-UPDate'];
      //   if (nextFOLLOW-UPDate != null) {
      //     final followDate = (nextFOLLOW-UPDate as Timestamp).toDate();
      //     final baseline = selectedDate != null ? startOfDay! : todayStart;
      //     if (_isBeforeDay(followDate, baseline)) missedLeadCount++;
      //   }
      // }

      // ── TRANSFERRED ────────────────────────────────────────────────────
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
      '[fetchLeadCounts] new:$newLeadCount FOLLOW-UP:$FOLLOW-UPCount '
      'closed:$closedLeadCount total:$totalCalledCount '
      'missed:$missedLeadCount transferred:$transferredCount '
      '— ${sw.elapsedMilliseconds}ms',
    );

    return DashboardCountModel(
      newLeadCount: newLeadCount,
      FOLLOW-UPCount: FOLLOW-UPCount,
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

      /// FETCH LEADS + FOLLOW-UPS
      final List<AddLeadModel> allLeads = await Future.wait(
        snap.docs.map((leadDoc) async {
          /// MAIN LEAD
          final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

          /// FETCH FOLLOW-UP SUBCOLLECTION
          final FOLLOW-UPSnap = await _collection
              .doc(leadDoc.id)
              .collection('FOLLOW_UPS')
              .orderBy('createdAt', descending: true)
              .get();

          /// CONVERT FOLLOW-UPS
          final FOLLOW-UPs = FOLLOW-UPSnap.docs.map((fupDoc) {
            return FOLLOW-UPModel.fromFirestore(fupDoc.data(), fupDoc.id);
          }).toList();

          /// RETURN LEAD WITH FOLLOW-UPS
          return lead.copyWith(FOLLOW-UP: FOLLOW-UPs);
        }),
      );

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

      final List<AddLeadModel> result = [];

      int totalCount = 0;
      for (final lead in allLeads) {
        final matchingFOLLOW-UPs =
            lead.FOLLOW-UP?.where((fup) {
              final inRange = isInRange(fup.calledDate);
              if (role.toLowerCase() != 'admin') {
                return inRange && fup.createdById == staffId;
              }
              return inRange;
            }).toList() ??
            [];
        if (matchingFOLLOW-UPs.isNotEmpty) {
          for (final fup in matchingFOLLOW-UPs) {
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

  @override
  Future<void> _logActivity(String leadId, ActivityModel activity) async {
    await _collection
        .doc(leadId)
        .collection('ACTIVITIES')
        .doc()
        .set(activity.toFirestore());
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
      batch.set(
        activityRef.doc(),
        ActivityModel(
          id: '',
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
      final stage = (data['leadStage'] ?? '').toString().toUpperCase();

      switch (stage) {
        case 'NEW':
          counts['New'] = (counts['New'] ?? 0) + 1;
          break;
        case 'FOLLOW UP':
        case 'FOLLOW-UP':
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
      } else if (stage == 'FOLLOW UP' || stage == 'FOLLOW-UP') {
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
            FOLLOW-UPCount: e.value['FOLLOW UP'] ?? 0,
            rejectedCount: e.value['REJECTED'] ?? 0,
            closedCount: e.value['CLOSED'] ?? 0,
          ),
        )
        .toList();

    rows.sort((a, b) {
      final totalA =
          a.newCount + a.FOLLOW-UPCount + a.rejectedCount + a.closedCount;
      final totalB =
          b.newCount + b.FOLLOW-UPCount + b.rejectedCount + b.closedCount;
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

      final FOLLOW-UPSnap = await _collection
          .doc(leadId)
          .collection('FOLLOW_UPS')
          .orderBy('createdAt', descending: true)
          .get();

      final FOLLOW-UPs = FOLLOW-UPSnap.docs
          .map((e) => FOLLOW-UPModel.fromFirestore(e.data(), e.id))
          .toList();

      final lead = AddLeadModel.fromFirestore(leadDoc.data()!, leadDoc.id);

      return lead.copyWith(FOLLOW-UP: FOLLOW-UPs);
    } catch (e) {
      throw Exception('Failed to fetch lead: $e');
    }
  }

  // Future<void> deleteFOLLOW-UP({
  //   required String leadId,
  //   required String FOLLOW-UPId,
  // }) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('LEADS')
  //         .doc(leadId)
  //         .collection('FOLLOW_UPS')
  //         .doc(FOLLOW-UPId)
  //         .delete();
  //   } catch (e) {
  //     throw Exception('Failed to delete follow-up: $e');
  //   }
  // }

  Future<void> deleteFOLLOW-UP({
    required String leadId,
    required String FOLLOW-UPId,
    required String changedByName,
    required String changedById,
    required String leadName,
    required String leadPhone,
  }) async {
    final leadRef = _collection.doc(leadId);

    final activityRef = leadRef.collection('ACTIVITIES');

    // Read FOLLOW-UP BEFORE deleting
    final deletedDoc = await leadRef
        .collection('FOLLOW_UPS')
        .doc(FOLLOW-UPId)
        .get();

    if (!deletedDoc.exists) {
      throw Exception('Follow-up not found');
    }

    final deletedFOLLOW-UP = FOLLOW-UPModel.fromFirestore(
      deletedDoc.data()!,
      deletedDoc.id,
    );

    // Delete FOLLOW-UP
    await deletedDoc.reference.delete();

    // Find the next latest FOLLOW-UP
    final remaining = await leadRef
        .collection('FOLLOW_UPS')
        .orderBy('calledDate', descending: true)
        .limit(1)
        .get();

    if (remaining.docs.isNotEmpty) {
      final latest = FOLLOW-UPModel.fromFirestore(
        remaining.docs.first.data(),
        remaining.docs.first.id,
      );

      await leadRef.update({
        'leadStage': latest.leadStage,
        'priority': latest.priority,
        'leadCategory': latest.leadCategory,
        'FOLLOW-UPDate': latest.nextFOLLOW-UPDate,
        'calledDate': latest.calledDate,
        'callResult': latest.calledStatus,
        'remarks': latest.remarks,
      });
    }

    // Log activity
    await activityRef.add(
      ActivityModel(
        id: '',
        type: ActivityType.FOLLOW-UPDeleted,
        changedBy: changedByName,
        changedById: changedById,
        changedAt: DateTime.now(),
        leadId: leadId,
        leadName: leadName,
        leadPhone: leadPhone,
        previousValue: deletedFOLLOW-UP.calledStatus,
        newValue: '',
        description:
            'Deleted follow-up. Status: ${deletedFOLLOW-UP.leadStage}, '
            'Call Result: ${deletedFOLLOW-UP.calledStatus}, '
            'Scheduled Date: ${DateFormat('dd-MM-yyyy HH:mm').format(deletedFOLLOW-UP.nextFOLLOW-UPDate)}',
      ).toFirestore(),
    );
  }

  @override
  Future<bool> isContactNumberExists(String contactNumber) async {
    final snap = await _collection
        .where('contactNumber', isEqualTo: contactNumber.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Future<bool> isWhatsappNumberExists(String whatsappNumber) async {
    if (whatsappNumber.trim().isEmpty) return false;
    final snap = await _collection
        .where('whatsappNumber', isEqualTo: whatsappNumber.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
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
    return snap.docs.any((doc) => doc.id != currentLeadId);
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
    return snap.docs.any((doc) => doc.id != currentLeadId);
  }
}

Future<void> migrateHasFOLLOW-UP() async {
  final db = FirebaseFirestore.instance;
  final leadsSnap = await db.collection('LEADS').get();

  int updated = 0;
  int skipped = 0;

  for (final leadDoc in leadsSnap.docs) {
    final data = leadDoc.data();

    // Skip if already set
    if (data.containsKey('hasFOLLOW-UP')) {
      skipped++;
      continue;
    }

    // Check if this lead has any follow-ups
    final FOLLOW-UPsSnap = await db
        .collection('LEADS')
        .doc(leadDoc.id)
        .collection('FOLLOW_UPS')
        .limit(1)
        .get();

    final hasFOLLOW-UP = FOLLOW-UPsSnap.docs.isNotEmpty;

    await db.collection('LEADS').doc(leadDoc.id).update({
      'hasFOLLOW-UP': hasFOLLOW-UP,
    });

    updated++;
    print('Updated ${leadDoc.id} → hasFOLLOW-UP: $hasFOLLOW-UP');
  }

  print('Migration complete. Updated: $updated, Skipped: $skipped');
}
