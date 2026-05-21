import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oxdo/feature/settings/general_settings/model/general_settings_model.dart';

class GeneralSettingsRepository {
  GeneralSettingsRepository({
    required this.staffId, // ← staff document ID from StaffModel
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final String staffId;
  final FirebaseFirestore _firestore;

  /// Firestore path: STAFF/{staffId}/settings/general
  DocumentReference<Map<String, dynamic>> get _docRef => _firestore
      .collection('STAFF')
      .doc(staffId)
      .collection('settings')
      .doc('general');

  Future<GeneralSettingsModel> fetchSettings() async {
    final snap = await _docRef.get();
    if (snap.exists && snap.data() != null) {
      return GeneralSettingsModel.fromMap(snap.data()!);
    }
    return const GeneralSettingsModel();
  }

  Future<void> saveSettings(GeneralSettingsModel model) async {
    await _docRef.set(model.toMap(), SetOptions(merge: true));
  }

  Future<void> updateField(String field, bool value) async {
    await _docRef.set({field: value}, SetOptions(merge: true));
  }
}