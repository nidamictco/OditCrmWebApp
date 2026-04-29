import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔵 Background
          _buildBackground(),

          // 🟦 Content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLoginCard(),
                  SizedBox(height: 1.h),
                  Text(
                    "© 2026. Crafted with ❤️ by Mictco It Solutions",
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

  // 🌊 Background with gradient + wave
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
                colors: [Color(0xFF3A4F7A), Color(0xFF2F3E66)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Optional overlay dots
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.network(
                      "https://www.transparenttextures.com/patterns/stardust.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: Container(color: const Color(0xFFF3F3F3))),
      ],
    );
  }

  // 🧾 Login Card
  Widget _buildLoginCard() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔷 Logo
          Center(
            child: Column(
              children: [
                Text(
                  "OXDO",
                  style: AppTextStyle.heading(
                    weight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                // SizedBox(height: 0.5.h),
                Text(
                  "Technology Pvt Ltd.",
                  style: AppTextStyle.heading(color: Colors.grey, size: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Username
          Text("Username", style: AppTextStyle.medium()),
          const SizedBox(height: 8),
          _inputField("Enter username"),

          const SizedBox(height: 16),

          // Password
          Text("Password", style: AppTextStyle.medium()),
          SizedBox(height: 0.5.h),
          _inputField("Enter password", isPassword: true),

          SizedBox(height: 1.5.h),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Forgot password?",
              style: AppTextStyle.medium(
                size: 10.sp,
                color: Colors.grey,
                weight: FontWeight.w400,
              ),
            ),
          ),

          SizedBox(height: 1.3.h),

          // 🔘 Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF1ABC9C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                "Sign In",
                style: AppTextStyle.medium(size: 12.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔤 Input Field
  Widget _inputField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
        suffixIcon: isPassword ? const Icon(Icons.visibility_outlined) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

/// 🌊 Custom Wave Clipper
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 80);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
