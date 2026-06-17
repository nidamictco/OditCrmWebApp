import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubit/add_new_company_state.dart';

class FirebaseAddNewCompanyService {
  final FirebaseFirestore firestore;

  FirebaseAddNewCompanyService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createCompany(AddNewCompanyState state) async {
    // Check if phone number already exists globally in USERS collection
    final existingUser = await firestore
        .collection("USERS")
        .where("phone", isEqualTo: state.phone)
        .limit(1)
        .get();

    if (existingUser.docs.isNotEmpty) {
      throw Exception("Phone number already exists.");
    }

    final companyId = state.companyId;
    final userId = DateTime.now().millisecondsSinceEpoch.toString();

    final now = DateTime.now();
    final startDate = state.registrationDate;
    // subscriptionEndDate is 1 month later by default
    final endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);

    final domain = state.companyName.toLowerCase().replaceAll(RegExp(r'\s+'), '') + '.oditcrm.com';

    final batch = firestore.batch();

    // 1. Create User in USERS collection
    final userDoc = firestore.collection("USERS").doc(userId);
    batch.set(userDoc, {
      "userId": userId,
      "name": state.adminName,
      "email": state.adminEmail,
      "phone": state.phone,
      "password": "Admin@123", // default password
      "companyId": companyId,
      "companyType": "sub_company",
      "staffType": "Admin",
      "status": "Active",
      "createdAt": FieldValue.serverTimestamp(),
    });

    // 2. Create Company in COMPANY collection
    final companyDoc = firestore.collection("COMPANY").doc(companyId);
    batch.set(companyDoc, {
      "companyId": companyId,
      "companyName": state.companyName,
      "domain": domain,
      "industry": "Other",
      "logoUrl": "",
      "subscriptionPlan": state.planType, // basic / professional / enterprise
      "yearlyBilling": false,
      "adminName": state.adminName,
      "adminEmail": state.adminEmail,
      "adminMobile": state.phone,
      "subscriptionStartDate": Timestamp.fromDate(startDate),
      "subscriptionEndDate": Timestamp.fromDate(endDate),
      "createdAt": FieldValue.serverTimestamp(),
      "createdBy": "SUPER_ADMIN",
      "status": state.status.toUpperCase(), // PENDING / ACTIVE / SUSPENDED
      "location": state.location,
    });

    // 3. Create Admin Staff in STAFF sub-collection
    final adminUid = "admin-$companyId";
    batch.set(companyDoc.collection("STAFF").doc(adminUid), {
      "staffId": adminUid,
      "name": state.adminName,
      "email": state.adminEmail,
      "staffType": "Admin",
      "phone": state.phone,
      "password": "Admin@123",
      "companyId": companyId,
      "companyType": "sub_company",
      "status": "Active",
      "designation":'Company_Admin',
      "designationId":"Company_Admin",
      "joiningDate":'_',
      "imageUrl":'',
      

      "createdAt": FieldValue.serverTimestamp(),
    });

    // 4. Create General settings sub-collection
    batch.set(companyDoc.collection("SETTINGS").doc("general"), {
      "companyName": state.companyName,
      "domain": domain,
      "industry": "Other",
      "location": state.location,
    });

    // 5. Create Subscription settings sub-collection
    batch.set(companyDoc.collection("SETTINGS").doc("subscription"), {
      "plan": state.planType,
      "yearlyBilling": false,
    });

    await batch.commit();
  }
}
