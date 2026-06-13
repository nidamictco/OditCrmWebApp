import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyIdGenerator {
  static Future<String> generate() async {
    final firestore = FirebaseFirestore.instance;

    return firestore.runTransaction((transaction) async {
      final counterRef = firestore
          .collection("SETTINGS")
          .doc("COMPANY_COUNTER");

      final snapshot =
      await transaction.get(counterRef);

      int count =
          (snapshot.data()?["count"] ?? 0) + 1;

      transaction.set(
        counterRef,
        {"count": count},
      );

      return "CMP${count.toString().padLeft(6, "0")}";
    });
  }
}