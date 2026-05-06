import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>  get staffCollection => _firestore.collection('STAFF');
} 