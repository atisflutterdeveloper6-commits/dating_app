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
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 14.sp,
              color: Colors.black,
            ),
          ),
        ),
        title: Text(
          'Notification',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1F1F1F),
          ),
        ),
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
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

        // Data state
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 18.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.newNotifications.isNotEmpty) ...[
                  Text(
                    'New',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...controller.newNotifications
                      .map((e) => _notificationCard(e)),
                  SizedBox(height: 28.h),
                ],
                if (controller.earlierNotifications.isNotEmpty) ...[
                  Text(
                    'Earlier',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...controller.earlierNotifications
                      .map((e) => _notificationCard(e)),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _notificationCard(LikeModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: (item.image != null && item.image!.isNotEmpty)
                ? NetworkImage(item.image!)
                : const AssetImage('assets/images/default_profile.png')
                    as ImageProvider,
          ),
          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1F1F1F),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.message ?? 'Liked your profile',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xff8F8F8F),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.createdAt != null
                    ? _timeAgo(item.createdAt!)
                    : '',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: const Color(0xff9B9B9B),
                ),
              ),
              if (item.isUnread) ...[
                SizedBox(height: 8.h),
                Container(
                  height: 8.h,
                  width: 8.w,
                  decoration: const BoxDecoration(
                    color: Color(0xffFF7A00),
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

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}