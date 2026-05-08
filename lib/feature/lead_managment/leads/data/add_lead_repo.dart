
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';

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
}
 
class AddLeadRepository implements IAddLeadRepository {
  final FirebaseFirestore _firestore;

  AddLeadRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('LEADS');
  CollectionReference<Map<String, dynamic>> get _deletedCollection =>
      _firestore.collection('DELETED_LEADS');

  @override
  Future<String> addLead(AddLeadModel lead) async {
    if (lead.clientName.trim().isEmpty) {
      throw ArgumentError('Client name cannot be empty.');
    }
    if (lead.contactNumber.trim().isEmpty) {
      throw ArgumentError('Contact number cannot be empty.');
    }
    final doc = await _collection.add(lead.toFirestore());
    return doc.id;
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
} 