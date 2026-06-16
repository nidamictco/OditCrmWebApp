import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/dashboard_topbar.dart';
import '../cubit/add_new_company_cubit.dart';
import '../cubit/add_new_company_state.dart';
import '../repository/add_new_company_repo.dart';
import '../services/firebase_add_new_company_service.dart';
import '../widgets/form_field_widgets.dart';

class AddNewCompanyPage extends StatelessWidget {
  final VoidCallback? onBackTap;

  const AddNewCompanyPage({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddNewCompanyCubit(
        repository: AddNewCompanyRepository(
          service: FirebaseAddNewCompanyService(),
        ),
      ),
      child: _AddNewCompanyView(onBackTap: onBackTap),
    );
  }
}

class _AddNewCompanyView extends StatefulWidget {
  final VoidCallback? onBackTap;

  const _AddNewCompanyView({this.onBackTap});

  @override
  State<_AddNewCompanyView> createState() => _AddNewCompanyViewState();
}

class _AddNewCompanyViewState extends State<_AddNewCompanyView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyNameController;
  late TextEditingController _adminNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _adminNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _adminNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context, AddNewCompanyState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00B388),
                  size: 64,
                ),
                const SizedBox(height: 18),
                Text(
                  'Onboarding Successful!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The company profile has been created in the database.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppThemeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppThemeColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Company ID', state.companyId),
                      const SizedBox(height: 8),
                      _buildInfoRow('Admin Email', state.adminEmail),
                      const SizedBox(height: 8),
                      _buildInfoRow('Default Password', 'Admin@123'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      if (widget.onBackTap != null) {
                        widget.onBackTap!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppThemeColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddNewCompanyCubit, AddNewCompanyState>(
      listener: (context, state) {
        if (state.formStatus == AddNewCompanyStatus.success) {
          _showSuccessDialog(context, state);
        } else if (state.formStatus == AddNewCompanyStatus.error) {
          final rawMsg = state.errorMessage ?? 'An error occurred';
          var friendlyMsg = rawMsg.startsWith('Exception: ')
              ? rawMsg.substring('Exception: '.length)
              : rawMsg;
          if (friendlyMsg.contains("Phone number already exists.")) {
            friendlyMsg = "This phone number is already registered. Please use a different phone number.";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(friendlyMsg),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddNewCompanyCubit>();

        return Scaffold(
          backgroundColor: AppThemeColors.scaffoldBg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardTopBar(screen: 'addCompany'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1300),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Breadcrumb
                            // Row(
                            //   children: [
                            //     Text(
                            //       'Company Manage',
                            //       style: GoogleFonts.poppins(
                            //         fontSize: 13,
                            //         color: AppThemeColors.textSecondary,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //     const SizedBox(width: 4),
                            //     const Icon(
                            //       Icons.chevron_right_rounded,
                            //       size: 16,
                            //       color: AppThemeColors.textSecondary,
                            //     ),
                            //     const SizedBox(width: 4),
                            //     Text(
                            //       'Add New Company',
                            //       style: GoogleFonts.poppins(
                            //         fontSize: 13,
                            //         color: AppThemeColors.primary,
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //     const SizedBox(width: 4),
                            //     const Icon(
                            //       Icons.chevron_right_rounded,
                            //       size: 16,
                            //       color: AppThemeColors.textSecondary,
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 28),

                            // Onboard Headers
                            Text(
                              'Onboard New Organization',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppThemeColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Initialize A New For Your Enterprise Client, Complete The Three-Step Setup Below.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppThemeColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Main Onboarding Container Card
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppThemeColors.borderLight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row 1: Company Name, Admin Name
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: NewCompanyTextField(
                                          label: 'Company Name',
                                          hint: 'Enter company name',
                                          controller: _companyNameController,
                                          prefixIcon: Icons.business_outlined,
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return 'Company Name is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: NewCompanyTextField(
                                          label: 'Admin Name',
                                          hint: 'Enter admin name',
                                          controller: _adminNameController,
                                          prefixIcon:
                                              Icons.person_outline_rounded,
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return 'Admin Name is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Row 2: Email, Phone, Plan, Status
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: NewCompanyTextField(
                                          label: 'Email Address',
                                          hint:
                                              'Enter email number', // Match exact mockup label hint
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return 'Email Address is required';
                                            }
                                            if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                            ).hasMatch(val.trim())) {
                                              return 'Enter a valid email address';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: NewCompanyTextField(
                                          label: 'Phone Number',
                                          hint: '9876543210',
                                          controller: _phoneController,
                                          isPhone: true,
                                          keyboardType: TextInputType.phone,
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return 'Phone Number is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: NewCompanyDropdownField<String>(
                                          label: 'Plan Type',
                                          value: state.planType,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'basic',
                                              child: Text('Basic'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'professional',
                                              child: Text('Standard'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'enterprise',
                                              child: Text('Enterprise'),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            if (val != null)
                                              cubit.updatePlanType(val);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: NewCompanyDropdownField<String>(
                                          label: 'Status',
                                          value: state.status,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'pending',
                                              child: Text('Pending'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'active',
                                              child: Text('Active'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'suspended',
                                              child: Text('Suspended'),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            if (val != null)
                                              cubit.updateStatus(val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Row 3: Registration Date, Location
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: NewCompanyDatePickerField(
                                          label: 'Registration Date',
                                          selectedDate: state.registrationDate,
                                          onChanged: (val) {
                                            cubit.updateRegistrationDate(val);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 3,
                                        child: NewCompanyTextField(
                                          label: 'Location',
                                          hint: 'Enter location',
                                          controller: _locationController,
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return 'Location is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 36),

                                  // Buttons Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Back Button
                                      OutlinedButton(
                                        onPressed: () {
                                          if (widget.onBackTap != null) {
                                            widget.onBackTap!();
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppThemeColors.textSecondary,
                                          side: const BorderSide(
                                            color: AppThemeColors.borderLight,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 28,
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Back',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Save Button
                                      SizedBox(
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed:
                                              state.formStatus ==
                                                  AddNewCompanyStatus.submitting
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    cubit.updateCompanyName(
                                                      _companyNameController
                                                          .text,
                                                    );
                                                    cubit.updateAdminName(
                                                      _adminNameController.text,
                                                    );
                                                    cubit.updateEmail(
                                                      _emailController.text,
                                                    );
                                                    cubit.updatePhone(
                                                      _phoneController.text,
                                                    );
                                                    cubit.updateLocation(
                                                      _locationController.text,
                                                    );
                                                    cubit.submitCompany();
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF00B388,
                                            ), // figma green
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 28,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child:
                                              state.formStatus ==
                                                  AddNewCompanyStatus.submitting
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                          Colors.white,
                                                        ),
                                                  ),
                                                )
                                              : Text(
                                                  'Save',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
}
