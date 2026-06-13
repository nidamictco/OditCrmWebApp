import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../cubit/add_company_state.dart';

class FirebaseAddCompanyService {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirebaseAddCompanyService({
    required this.firestore,
    required this.storage,
  });

  Future<void> createCompany(
    AddCompanyState state,
  ) async {
    final companyId =
        state.generatedCompanyId;

    String? logoUrl;

    // Upload logo
    if (state.logoBytes != null) {
      logoUrl = await _uploadLogo(
        companyId,
        state.logoBytes!,
      );
    }

    final now = DateTime.now();
    final startDate = now;
    final endDate = state.yearlyBilling
        ? DateTime(now.year + 1, now.month, now.day)
        : DateTime(now.year, now.month + 1, now.day);

    final batch =
    firestore.batch();

    final companyDoc = firestore
        .collection("COMPANY")
        .doc(companyId);

    batch.set(
      companyDoc,
      {
        "companyId": companyId,

        "companyName":
        state.companyName,

        "domain":
        state.domain,

        "industry":
        state.industry,

        "logoUrl": logoUrl,

        "subscriptionPlan":
        state.selectedPlan.name,

        "yearlyBilling":
        state.yearlyBilling,

        "adminName":
        state.adminName,

        "adminEmail":
        state.adminEmail,

        "adminMobile":
        state.adminMobile,

        "subscriptionStartDate":
        Timestamp.fromDate(startDate),

        "subscriptionEndDate":
        Timestamp.fromDate(endDate),

        // "analyticsAddon":
        // state.analyticsAddon,

        // "supportAddon":
        // state.supportAddon,

        // "storageAddon":
        // state.storageAddon,

        "enableMfa":
        state.enableMfa,

        "enableAuditLogs":
        state.enableAuditLogs,

        "enableIpRestriction":
        state.enableIpRestriction,

        "sessionTimeout":
        state.sessionTimeout,

        "createdAt":
        FieldValue.serverTimestamp(),

        "createdBy":
        "SUPER_ADMIN",

        "status":
        "ACTIVE",
      },
    );

    // Admin

    final adminUid = "admin-$companyId";
    batch.set(
      companyDoc
          .collection("staff")
          .doc(adminUid),
      {
        "staffId": adminUid,

        "name":
        state.adminName,

        "email":
        state.adminEmail,

        "role":
        "ADMIN",

        "isActive": true,

        "createdAt":
        FieldValue.serverTimestamp(),
      },
    );

    // Settings

    batch.set(
      companyDoc
          .collection("settings")
          .doc("general"),
      {
        "companyName":
        state.companyName,

        "domain":
        state.domain,

        "industry":
        state.industry,
      },
    );

    // Subscription

    batch.set(
      companyDoc
          .collection("settings")
          .doc("subscription"),
      {
        "plan":
        state.selectedPlan.name,

        "yearlyBilling":
        state.yearlyBilling,

        // "analyticsAddon":
        // state.analyticsAddon,

        // "supportAddon":
        // state.supportAddon,

        // "storageAddon":
        // state.storageAddon,
      },
    );

    await batch.commit();
  }

  Future<String> _uploadLogo(
      String companyId,
      Uint8List bytes,
      ) async {
    final ref = storage
        .ref()
        .child(
      "company_logos/$companyId.png",
    );

    await ref.putData(bytes);

    return ref.getDownloadURL();
  }
}