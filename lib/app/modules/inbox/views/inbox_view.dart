import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/chat/views/chat_view.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/inbox/controllers/inbox_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InboxView extends StatelessWidget {
  InboxView({super.key});

  final controller = Get.put(InboxController());

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: CustomAppBar(
        title: "Inbox",
        onBackPressed: () {
          Get.find<DashboardController>().changeTab(0);
        },
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xffF1F1F5),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  controller.filterChats(value);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xff9E9E9E),
                  ),
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: const Color(0xff9E9E9E),
                  ),
                ),
              ),
            ),
          ),

          // Chat List
          Expanded(
            child: Obx(
              () {
                // ✅ Show loading
                if (controller.isLoading.value && controller.filteredChats.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xffFF6B00),
                    ),
                  );
                }

                // ✅ Show empty state
                if (controller.filteredChats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Chats Yet',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Start a conversation with someone new!',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ✅ Show chat list
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: controller.filteredChats.length,
                  itemBuilder: (context, index) {
                    final item = controller.filteredChats[index];
                    final imagePath = (item['image'] ?? '').toString();

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => ChatView(),
                          arguments: {
                            'userId': item['userId'],
                            'userName': item['name'],
                            'userImage': item['image'],
                            'chatRoomId': item['roomId'],
                          },
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // ✅ User Avatar with Online Status
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 26.r,
                                  backgroundImage: imagePath.startsWith('http')
                                      ? NetworkImage(imagePath) as ImageProvider
                                      : const AssetImage('assets/images/profile1.png'),
                                ),
                                if (item['online'] == true)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 12.h,
                                      width: 12.w,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            SizedBox(width: 14.w),

                            // ✅ User Name & Last Message
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: GoogleFonts.poppins(
                                      letterSpacing: 1.5.w,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff222222),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    item['lastMessage'] ?? 'No messages yet',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: const Color(0xff9E9E9E),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // ✅ Time & Unread Count
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item['time'] ?? 'Just now',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: const Color(0xff9E9E9E),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                if (item['unreadCount'] > 0)
                                  Container(
                                    height: 22.h,
                                    width: 22.w,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Color(0xffFF6B00),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      item['unreadCount'].toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}