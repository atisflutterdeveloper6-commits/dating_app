import 'package:dating_app/app/models/profile_all_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/blockuser_controller.dart';
import '../../../custom_widget/custom_appbar.dart';

class BlockuserView extends StatefulWidget {
  const BlockuserView({super.key});

  @override
  State<BlockuserView> createState() => _BlockUsersViewState();
}

class _BlockUsersViewState extends State<BlockuserView> {
  final BlockuserController controller = Get.put(
    BlockuserController(),
  );

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      // IMPORTANT:
      // Keep this light so no black flash appears during first frame.
      backgroundColor: const Color(0xFFF7F7F7),

      // Keep TRUE as requested.
      extendBodyBehindAppBar: true,

      // Changed TRUE -> FALSE.
      // This prevents the bottom area from becoming transparent/black.
      extendBody: false,

      appBar: const CustomAppBar(
        title: "Block users",
          subtitle: "Users you block will appear here",
      ),

      body: Stack(
        children: [
          // ========================================================
          // FALLBACK BACKGROUND
          // ========================================================

          Positioned.fill(
            child: Container(
              color: const Color(0xFFF7F7F7),
            ),
          ),

          // ========================================================
          // BACKGROUND IMAGE
          // ========================================================

          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  color: const Color(0xFFF7F7F7),
                );
              },
            ),
          ),

          // ========================================================
          // WHITE OVERLAY
          // ========================================================

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          Obx(() {
            // ======================================================
            // ERROR STATE
            // ======================================================

            if (controller.errorMessage.value.isNotEmpty) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  120.h,
                  16.w,
                  90.h,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight:
                    MediaQuery.of(context).size.height - 210.h,
                  ),
                  padding: EdgeInsets.all(20.w),
                  decoration: _mainContainerDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red[300],
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        controller.errorMessage.value,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20.h),

                      ElevatedButton(
                        onPressed: () {
                          controller.fetchBlockedUsers();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xffFF6B00),
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ======================================================
            // EMPTY STATE
            // ======================================================

            if (!controller.isLoading.value &&
                controller.blockedUsers.isEmpty) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  120.h,
                  16.w,
                  90.h,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight:
                    MediaQuery.of(context).size.height - 210.h,
                  ),
                  padding: EdgeInsets.all(20.w),
                  decoration: _mainContainerDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block_outlined,
                        size: 80.sp,
                        color: Colors.grey[400],
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        'No blocked users',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        'Users you block will appear here',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey[500],
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        'You can unblock them anytime',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ======================================================
            // LOADING / USERS
            // ======================================================

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                120.h,
                16.w,
                90.h,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  12.w,
                  16.h,
                  12.w,
                  20.h,
                ),
                decoration: _mainContainerDecoration(),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: controller.isLoading.value
                      ? 4
                      : controller.blockedUsers.length,
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    if (controller.isLoading.value) {
                      return _buildShimmerCard();
                    }

                    final user =
                    controller.blockedUsers[index];

                    return _buildBlockedUserCard(
                      context,
                      user,
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==============================================================
  // MAIN CONTAINER
  // ==============================================================

  BoxDecoration _mainContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: const Color(0xFFF1E8E4),
        width: 0.8.w,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 12.r,
          offset: Offset(0, 3.h),
        ),
      ],
    );
  }

  // ==============================================================
  // SHIMMER CARD
  // ==============================================================

  Widget _buildShimmerCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            children: [
              // Full card
              Positioned.fill(
                child: Container(
                  color: Colors.grey[300],
                ),
              ),

              // Block icon
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block,
                    size: 18.sp,
                    color: Colors.grey,
                  ),
                ),
              ),

              // Bottom placeholder
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 14.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                          BorderRadius.circular(4.r),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Container(
                        height: 10.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                          BorderRadius.circular(4.r),
                        ),
                      ),

                      SizedBox(height: 6.h),

                      Container(
                        height: 24.h,
                        width: 70.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                          BorderRadius.circular(6.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // BLOCKED USER CARD
  // ==============================================================

  Widget _buildBlockedUserCard(
      BuildContext context,
      ProfileModel user,
      ) {
    final displayName =
    controller.getUserDisplayName(user);

    final age =
    controller.getUserAge(user);

    final imageUrl =
    controller.getUserProfileImage(user);

    final hasPhotos =
    controller.hasPhotos(user);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        children: [
          // ========================================================
          // IMAGE
          // ========================================================

          Positioned.fill(
            child: hasPhotos &&
                imageUrl != null &&
                imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return _buildPlaceholder();
              },
              loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                  ) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  color: Colors.grey[300],
                );
              },
            )
                : _buildPlaceholder(),
          ),

          // ========================================================
          // IMAGE DARK GRADIENT
          // ========================================================

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [
                    0.0,
                    0.4,
                    0.6,
                    0.8,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          // ========================================================
          // BLOCK ICON
          // ========================================================

          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block,
                size: 18.sp,
                color: Colors.white,
              ),
            ),
          ),

          // ========================================================
          // USER INFO
          // ========================================================

          Positioned(
            left: 8.w,
            right: 8.w,
            bottom: 8.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius:
                BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(0.2),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                  ),

                  if (age != null)
                    Text(
                      '$age years old',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10.sp,
                      ),
                    ),

                  SizedBox(height: 6.h),

                  InkWell(
                    onTap: () {
                      if (user.id != null) {
                        _showUnblockDialog(
                          context,
                          user.id!,
                        );
                      }
                    },
                    borderRadius:
                    BorderRadius.circular(6.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.15),
                        borderRadius:
                        BorderRadius.circular(6.r),
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block_outlined,
                            color: Colors.white,
                            size: 14.sp,
                          ),

                          SizedBox(width: 6.w),

                          Text(
                            "Unblock",
                            style:
                            GoogleFonts.poppins(
                              letterSpacing: 1.2,
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PLACEHOLDER
  // ==============================================================

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 40.sp,
            color: Colors.grey[400],
          ),

          SizedBox(height: 4.h),

          Text(
            'No Photo',
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // UNBLOCK DIALOG
  // ==============================================================

  void _showUnblockDialog(
      BuildContext context,
      String profileId,
      ) {
    if (profileId.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.block_outlined,
                color: Colors.orange[700],
                size: 24.sp,
              ),

              SizedBox(width: 8.w),

              Text(
                'Unblock User',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to unblock this user? '
                'They will be able to see your profile and interact '
                'with you again.',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                controller.unblockUser(
                  profileId,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xffFF6B00),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 10.h,
                ),
              ),
              child: Text(
                'Unblock',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}