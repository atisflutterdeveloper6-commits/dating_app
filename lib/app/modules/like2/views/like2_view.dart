import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/models/profile_all_model.dart';
import 'package:dating_app/app/modules/like2/controllers/like2_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class Like2View extends StatefulWidget {
  const Like2View({super.key});

  @override
  State<Like2View> createState() => _Like2ViewState();
}

class _Like2ViewState extends State<Like2View> {
  late final Like2Controller controller;

  @override
  void initState() {
    super.initState();

    // ✅ FIX: Agar controller pehle se registered hai to wahi reuse karo,
    // naya instance mat banao — isse purana data safe rehta hai aur
    // duplicate controller wala bug nahi aata.
    controller = Get.isRegistered<Like2Controller>()
        ? Get.find<Like2Controller>()
        : Get.put(Like2Controller());

    // ✅ FIX: Har baar jab ye screen (dobara) khulti hai, fresh data laao —
    // chahe controller reused ho ya naya ho. Isse "No liked profiles yet"
    // wala stale-state bug fix ho jaata hai jab user like/unlike karke
    // wapas is screen par aata hai.
    controller.refreshLikedProfiles();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: CustomAppBar(
        title: "Like",
        actions: [
          IconButton(
            onPressed: () => controller.refreshLikedProfiles(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        print(
          '🖼️ BUILD like2 view — isLoading=${controller.isLoading.value}, count=${controller.likedProfiles.length}',
        );

        // Show error state
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.retryFetch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show empty state (only when not loading and no profiles)
        if (!controller.isLoading.value && controller.likedProfiles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No liked profiles yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Start liking profiles to see them here',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        // Show liked profiles grid with shimmer loading
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: GridView.builder(
            itemCount: controller.isLoading.value
                ? 4 // Show 4 shimmer cards while loading
                : controller.likedProfiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 18.h,
              childAspectRatio: 0.90,
            ),
            itemBuilder: (context, index) {
              // Show shimmer while loading
              if (controller.isLoading.value) {
                return _buildShimmerCard(context);
              }

              final profile = controller.likedProfiles[index];
              return _buildLikedProfileCard(context, profile);
            },
          ),
        );
      }),
    );
  }

  /// Build shimmer card for loading state - NO CIRCULAR LOADER
  Widget _buildShimmerCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Stack(
            children: [
              // Image placeholder
              Positioned.fill(
                child: Container(
                  color: Colors.grey[300],
                ),
              ),

              // Gradient overlay placeholder
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),

              // Like icon placeholder (Red Heart)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: Colors.grey[400],
                  child: Icon(
                    Icons.favorite,
                    color: Colors.grey[300],
                    size: 14.sp,
                  ),
                ),
              ),

              // Unlike button placeholder (Close/X Icon)
              Positioned(
                top: 10.h,
                left: 10.w,
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: Colors.grey[400],
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[300],
                    size: 14.sp,
                  ),
                ),
              ),

              // User info placeholder
              Positioned(
                left: 10.w,
                right: 10.w,
                bottom: 10.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name placeholder
                    Container(
                      height: 16.h,
                      width: 80.w,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 4.h),
                    // Bio placeholder
                    Container(
                      height: 12.h,
                      width: 60.w,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build liked profile card - NO CIRCULAR LOADER
  Widget _buildLikedProfileCard(BuildContext context, ProfileModel profile) {
    final imageUrl = controller.getProfileImage(profile);
    final displayName = controller.getDisplayName(profile);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          // Profile Image
          Positioned.fill(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    // 🔥 NO CIRCULAR LOADER - Just solid color
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 50.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 50.sp,
                      color: Colors.grey[600],
                    ),
                  ),
          ),

          // 🔥 FADE OVERLAY - Bottom fade for better text visibility
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
                  stops: const [0.0, 0.4, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Like Icon (Red Heart) - White Background
          Positioned(
            top: 10.h,
            right: 10.w,
            child: GestureDetector(
              onTap: () => _showUnlikeDialog(context, profile.id),
              child: CircleAvatar(
                radius: 14.r,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.favorite,
                  color: Colors.red[700],
                  size: 18.sp,
                ),
              ),
            ),
          ),

          // User Info - Now with better visibility
          Positioned(
            left: 10.w,
            right: 10.w,
            bottom: 10.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (profile.bio != null && profile.bio!.isNotEmpty)
                  Text(
                    profile.bio!,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 8.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show unlike confirmation dialog
  void _showUnlikeDialog(BuildContext context, String? profileId) {
    if (profileId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.red[700],
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Unlike Profile',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to unlike this profile?',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
              controller.unlikeProfile(profileId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffFF6B00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 10.h,
              ),
            ),
            child: Text(
              'Unlike',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}