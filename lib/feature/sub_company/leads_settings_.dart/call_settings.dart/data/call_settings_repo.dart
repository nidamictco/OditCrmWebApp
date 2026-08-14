// ─────────────────────────────────────────────────────────────────────────────
// repositories/call_settings_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// Firestore layout:
//   Collection : "CALL SETTINGS"
//   Document   : "BONVOICE"  →  { entries: [ {…}, … ] }
//   Document   : "VOXBAY"    →  { entries: [ {…}, … ] }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Odit_CRM/core/constant/firebase_const.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/call_settings.dart/model/bonvoice_model.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/call_settings.dart/model/voxbay_model.dart';



class CallSettingsRepository {
  CallSettingsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String _collection = 'CALL SETTINGS';
  static const String _bonvoiceDoc = 'BONVOICE';
  static const String _voxbayDoc = 'VOXBAY';
  static const String _field = 'entries';

  DocumentReference<Map<String, dynamic>> get _bonvoiceRef =>
      FirestorePath.companyCollection(_collection).doc(_bonvoiceDoc);

  DocumentReference<Map<String, dynamic>> get _voxbayRef =>
      FirestorePath.companyCollection(_collection).doc(_voxbayDoc);

  // ── BONVOICE ─────────────────────────────────────────────────────────────

  Stream<List<BonvoiceSettingsModel>> bonvoiceStream() {
    return _bonvoiceRef.snapshots().map((snap) {
      if (!snap.exists) return [];
      final raw = snap.data()?[_field];
      if (raw == null) return [];
      return (raw as List<dynamic>)
          .map((e) => BonvoiceSettingsModel.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Future<List<BonvoiceSettingsModel>> fetchBonvoice() async {
    final snap = await _bonvoiceRef.get();
    if (!snap.exists) return [];
    final raw = snap.data()?[_field];
    if (raw == null) return [];
    return (raw as List<dynamic>)
        .map((e) => BonvoiceSettingsModel.fromMap(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addBonvoice(BonvoiceSettingsModel model) async {
    await _bonvoiceRef.set(
      {_field: FieldValue.arrayUnion([model.toMap()])},
      SetOptions(merge: true),
    );
  }

  Future<void> updateBonvoice(BonvoiceSettingsModel updated) async {
    final list = await fetchBonvoice();
    final newList = list
        .map((e) => e.id == updated.id ? updated : e)
        .map((e) => e.toMap())
        .toList();
    await _bonvoiceRef.set({_field: newList});
  }

  Future<void> deleteBonvoice(String id) async {
    final list = await fetchBonvoice();
    final newList =
        list.where((e) => e.id != id).map((e) => e.toMap()).toList();
    await _bonvoiceRef.set({_field: newList});
  }

  // ── VOXBAY ───────────────────────────────────────────────────────────────

  Stream<List<VoxbaySettingsModel>> voxbayStream() {
    return _voxbayRef.snapshots().map((snap) {
      if (!snap.exists) return [];
      final raw = snap.data()?[_field];
      if (raw == null) return [];
      return (raw as List<dynamic>)
          .map((e) =>
              VoxbaySettingsModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Future<List<VoxbaySettingsModel>> fetchVoxbay() async {
    final snap = await _voxbayRef.get();
    if (!snap.exists) return [];
    final raw = snap.data()?[_field];
    if (raw == null) return [];
    return (raw as List<dynamic>)
        .map((e) =>
            VoxbaySettingsModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addVoxbay(VoxbaySettingsModel model) async {
    await _voxbayRef.set(
      {_field: FieldValue.arrayUnion([model.toMap()])},
      SetOptions(merge: true),
    );
  }

  Future<void> updateVoxbay(VoxbaySettingsModel updated) async {
    final list = await fetchVoxbay();
    final newList = list
        .map((e) => e.id == updated.id ? updated : e)
        .map((e) => e.toMap())
        .toList();
    await _voxbayRef.set({_field: newList});
  }

  Future<void> deleteVoxbay(String id) async {
    final list = await fetchVoxbay();
    final newList =
        list.where((e) => e.id != id).map((e) => e.toMap()).toList();
    await _voxbayRef.set({_field: newList});
  }
}