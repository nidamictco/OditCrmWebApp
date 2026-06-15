// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:Odit_CRM/core/theme/app_colors.dart';
// import 'package:Odit_CRM/core/theme/app_text_style.dart';
// import 'package:Odit_CRM/feature/auth/cubit/auth_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
// import 'package:sizer/sizer.dart';

// class PersonalProfile extends StatefulWidget {
//   const PersonalProfile({super.key});

//   @override
//   State<PersonalProfile> createState() => _PersonalProfileState();
// }

// class _PersonalProfileState extends State<PersonalProfile> {
//   int selectedTab = 0;

//   // Switch states
//   bool newLead = true;
//   bool facebookLead = true;
//   bool transferLead = true;

//   bool whatsapp = false;
//   bool cloudCall = true;
//   bool phoneCall = false;
//   bool autoAssign = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 // ── Blue gradient header ──
//                 _header(),
//                 // ── Card overlapping the header ──
//                 Positioned(
//                   top: 10.h, // starts 10h from top of header (overlaps bottom)
//                   left: 4.w,
//                   right: 4.w,
//                   child: BlocBuilder<AuthCubit, AuthState>(
//                     builder: (context, state) {
//                        if (state is! Authenticated)
//                         return const SizedBox.shrink();
//                       final user = state.user;
//                       return _cardContainer(context, user.name, user.staffType ?? '', user);
//                     },
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 8.h),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔷 TOP HEADER
//   Widget _header() {
//     return Container(
//       height: 18.h,
//       width: double.infinity,
//       decoration: BoxDecoration(gradient: AppColors.gradientBlue),
//     );
//   }

//   /// 🔷 MAIN CARD
//   Widget _cardContainer(
//     BuildContext context,
//     String name,
//     String role,
//     StaffModel user,
//   ) {
//     final hasImage = user.imageUrl != null && user.imageUrl!.trim().isNotEmpty;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4.w),
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(3.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(5),
//           boxShadow: [
//             BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _tabs(),
//             SizedBox(height: 1.h),
//             Center(
//               child: Column(
//                 children: [
//                   _buildProfileImage(hasImage, user),
//                   SizedBox(height: 1.h),
//                   Text(
//                     '$name',
//                     style: AppTextStyle.medium(weight: FontWeight.w600),
//                   ),
//                   Text(
//                     '$role',
//                     style: AppTextStyle.medium(color: AppColors.grey),
//                   ),
//                 ],
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Column(
//                         children: [
//                           Text('Name', style: AppTextStyle.medium()),
//                           SizedBox(height: 0.5.h),
//                           TextField(
//                             enabled: false,
//                             decoration: InputDecoration(
//                               hintText: user.name,
//                               border: OutlineInputBorder(),
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 2.w,
//                                 vertical: 1.5.h,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(width: 4.w),
//                       Column(
//                         children: [
//                           Text('Phone Number', style: AppTextStyle.medium()),
//                           SizedBox(height: 0.5.h),
//                           TextField(
//                             enabled: false,
//                             decoration: InputDecoration(
//                               hintText: user.phone,
//                               border: OutlineInputBorder(),
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 2.w,
//                                 vertical: 1.5.h,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 1.h),
//                   Column(
//                     children: [
//                       Text('Email ', style: AppTextStyle.medium()),
//                       SizedBox(height: 0.5.h),
//                       TextField(
//                         enabled: false,
//                         decoration: InputDecoration(
//                           hintText: user.email,
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 2.w,
//                             vertical: 1.5.h,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 1.h,),
//                   InkWell(
//                     onTap: () {
//                       // Handle edit profile action
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Text('Edit Profile', style: AppTextStyle.medium(color: Colors.white),),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔷 TAB BAR
//   Widget _tabs() {
//     return Column(
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Personal Details',
//               style: AppTextStyle.medium(
//                 color: AppColors.primary,
//                 weight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 0.7.h),
//             Container(height: 2, width: 15.w, color: AppColors.primary),
//           ],
//         ),

//         Divider(height: 1, thickness: 1, color: AppColors.divider),
//       ],
//     );
//   }

//   Widget _buildProfileImage(bool hasImage, StaffModel user) {
//     if (!hasImage) {
//       return CircleAvatar(
//         radius: 3.h,
//         backgroundColor: Colors.grey.shade200,
//         child: Icon(Icons.person, size: 12.sp, color: Colors.grey),
//       );
//     }

//     return CircleAvatar(
//       radius: 3.h,
//       backgroundColor: Colors.grey.shade200,
//       child: ClipOval(
//         child: Image.network(
//           user.imageUrl!,
//           width: 6.h,
//           height: 6.h,
//           fit: BoxFit.cover,
//           // Shows a subtle shimmer/spinner while loading on web
//           loadingBuilder: (context, child, progress) {
//             if (progress == null) return child;
//             return Center(
//               child: SizedBox(
//                 width: 14,
//                 height: 14,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.grey.shade400,
//                 ),
//               ),
//             );
//           },
//           // Falls back to person icon if URL is broken or CORS fails
//           errorBuilder: (context, error, stack) {
//             return Icon(Icons.person, size: 12.sp, color: Colors.grey);
//           },
//         ),
//       ),
//     );
//   }

//   PopupMenuItem<String> _buildMenuItem(
//     IconData icon,
//     String text, {
//     bool isLogout = false,
//   }) {
//     return PopupMenuItem<String>(
//       value: text,
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: isLogout ? Colors.red : Colors.grey[700]),
//           const SizedBox(width: 10),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 13,
//               color: isLogout ? Colors.red : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'package:sizer/sizer.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  // Holds the latest fetched staff — starts from AuthCubit, refreshed from Firestore
  StaffModel? _freshUser;

  @override
  void initState() {
    super.initState();
    // Fetch fresh data from Firestore as soon as screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated && authState.user.id != null) {
        context.read<StaffCubit>().getStaff(authState.user.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffState>(
      listener: (context, state) {
        // When fresh data arrives, store it locally
        if (state is StaffLoaded) {
          setState(() => _freshUser = state.staff);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) return const SizedBox.shrink();

            // Use fresh fetched user if available, else fall back to auth user
            final user = _freshUser ?? authState.user;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _header(),
                      Positioned(
                        top: 10.h,
                        left: 4.w,
                        right: 4.w,
                        child: _cardContainer(
                          context,
                          user.name,
                          user.staffType ?? '',
                          user,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 18.h,
      width: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.gradientBlue),
    );
  }

  Widget _cardContainer(
    BuildContext context,
    String name,
    String role,
    StaffModel user,
  ) {
    final hasImage = user.imageUrl != null && user.imageUrl!.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _tabs(),
            SizedBox(height: 1.h),
            Center(
              child: Column(
                children: [
                  // Show spinner while fetching fresh image
                  BlocBuilder<StaffCubit, StaffState>(
                    builder: (context, state) {
                      if (state is StaffLoading && _freshUser == null) {
                        return CircleAvatar(
                          radius: 3.h,
                          backgroundColor: Colors.grey.shade200,
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      }
                      return _buildProfileImage(hasImage, user);
                    },
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    name,
                    style: AppTextStyle.medium(weight: FontWeight.w600),
                  ),
                  Text(role, style: AppTextStyle.medium(color: AppColors.grey)),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        // ✅ gives bounded width
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name', style: AppTextStyle.medium()),
                            SizedBox(height: 0.5.h),
                            TextField(
                              enabled: false,
                              style: AppTextStyle.medium(size: 12.5),
                              decoration: InputDecoration(
                                hintText: user.name,
                                hintStyle: AppTextStyle.medium(size: 12.5),
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.5.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        // ✅ same here
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone Number', style: AppTextStyle.medium()),
                            SizedBox(height: 0.5.h),
                            TextField(
                              enabled: false,
                              style: AppTextStyle.medium(size: 12.5),
                              decoration: InputDecoration(
                                hintText: user.phone,
                                hintStyle: AppTextStyle.medium(size: 12.5),
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.5.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email', style: AppTextStyle.medium()),
                      SizedBox(height: 0.5.h),
                      SizedBox(
                        width: 30.5.w,
                        child: TextField(
                          enabled: false,
                          style: AppTextStyle.medium(size: 12.5),
                          decoration: InputDecoration(
                            hintText: user.email,
                            hintStyle: AppTextStyle.medium(size: 12.5),
                            border: const OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 1.h),
                  // InkWell(
                  //   onTap: () {
                  //     // Handle edit profile action
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: 4.w,
                  //       vertical: 1.5.h,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: AppColors.primary,
                  //       borderRadius: BorderRadius.circular(5),
                  //     ),
                  //     child: Text(
                  //       'Edit Profile',
                  //       style: AppTextStyle.medium(color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Details',
              style: AppTextStyle.medium(
                color: AppColors.primary,
                weight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.7.h),
            Container(height: 2, width: 15.w, color: AppColors.primary),
          ],
        ),
        Divider(height: 1, thickness: 1, color: AppColors.divider),
      ],
    );
  }

  Widget _buildProfileImage(bool hasImage, StaffModel user) {
    if (!hasImage) {
      return CircleAvatar(
        radius: 6.h,
        backgroundColor: Colors.grey.shade200,
        child: Icon(Icons.person, size: 19.sp, color: Colors.grey),
      );
    }

    return CircleAvatar(
      radius: 6.h,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.network(
          user.imageUrl!,
          width: 12.h,
          height: 12.h,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) =>
              Icon(Icons.person, size: 12.sp, color: Colors.grey),
        ),
      ),
    );
  }
}
