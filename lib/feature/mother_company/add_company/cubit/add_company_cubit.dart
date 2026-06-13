import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';


import '../repository/add_company_repo.dart';
import '../widgets/subscription_step.dart';
import 'add_company_state.dart';

class AddCompanyCubit
    extends Cubit<AddCompanyState> {
  final FirebaseAddCompanyRepository
  repository;

  AddCompanyCubit({
    required this.repository,
  }) : super(
    AddCompanyState(
      generatedCompanyId:
      _generateCompanyId(),
    ),
  );

  static String _generateCompanyId() {
    final random = Random();

    return "CMP-${100000 + random.nextInt(899999)}";
  }

  void goToStep(int step) {
    emit(
      state.copyWith(
        currentStep: step,
      ),
    );
  }

  void nextStep() {
    emit(
      state.copyWith(
        currentStep:
        state.currentStep + 1,
      ),
    );
  }

  void previousStep() {
    emit(
      state.copyWith(
        currentStep:
        state.currentStep - 1,
      ),
    );
  }

  void updateCompanyName(
      String value,
      ) {
    emit(
      state.copyWith(
        companyName: value,
      ),
    );
  }

  void updateDomain(
      String value,
      ) {
    emit(
      state.copyWith(
        domain: value,
      ),
    );
  }

  void updateIndustry(
      String value,
      ) {
    emit(
      state.copyWith(
        industry: value,
      ),
    );
  }

  Future<void> pickLogo() async {
    final result =
    await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null) return;

    emit(
      state.copyWith(
        logoBytes:
        result.files.first.bytes,
      ),
    );
  }

  void selectPlan(
      SubscriptionPlan plan,
      ) {
    emit(
      state.copyWith(
        selectedPlan: plan,
      ),
    );
  }

  void changeBilling(
      bool yearly,
      ) {
    emit(
      state.copyWith(
        yearlyBilling: yearly,
      ),
    );
  }

  // void toggleAnalytics() {
  //   emit(
  //     state.copyWith(
  //       analyticsAddon:
  //       !state.analyticsAddon,
  //     ),
  //   );
  // }

  // void toggleSupport() {
  //   emit(
  //     state.copyWith(
  //       supportAddon:
  //       !state.supportAddon,
  //     ),
  //   );
  // }

  // void toggleStorage() {
  //   emit(
  //     state.copyWith(
  //       storageAddon:
  //       !state.storageAddon,
  //     ),
  //   );
  // }

  void updateAdminName(
      String value,
      ) {
    emit(
      state.copyWith(
        adminName: value,
      ),
    );
  }

  void updateAdminEmail(
      String value,
      ) {
    emit(
      state.copyWith(
        adminEmail: value,
      ),
    );
  }

  void updateAdminMobile(
      String value,
      ) {
    emit(
      state.copyWith(
        adminMobile : value,
      ),
    );
  }

  void updatePassword(
      String value,
      ) {
    emit(
      state.copyWith(
        password: value,
      ),
    );
  }

  void updateConfirmPassword(
      String value,
      ) {
    emit(
      state.copyWith(
        confirmPassword: value,
      ),
    );
  }

  void toggleMfa(bool value) {
    emit(
      state.copyWith(
        enableMfa: value,
      ),
    );
  }

  void toggleAudit(bool value) {
    emit(
      state.copyWith(
        enableAuditLogs: value,
      ),
    );
  }

  void toggleIpRestriction(
      bool value,
      ) {
    emit(
      state.copyWith(
        enableIpRestriction: value,
      ),
    );
  }

  void updateSessionTimeout(
      int value,
      ) {
    emit(
      state.copyWith(
        sessionTimeout: value,
      ),
    );
  }

  Future<void> createCompany() async {
    try {
      emit(
        state.copyWith(
          isCreating: true,
          errorMessage: null,
        ),
      );

      await repository.createCompany(
        state,
      );

      emit(
        state.copyWith(
          isCreating: false,
          companyCreated: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isCreating: false,
          errorMessage:
          e.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(
      AddCompanyState(
        generatedCompanyId:
        const Uuid().v4(),
      ),
    );
  }

  void updateLogo(Uint8List? bytes) {
    emit(
      state.copyWith(
        logoBytes: bytes,
      ),
    );
  }
}