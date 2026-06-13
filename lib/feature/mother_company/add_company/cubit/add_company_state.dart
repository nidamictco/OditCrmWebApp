import 'dart:typed_data';

import '../widgets/subscription_step.dart';

class AddCompanyState {
  final int currentStep;

  // Step 1
  final String companyName;
  final String domain;
  final String industry;
  final Uint8List? logoBytes;
  final String? logoUrl;

  // Step 2
  final SubscriptionPlan selectedPlan;
  final bool yearlyBilling;

  final bool analyticsAddon;
  final bool supportAddon;
  final bool storageAddon;

  // Step 3
  final String adminName;
  final String adminEmail;
  final String adminMobile;
  final String password;
  final String confirmPassword;

  final bool enableMfa;
  final bool enableAuditLogs;
  final bool enableIpRestriction;

  final int sessionTimeout;

  // System
  final String generatedCompanyId;

  final bool isLoading;
  final bool isCreating;
  final bool companyCreated;

  final String? errorMessage;

  const AddCompanyState({
    this.currentStep = 1,

    this.companyName = '',
    this.domain = '',
    this.industry = '',

    this.logoBytes,
    this.logoUrl,

    this.selectedPlan = SubscriptionPlan.professional,
    this.yearlyBilling = false,

    this.analyticsAddon = false,
    this.supportAddon = false,
    this.storageAddon = false,

    this.adminName = '',
    this.adminEmail = '',
    this.adminMobile = '',
    this.password = '',
    this.confirmPassword = '',

    this.enableMfa = true,
    this.enableAuditLogs = true,
    this.enableIpRestriction = false,

    this.sessionTimeout = 30,

    this.generatedCompanyId = '',

    this.isLoading = false,
    this.isCreating = false,
    this.companyCreated = false,

    this.errorMessage,
  });

  AddCompanyState copyWith({
    int? currentStep,

    String? companyName,
    String? domain,
    String? industry,

    Uint8List? logoBytes,
    String? logoUrl,

    SubscriptionPlan? selectedPlan,
    bool? yearlyBilling,

    bool? analyticsAddon,
    bool? supportAddon,
    bool? storageAddon,

    String? adminName,
    String? adminEmail,
    String? adminMobile,
    String? password,
    String? confirmPassword,

    bool? enableMfa,
    bool? enableAuditLogs,
    bool? enableIpRestriction,

    int? sessionTimeout,

    String? generatedCompanyId,

    bool? isLoading,
    bool? isCreating,
    bool? companyCreated,

    String? errorMessage,
  }) {
    return AddCompanyState(
      currentStep:
      currentStep ?? this.currentStep,

      companyName:
      companyName ?? this.companyName,
      domain: domain ?? this.domain,
      industry:
      industry ?? this.industry,

      logoBytes: logoBytes ?? this.logoBytes,
      logoUrl: logoUrl ?? this.logoUrl,

      selectedPlan:
      selectedPlan ?? this.selectedPlan,

      yearlyBilling:
      yearlyBilling ?? this.yearlyBilling,

      analyticsAddon:
      analyticsAddon ??
          this.analyticsAddon,

      supportAddon:
      supportAddon ??
          this.supportAddon,

      storageAddon:
      storageAddon ??
          this.storageAddon,

      adminName:
      adminName ?? this.adminName,

      adminEmail: adminEmail ?? this.adminEmail,
      adminMobile: adminMobile ?? this.adminMobile,

      password:
      password ?? this.password,

      confirmPassword:
      confirmPassword ??
          this.confirmPassword,

      enableMfa:
      enableMfa ?? this.enableMfa,

      enableAuditLogs:
      enableAuditLogs ??
          this.enableAuditLogs,

      enableIpRestriction:
      enableIpRestriction ??
          this.enableIpRestriction,

      sessionTimeout:
      sessionTimeout ??
          this.sessionTimeout,

      generatedCompanyId:
      generatedCompanyId ??
          this.generatedCompanyId,

      isLoading:
      isLoading ?? this.isLoading,

      isCreating:
      isCreating ?? this.isCreating,

      companyCreated:
      companyCreated ??
          this.companyCreated,

      errorMessage:
      errorMessage ?? this.errorMessage,
    );
  }
}