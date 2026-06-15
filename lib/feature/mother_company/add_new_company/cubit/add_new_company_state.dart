import 'package:equatable/equatable.dart';

enum AddNewCompanyStatus { initial, submitting, success, error }

class AddNewCompanyState extends Equatable {
  final AddNewCompanyStatus formStatus;
  final String companyId;
  final String companyName;
  final String adminName;
  final String adminEmail;
  final String phone;
  final String planType; // basic, professional, enterprise
  final String status; // pending, active, suspended
  final DateTime registrationDate;
  final String location;
  final String? errorMessage;

  const AddNewCompanyState({
    this.formStatus = AddNewCompanyStatus.initial,
    required this.companyId,
    this.companyName = '',
    this.adminName = '',
    this.adminEmail = '',
    this.phone = '',
    this.planType = 'basic',
    this.status = 'pending',
    required this.registrationDate,
    this.location = '',
    this.errorMessage,
  });

  AddNewCompanyState copyWith({
    AddNewCompanyStatus? formStatus,
    String? companyId,
    String? companyName,
    String? adminName,
    String? adminEmail,
    String? phone,
    String? planType,
    String? status,
    DateTime? registrationDate,
    String? location,
    String? errorMessage,
  }) {
    return AddNewCompanyState(
      formStatus: formStatus ?? this.formStatus,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
      phone: phone ?? this.phone,
      planType: planType ?? this.planType,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
      location: location ?? this.location,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        formStatus,
        companyId,
        companyName,
        adminName,
        adminEmail,
        phone,
        planType,
        status,
        registrationDate,
        location,
        errorMessage,
      ];
}
