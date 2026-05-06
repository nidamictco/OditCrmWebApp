// // lib/feature/lead_managment/add_lead/data/add_lead_repository.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:oxdo/feature/lead_managment/add_lead/model/add_lead_model.dart';

// abstract class IAddLeadRepository {
//   Future<String> addLead(AddLeadModel lead);
// }

// class AddLeadRepository implements IAddLeadRepository {
//   final FirebaseFirestore _firestore;

//   AddLeadRepository({FirebaseFirestore? firestore})
//       : _firestore = firestore ?? FirebaseFirestore.instance;

//   CollectionReference<Map<String, dynamic>> get _collection =>
//       _firestore.collection('LEADS');

//   @override
//   Future<String> addLead(AddLeadModel lead) async {
//     if (lead.clientName.trim().isEmpty) {
//       throw ArgumentError('Client name cannot be empty.');
//     }
//     if (lead.contactNumber.trim().isEmpty) {
//       throw ArgumentError('Contact number cannot be empty.');
//     }

//     final doc = await _collection.add(lead.toFirestore());
//     return doc.id;
//   }

//  Future<List<AddLeadModel>> fetchLeads() async {
//     final snap = await _firestore
//         .collection('LEADS')
//         .orderBy('createdAt', descending: true)
//         .get();

//     return snap.docs
//         .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
//         .toList();
//   }

// }


// lib/feature/lead_managment/add_lead/data/add_lead_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oxdo/feature/lead_managment/add_lead/model/add_lead_model.dart';

abstract class IAddLeadRepository {
  Future<String> addLead(AddLeadModel lead);
  Future<List<AddLeadModel>> fetchLeads();
  Future<void> updateLead(String id, AddLeadModel lead);
  Future<void> deleteLead(String id);
}

class AddLeadRepository implements IAddLeadRepository {
  final FirebaseFirestore _firestore;

  AddLeadRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('LEADS');

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
}