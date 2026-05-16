
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';

import '../../../dashboard/models/dashboard_count_model.dart';

abstract class IAddLeadRepository {
  Future<String> addLead(AddLeadModel lead);
  Future<List<AddLeadModel>> fetchLeads();
  Future<void> updateLead(String id, AddLeadModel lead);
  Future<void> deleteLead(String id);
  Future<void> moveToDeleted(AddLeadModel lead);
  Future<List<AddLeadModel>> fetchDeletedLeads(); 
  Future<String> restoreLead(AddLeadModel lead);
  Future<void> permanentlyDeleteLead(String id);
  Future<void> assignStaff(String leadId, String staffId, String staffName);
  Future<void> addFollowUp(String leadId, FollowUpModel followUp);
  Future<DashboardCountModel> fetchLeadCounts({
    required String staffId,
    required DateTime selectedDate,
  });
}
 
class AddLeadRepository implements IAddLeadRepository {
  final FirebaseFirestore _firestore;

  AddLeadRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('LEADS');
  CollectionReference<Map<String, dynamic>> get _deletedCollection =>
      _firestore.collection('DELETED_LEADS');


       String _generateDateId(String prefix) {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final timePart = DateFormat('HHmmss').format(now);
    final ms = now.millisecondsSinceEpoch % 1000; // last 3 digits for uniqueness
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

     final String id = _generateDateId('LEAD');
    await _collection.doc(id).set(lead.toFirestore());
    log('[AddLeadRepository] Lead added with ID: $id');
    return id;
  } 

  @override
  Future<List<AddLeadModel>> fetchLeads() async {
    final snap = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
        .toList();
  }

  @override
  Future<void> updateLead(String id, AddLeadModel lead) async {
    if (id.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
    await _collection.doc(id).update(lead.toFirestore());
  }

  @override
  Future<void> deleteLead(String id) async {
    if (id.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
    await _collection.doc(id).delete();
  }

  
@override
  Future<void> moveToDeleted(AddLeadModel lead) async {
  assert(lead.id != null, 'ID must not be null');
  
  final deletedLead = lead.copyWith(
    deletedAt: DateTime.now(), 
  ); 

  
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
Future<void> assignStaff(String leadId, String staffId, String staffName) async {
  if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
  await _collection.doc(leadId).update({
    'assignedStaffId': staffId,
    'assignedStaff': staffName,
  });
  log('[AddLeadRepository] Staff assigned to lead: $leadId → $staffId');
}


@override
Future<void> addFollowUp(String leadId, FollowUpModel followUp) async {
  if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
   
    final String followUpId = _generateDateId('FUP'); 
  await _collection
      .doc(leadId) 
      .collection('FOLLOW_UPS')
      .doc(followUpId).set(followUp.toFirestore());

 await _collection.doc(leadId).update({
    'leadStage': followUp.leadStage,
    'priority': followUp.priority,
    'leadCategory': followUp.leadCategory,
  });

  log('[AddLeadRepository] FollowUp added for lead: $leadId');
}

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day;
  }

  @override
  Future<DashboardCountModel> fetchLeadCounts({
    required String staffId,
    required DateTime selectedDate,
  }) async {

    final startOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final endOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    final snap = await _collection
        .where('assignedStaffId', isEqualTo: staffId)
        .get();

    int newLeadCount = 0;
    int followUpCount = 0;
    int closedLeadCount = 0;
    int totalCalledCount = 0;
    int missedLeadCount = 0;
    int transferredCount = 0;

    for (final doc in snap.docs) {

      final data = doc.data();

      // ---------------- NEW LEADS ----------------
      final createdAt = data['createdAt'];

      if (createdAt != null) {
        final createdDate = (createdAt as Timestamp).toDate();

        if (_isSameDay(createdDate, selectedDate)) {
          newLeadCount++;
        }
      }

      // ---------------- FOLLOWUP ----------------
      final nextFollowUpDate = data['nextFollowUpDate'];

      if (nextFollowUpDate != null) {
        final followDate = (nextFollowUpDate as Timestamp).toDate();

        if (_isSameDay(followDate, selectedDate)) {
          followUpCount++;
        }
      }

      // ---------------- CLOSED ----------------
      final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();

      if (leadStage == 'CLOSED') {
        closedLeadCount++;
      }

      // ---------------- MISSED / REJECTED ----------------
      if (leadStage == 'REJECTED') {
        missedLeadCount++;
      }

      // ---------------- TOTAL CALLED ----------------
      final lastCalledDate = data['lastCalledDate'];

      if (lastCalledDate != null) {
        final calledDate = (lastCalledDate as Timestamp).toDate();

        if (_isSameDay(calledDate, selectedDate)) {
          totalCalledCount++;
        }
      }

      // ---------------- TRANSFERRED ----------------
      final transferredList = data['transferred'];

      if (transferredList != null && transferredList is List) {

        bool alreadyCounted = false;

        for (final item in transferredList) {

          if (item is Map<String, dynamic>) {

            final transferredTime = item['transferredTime'];

            if (transferredTime != null) {

              final transferDate =
              (transferredTime as Timestamp).toDate();

              if (_isSameDay(transferDate, selectedDate)) {

                if (!alreadyCounted) {
                  transferredCount++;
                  alreadyCounted = true;
                }
              }
            }
          }
        }
      }
    }

    return DashboardCountModel(
      newLeadCount: newLeadCount,
      followUpCount: followUpCount,
      closedLeadCount: closedLeadCount,
      totalCalledCount: totalCalledCount,
      missedLeadCount: missedLeadCount,
      transferredCount: transferredCount,
    );
  }



} 