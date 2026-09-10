import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/notificatoin/controllers/notificatoin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificatoinView extends StatelessWidget {
  NotificatoinView({super.key});

  final controller = Get.put(NotificatoinController());

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,

      // Keep TRUE
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: CustomAppBar(
        title: 'Notification',
          subtitle: 'You have ${controller.likes.length} notifications',
        onBackPressed: () {
          Get.back();
        },
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BACKGROUND IMAGE
          // ======================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/LoginBack2.png',
              fit: BoxFit.cover,
            ),
          ),

          // ======================================================
          // WHITE OVERLAY
          // ======================================================

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          Positioned.fill(
            child: SafeArea(
              top: false,
              child: Obx(
                    () {
                  // ==================================================
                  // LOADING
                  // ==================================================

                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffFF6A00),
                      ),
                    );
                  }

                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.red,
                              ),
                            ),

                            SizedBox(height: 12.h),

                            TextButton(
                              onPressed: controller.refresh,
                              child: Text(
                                'Retry',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xffFF6A00),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ==================================================
                  // EMPTY
                  // ==================================================

                  if (controller.likes.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications yet',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: const Color(0xff8F8F8F),
                        ),
                      ),
                    );
                  }

                  // ==================================================
                  // NOTIFICATION DATA
                  // ==================================================

                  return RefreshIndicator(
                    color: const Color(0xffFF6A00),
                    onRefresh: controller.refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        28.w,
                        120.h,
                        28.w,
                        90.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          // ==================================================
                          // HEADER - WHITE CONTAINER KE UPAR
                          // ==================================================

                          SizedBox(
                            width: 320.w,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                // ICON
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFFE0CC),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: const Color(0xFFFF6B00),
                                    size: 22.sp,
                                  ),
                                ),

                                SizedBox(width: 14.w),

                                // TITLE + SUBTITLE
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        "Notifications",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                          color: Colors.black,
                                        ),
                                      ),

                                      SizedBox(height: 4.h),

                                      Text(
                                        "Stay updated with your latest activity.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 9.sp,
                                          color: Colors.black54,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // ==================================================
                          // WHITE CONTENT CONTAINER
                          // ==================================================

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              20.h,
                              16.w,
                              20.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: const Color(0xFFF1E8E4),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.035),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 3.h),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // ==================================================
                                // NEW
                                // ==================================================

                                if (controller.newNotifications.isNotEmpty) ...[
                                  Text(
                                    'New',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(height: 12.h),

                                  ...controller.newNotifications.map(
                                        (e) => _notificationCard(e),
                                  ),

                                  SizedBox(height: 20.h),
                                ],

                                // ==================================================
                                // EARLIER
                                // ==================================================

                                if (controller.earlierNotifications.isNotEmpty) ...[
                                  Text(
                                    'Earlier',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(height: 12.h),

                                  ...controller.earlierNotifications.map(
                                        (e) => _notificationCard(e),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // NOTIFICATION CARD
  // ==============================================================

  Widget _notificationCard(LikeModel item) {
    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(
        bottom: 12.h,
      ),

      padding: EdgeInsets.all(
        14.w,
      ),

      decoration: BoxDecoration(
        color: const Color(0xffFAFAFA),
        borderRadius: BorderRadius.circular(15.r),

        border: Border.all(
          color: const Color(0xFFF1E8E4),
          width: 0.8,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ========================================================
          // PROFILE IMAGE
          // ========================================================

          CircleAvatar(
            radius: 24.r,
            backgroundColor: const Color(0xffF2F2F2),

            backgroundImage:
            (item.image != null && item.image!.isNotEmpty)
                ? NetworkImage(item.image!)
                : const AssetImage(
              'assets/images/default_profile.png',
            ) as ImageProvider,
          ),

          SizedBox(width: 14.w),

          // ========================================================
          // NAME + MESSAGE
          // ========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1F1F1F),
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  item.message ?? 'Liked your profile',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xff7A7A7A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // ========================================================
          // TIME + UNREAD
          // ========================================================

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.createdAt != null
                    ? _timeAgo(item.createdAt!)
                    : '',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: const Color(0xff9B9B9B),
                ),
              ),

              if (item.isUnread) ...[
                SizedBox(height: 8.h),

                Container(
                  height: 8.h,
                  width: 8.w,
                  decoration: const BoxDecoration(
                    color: Color(0xffFF6A00),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // TIME AGO
  // ==============================================================

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'now';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }

    return '${diff.inDays}d ago';
  }
}