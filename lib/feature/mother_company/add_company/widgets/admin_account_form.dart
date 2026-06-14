import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAccountForm extends StatelessWidget {
  final TextEditingController adminNameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final bool obscurePassword;
  final bool obscureConfirmPassword;

  final VoidCallback togglePassword;
  final VoidCallback toggleConfirmPassword;

  final FormFieldValidator<String>? adminNameValidator;
  final FormFieldValidator<String>? emailValidator;
  final FormFieldValidator<String>? mobileValidator;
  final FormFieldValidator<String>? passwordValidator;
  final FormFieldValidator<String>? confirmPasswordValidator;

  const AdminAccountForm({
    super.key,
    required this.adminNameController,
    required this.emailController,
    required this.mobileController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.togglePassword,
    required this.toggleConfirmPassword,
    this.adminNameValidator,
    this.emailValidator,
    this.mobileValidator,
    this.passwordValidator,
    this.confirmPasswordValidator,
  });

  @override
  Widget build(BuildContext context) {
    final password = passwordController.text;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Administrator Account",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Create the primary administrator account for this organization.",
            style: GoogleFonts.poppins(fontSize: 14, color: Color(0xff64748B)),
          ),

          const SizedBox(height: 32),

          _Field(
            label: "Administrator Name",
            child: TextFormField(
              controller: adminNameController,
              validator: adminNameValidator,
              style: GoogleFonts.poppins(),
              decoration: _inputDecoration("Enter full name"),
            ),
          ),

          const SizedBox(height: 20),

          _Field(
            label: "Administrator Email",
            child: TextFormField(
              controller: emailController,
              validator: emailValidator,
              style: GoogleFonts.poppins(),
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration("admin@company.com"),
            ),
          ),

          const SizedBox(height: 20),

          _Field(
            label: "Administrator Mobile Number",
            child: TextFormField(
              controller: mobileController,
              validator: mobileValidator,
              style: GoogleFonts.poppins(),
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration("+91 9876543210"),
            ),
          ),

          const SizedBox(height: 20),

          _Field(
            label: "Password",
            child: TextFormField(
              controller: passwordController,
              validator: passwordValidator,
              style: GoogleFonts.poppins(),
              obscureText: obscurePassword,
              decoration: _inputDecoration("Create password").copyWith(
                suffixIcon: IconButton(
                  onPressed: togglePassword,
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _Field(
            label: "Confirm Password",
            child: TextFormField(
              controller: confirmPasswordController,
              validator: confirmPasswordValidator,
              style: GoogleFonts.poppins(),
              obscureText: obscureConfirmPassword,
              decoration: _inputDecoration("Confirm password").copyWith(
                suffixIcon: IconButton(
                  onPressed: toggleConfirmPassword,
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Text(
          //   "Password Strength",
          //   style: GoogleFonts.poppins(
          //     fontSize: 13,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),

          // const SizedBox(height: 10),

          // _PasswordStrengthBar(
          //   password: password,
          // ),

          // const SizedBox(height: 10),

          // Text(
          //   _passwordStrengthLabel(password),
          //   style: GoogleFonts.poppins(
          //     fontWeight: FontWeight.w600,
          //     color: _passwordStrengthColor(
          //       password,
          //     ),
          //   ),
          // ),

          // const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xffF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xff0F2E8A)),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "The administrator will receive an invitation email after the company is provisioned.",
                    style: GoogleFonts.poppins(color: Color(0xff475569)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff0F2E8A), width: 2),
      ),
    );
  }

  static String _passwordStrengthLabel(String password) {
    if (password.length < 6) {
      return "Weak";
    }

    if (password.length < 10) {
      return "Medium";
    }

    return "Strong";
  }

  static Color _passwordStrengthColor(String password) {
    if (password.length < 6) {
      return Colors.red;
    }

    if (password.length < 10) {
      return Colors.orange;
    }

    return Colors.green;
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),

        const SizedBox(height: 8),

        child,
      ],
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final String password;

  const _PasswordStrengthBar({required this.password});

  @override
  Widget build(BuildContext context) {
    double value = 0;

    if (password.length >= 6) {
      value = .33;
    }

    if (password.length >= 10) {
      value = .66;
    }

    if (password.length >= 14) {
      value = 1;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: const Color(0xffE2E8F0),
        valueColor: AlwaysStoppedAnimation(
          value < .34
              ? Colors.red
              : value < .67
              ? Colors.orange
              : Colors.green,
        ),
      ),
    );
  }
}
