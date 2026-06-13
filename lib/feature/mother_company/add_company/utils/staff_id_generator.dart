import 'package:cloud_firestore/cloud_firestore.dart';

class StaffIdGenerator {
  static Future<String> generate() async {
    final firestore = FirebaseFirestore.instance;

    return firestore.runTransaction((transaction) async {
      final counterRef = firestore
          .collection("SETTINGS")
          .doc("STAFF_COUNTER");

      final snapshot =
      await transaction.get(counterRef);

      int count =
          (snapshot.data()?["count"] ?? 0) + 1;

      transaction.set(
        counterRef,
        {"count": count},
      );

      return "STF${count.toString().padLeft(6, "0")}";
    });
  }
}