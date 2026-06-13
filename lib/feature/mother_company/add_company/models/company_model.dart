import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String companyId;

  final String companyName;

  final String companyCategory;

  final String companyLogo;

  final String contactPerson;

  final String mobileNumber;

  final String address;

  final String planType;

  final String subscriptionType;

  final double subscriptionAmount;

  final double taxAmount;

  final double discountAmount;

  final double totalAmount;

  final Timestamp subscriptionStartDate;

  final Timestamp subscriptionEndDate;

  final String status;

  final Timestamp createdAt;

  final Timestamp updatedAt;

  CompanyModel({
    required this.companyId,
    required this.companyName,
    required this.companyCategory,
    required this.companyLogo,
    required this.contactPerson,
    required this.mobileNumber,
    required this.address,
    required this.planType,
    required this.subscriptionType,
    required this.subscriptionAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "companyId": companyId,
      "companyName": companyName,
      "companyCategory": companyCategory,
      "companyLogo": companyLogo,
      "contactPerson": contactPerson,
      "mobileNumber": mobileNumber,
      "address": address,
      "planType": planType,
      "subscriptionType": subscriptionType,
      "subscriptionAmount":
      subscriptionAmount,
      "taxAmount": taxAmount,
      "discountAmount":
      discountAmount,
      "totalAmount": totalAmount,
      "subscriptionStartDate":
      subscriptionStartDate,
      "subscriptionEndDate":
      subscriptionEndDate,
      "status": status,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  factory CompanyModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return CompanyModel(
      companyId: map["companyId"] ?? "",
      companyName:
      map["companyName"] ?? "",
      companyCategory:
      map["companyCategory"] ?? "",
      companyLogo:
      map["companyLogo"] ?? "",
      contactPerson:
      map["contactPerson"] ?? "",
      mobileNumber:
      map["mobileNumber"] ?? "",
      address: map["address"] ?? "",
      planType: map["planType"] ?? "",
      subscriptionType:
      map["subscriptionType"] ?? "",
      subscriptionAmount:
      (map["subscriptionAmount"] ?? 0)
          .toDouble(),
      taxAmount:
      (map["taxAmount"] ?? 0)
          .toDouble(),
      discountAmount:
      (map["discountAmount"] ?? 0)
          .toDouble(),
      totalAmount:
      (map["totalAmount"] ?? 0)
          .toDouble(),
      subscriptionStartDate:
      map["subscriptionStartDate"],
      subscriptionEndDate:
      map["subscriptionEndDate"],
      status: map["status"] ?? "",
      createdAt: map["createdAt"],
      updatedAt: map["updatedAt"],
    );
  }
}