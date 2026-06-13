import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';

import '../../shared/widgets/app_sidebar.dart';
import '../../shared/widgets/dashboard_topbar.dart';
import '../cubit/add_company_cubit.dart';
import '../cubit/add_company_state.dart';

import '../repository/add_company_repo.dart';

import '../services/firebase_add_company_service.dart';

import '../widgets/company_created_dialog.dart';
import '../widgets/company_information_step.dart';
import '../widgets/onboarding_stepper.dart';
import '../widgets/page_header.dart';
import '../widgets/subscription_step.dart';
import '../widgets/verification_step.dart';
import '../widgets/admin_account_form.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddCompanyPage extends StatelessWidget {
  const AddCompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCompanyCubit(
        repository: FirebaseAddCompanyRepository(
          service: FirebaseAddCompanyService(
            firestore: FirebaseFirestore.instance,
            storage: FirebaseStorage.instance,
          ),
        ),
      ),
      child: const _AddCompanyView(),
    );
  }
}

class _AddCompanyView extends StatefulWidget {
  const _AddCompanyView();

  @override
  State<_AddCompanyView> createState() =>
      _AddCompanyViewState();
}

class _AddCompanyViewState
    extends State<_AddCompanyView> {
  late TextEditingController companyController;
  late TextEditingController domainController;

  late TextEditingController adminNameController;
  late TextEditingController adminEmailController;
  late TextEditingController adminMobileController;

  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final List<String> industries = const [
    "Technology & SaaS",
    "Healthcare",
    "Finance",
    "Retail",
    "Education",
    "Manufacturing",
    "Construction",
    "Logistics",
  ];

  @override
  void initState() {
    super.initState();

    companyController =
        TextEditingController();

    domainController =
        TextEditingController();

    adminNameController =
        TextEditingController();

    adminEmailController =
        TextEditingController();

    adminMobileController =
        TextEditingController();

    passwordController =
        TextEditingController();

    confirmPasswordController =
        TextEditingController();
  }

  @override
  void dispose() {
    companyController.dispose();
    domainController.dispose();

    adminNameController.dispose();
    adminEmailController.dispose();
    adminMobileController.dispose();

    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
        AddCompanyCubit,
        AddCompanyState>(
      listener: (context, state) {
        if (state.companyCreated) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                CompanyCreatedDialog(
                  companyId:
                  state.generatedCompanyId,
                  adminMobile:
                  state.adminMobile,
                ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddCompanyCubit>();

        return Scaffold(
          backgroundColor:
          AppThemeColors.scaffoldBg,
          body: Column(
            children: [
              const DashboardTopBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28,),
                  child: Center(
                    child:
                    ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 1500,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const PageHeader(
                            breadcrumb:
                            "Company Management > Add New Company",
                            title:
                            "Onboard New Organization",
                            subtitle:
                            "Initialize a new company instance and configure its subscription.",
                          ),

                          const SizedBox(
                            height: 32,
                          ),

                          OnboardingStepper(
                            currentStep:
                            state
                                .currentStep,
                          ),

                          const SizedBox(
                            height: 40,
                          ),

                          _buildStep(
                            context,
                            cubit,
                            state,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep(
      BuildContext context,
      AddCompanyCubit cubit,
      AddCompanyState state,
      ) {
    switch (state.currentStep) {
      case 1:
        return CompanyInformationStep(
          companyNameController:
          companyController,
          domainController:
          domainController,
          selectedIndustry:
          state.industry.isEmpty
              ? null
              : state.industry,
          industries: industries,
          logoBytes:
          state.logoBytes,

          onIndustryChanged:
              (value) {
            cubit.updateIndustry(
              value ?? '',
            );
          },

          onUploadLogo:
          cubit.pickLogo,

          onCancel: () {
            Navigator.pop(
              context,
            );
          },

          onNext: () {
            cubit.updateCompanyName(
              companyController.text,
            );

            cubit.updateDomain(
              domainController.text,
            );

            cubit.nextStep();
          },
        );

      case 2:
        return SubscriptionStep(
          yearlyBilling:
          state.yearlyBilling,

          selectedPlan:
          state.selectedPlan,

          // analyticsAddon:
          // state.analyticsAddon,

          // supportAddon:
          // state.supportAddon,

          // storageAddon:
          // state.storageAddon,

          onBillingChanged:
          cubit.changeBilling,

          onPlanSelected:
          cubit.selectPlan,

          // onAnalyticsToggle:
          // cubit.toggleAnalytics,

          // onSupportToggle:
          // cubit.toggleSupport,

          // onStorageToggle:
          // cubit.toggleStorage,

          onBack:
          cubit.previousStep,

          onNext:
          cubit.nextStep,
        );

      case 3:
        return VerificationStep(
          adminAccountForm:
          AdminAccountForm(
            adminNameController:
            adminNameController,

            emailController: adminEmailController,
            mobileController: adminMobileController,

            passwordController:
            passwordController,

            confirmPasswordController:
            confirmPasswordController,

            obscurePassword:
            obscurePassword,

            obscureConfirmPassword:
            obscureConfirmPassword,

            togglePassword: () {
              setState(() {
                obscurePassword =
                !obscurePassword;
              });
            },

            toggleConfirmPassword:
                () {
              setState(() {
                obscureConfirmPassword =
                !obscureConfirmPassword;
              });
            },
          ),

          enableMfa:
          state.enableMfa,

          enableAuditLogs:
          state.enableAuditLogs,

          enableIpRestriction:
          state.enableIpRestriction,

          sessionTimeout:
          state.sessionTimeout,

          onMfaChanged:
          cubit.toggleMfa,

          onAuditChanged:
          cubit.toggleAudit,

          onIpRestrictionChanged:
          cubit
              .toggleIpRestriction,

          onSessionTimeoutChanged:
          cubit
              .updateSessionTimeout,

          companyName:
          state.companyName,

          domain:
          state.domain,

          industry:
          state.industry,

          plan:
          state.selectedPlan.name,

          billingCycle:
          state.yearlyBilling
              ? "Yearly"
              : "Monthly",

          addons: const [],

          adminEmail:
          adminEmailController.text,

          adminMobile:
          adminMobileController.text,

          generatedCompanyId:
          state.generatedCompanyId,

          isCreating:
          state.isCreating,

          onBack:
          cubit.previousStep,

          onCreateCompany: () {
            cubit.updateAdminName(
              adminNameController.text,
            );

            cubit.updateAdminEmail(
              adminEmailController.text,
            );

            cubit.updateAdminMobile(
              adminEmailController.text,
            );

            cubit.updatePassword(
              passwordController.text,
            );

            cubit.updateConfirmPassword(
              confirmPasswordController
                  .text,
            );

            cubit.createCompany();
          },
        );

      default:
        return const SizedBox();
    }
  }
}