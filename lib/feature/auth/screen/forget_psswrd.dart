import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/asset_resources.dart';
import 'login.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _otpSent = false;
  bool _otpVerified = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Switch card based on step ──
                  if (!_otpSent) _buildPhoneCard(context),
                  if (_otpSent && !_otpVerified) _buildOtpCard(context),
                  if (_otpVerified) _buildNewPasswordCard(context),

                  SizedBox(height: 1.h),
                  Text(
                    '© 2026. Crafted with ❤️ by Mictco It Solutions',
                    style: AppTextStyle.small(color: Colors.grey, size: 10.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Phone Card ───────────────────────────────────────────────────

  Widget _buildPhoneCard(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + Back
            Center(child: _buildHeader(context)),

            // Title
            Text(
              'Forgot Password',
              style: AppTextStyle.medium(weight: FontWeight.bold),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Enter your registered phone number.\nWe will send an OTP to reset your password.',
              style: AppTextStyle.medium(size: 10.sp, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Text('Phone Number', style: AppTextStyle.medium()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+91XXXXXXXXXX',
                hintStyle: AppTextStyle.medium(
                  size: 11.sp,
                  color: AppColors.grey,
                ),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter phone number' : null,
            ),

            SizedBox(height: 2.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // TODO: call sendOtp()
                    _buildOtpCard(context);
                    setState(() => _otpSent = true);
                  }
                },
                style: _buttonStyle(),
                child: Text(
                  'Send OTP',
                  style: AppTextStyle.medium(size: 12.sp, color: Colors.white),
                ),
              ),
            ),
_buildGoToLogin(context)
          ],
        ),
      ),
    );
  }

  // ─── Step 2: OTP Card ─────────────────────────────────────────────────────

  Widget _buildOtpCard(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildHeader(context)),


          Text('Verify OTP', style: AppTextStyle.medium(weight: FontWeight.bold)),
          SizedBox(height: 0.5.h),
          Text(
            'OTP sent to ${_phoneController.text}',
            style: AppTextStyle.medium(size: 10.sp, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          Text('Enter OTP', style: AppTextStyle.medium()),
          const SizedBox(height: 8),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '6-digit OTP',
              hintStyle: AppTextStyle.medium(
                size: 11.sp,
                color: AppColors.grey,
              ),
              prefixIcon: const Icon(
                Icons.lock_clock_outlined,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          SizedBox(height: 0.5.h),

          // Resend OTP
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: call resendOtp()
              },
              child: Text(
                'Resend OTP',
                style: AppTextStyle.medium(
                  size: 10.sp,
                  color: const Color(0xFF1ABC9C),
                ),
              ),
            ),
          ),

          SizedBox(height: 1.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: call verifyOtp()
                setState(() => _otpVerified = true);
              },
              style: _buttonStyle(),
              child: Text(
                'Verify OTP',
                style: AppTextStyle.medium(size: 12.sp, color: Colors.white),
              ),
            ),
          ),

          SizedBox(height: 1.h),

          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _otpSent = false;
                _otpController.clear();
              }),
              child: Text(
                '← Change Phone Number',
                style: AppTextStyle.medium(size: 10.sp, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 3: New Password Card ────────────────────────────────────────────

  Widget _buildNewPasswordCard(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildHeader(context)),


          Text('Reset Password', style: AppTextStyle.medium(weight: FontWeight.bold)),
          SizedBox(height: 0.5.h),
          Text(
            'Create a new password for your account.',
            style: AppTextStyle.medium(size: 10.sp, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // New Password
          Text('New Password', style: AppTextStyle.medium()),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            decoration: InputDecoration(
              hintText: 'Enter new password',
              hintStyle: AppTextStyle.medium(
                size: 11.sp,
                color: AppColors.grey,
              ),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Confirm Password
          Text('Confirm Password', style: AppTextStyle.medium()),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              hintText: 'Re-enter new password',
              hintStyle: AppTextStyle.medium(
                size: 11.sp,
                color: AppColors.grey,
              ),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: call resetPassword()
                // On success → Navigator.pop(context) or go to login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              style: _buttonStyle(),
              child: Text(
                'Reset Password',
                style: AppTextStyle.medium(size: 12.sp, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          _buildGoToLogin(context)
        ],
      ),
    );
  }

  // --------go to login-----------------
  Widget _buildGoToLogin(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Wait, I remember my password... ',
            style: AppTextStyle.medium(size: 9.75.sp, color: Colors.grey),
          ),
           TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      child:

          Text('Click here',style:AppTextStyle.link(size: 9.75.sp)),
     ) ],
      );
    
  }

  // ─── Shared Widgets ───────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Image.asset(AssetResources.logo, width: 11.w);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        blurRadius: 20,
        color: Colors.black.withOpacity(0.1),
        offset: const Offset(0, 10),
      ),
    ],
  );

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14),
    backgroundColor: const Color(0xFF1ABC9C),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );

  Widget _buildBackground() {
    return Column(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A4F7A), Color(0xFF1E3A5F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Expanded(child: Container(color: AppColors.background)),
      ],
    );
  }
}

// ─── Wave Clipper ─────────────────────────────────────────────────────────────

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 80)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - 80,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
