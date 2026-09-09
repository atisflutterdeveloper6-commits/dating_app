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

  static const Color orangeColor = Color(0xffFF6B00);

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
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: CustomAppBar(
        title: "Inbox",
        onBackPressed: () {
          Get.find<DashboardController>().changeTab(0);
        },
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==========================================================
          // BACKGROUND IMAGE
          // ==========================================================

          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================================
          // WHITE OPACITY OVERLAY
          // ==========================================================

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // ==========================================================
          // CONTENT
          // ==========================================================

          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // ==================================================
                  // SEARCH BAR
                  // ==================================================

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14.w,
                      14.h,
                      14.w,
                      12.h,
                    ),
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.75),
                          width: 0.8.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (value) {
                          controller.filterChats(value);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,

                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14.h,
                          ),

                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color(0xff8E8E8E),
                            size: 22.sp,
                          ),

                          hintText: 'Search',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: const Color(0xff9E9E9E),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: const Color(0xff222222),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // CHAT LIST
                  // ==================================================

                  Expanded(
                    child: Obx(
                          () {
                        // ============================================
                        // LOADING
                        // ============================================

                        if (controller.isLoading.value &&
                            controller.filteredChats.isEmpty) {
                          return Center(
                            child: Container(
                              height: 90.w,
                              width: 90.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.88),
                                borderRadius:
                                BorderRadius.circular(20.r),
                                border: Border.all(
                                  color:
                                  Colors.white.withOpacity(0.75),
                                  width: 0.8.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: orangeColor,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          );
                        }

                        // ============================================
                        // EMPTY STATE
                        // ============================================

                        if (controller.filteredChats.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30.w,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 28.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  Colors.white.withOpacity(0.88),
                                  borderRadius:
                                  BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color:
                                    Colors.white.withOpacity(0.75),
                                    width: 0.8.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withOpacity(0.06),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 72.w,
                                      width: 72.w,
                                      decoration: BoxDecoration(
                                        color: orangeColor
                                            .withOpacity(0.10),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.chat_bubble_outline,
                                        size: 36.sp,
                                        color: orangeColor,
                                      ),
                                    ),

                                    SizedBox(height: 16.h),

                                    Text(
                                      'No Chats Yet',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color:
                                        const Color(0xff2B2B2B),
                                      ),
                                    ),

                                    SizedBox(height: 6.h),

                                    Text(
                                      'Start a conversation with someone new!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color:
                                        const Color(0xff8E8E8E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        // ============================================
                        // CHAT LIST
                        // ============================================

                        return ListView.builder(
                          physics:
                          const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            14.w,
                            2.h,
                            14.w,
                            40.h,
                          ),
                          itemCount:
                          controller.filteredChats.length,
                          itemBuilder: (context, index) {
                            final item =
                            controller.filteredChats[index];

                            final imagePath =
                            (item['image'] ?? '').toString();

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
                                margin: EdgeInsets.only(
                                  bottom: 10.h,
                                ),
                                padding: EdgeInsets.all(13.w),
                                decoration: BoxDecoration(
                                  color:
                                  Colors.white.withOpacity(0.88),
                                  borderRadius:
                                  BorderRadius.circular(18.r),
                                  border: Border.all(
                                    color:
                                    Colors.white.withOpacity(0.75),
                                    width: 0.8.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // =================================
                                    // USER IMAGE
                                    // =================================

                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(2.w),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: orangeColor
                                                  .withOpacity(0.30),
                                              width: 1.w,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 26.r,
                                            backgroundImage:
                                            imagePath
                                                .startsWith(
                                                'http')
                                                ? NetworkImage(
                                              imagePath,
                                            )
                                                : const AssetImage(
                                              'assets/images/profile1.png',
                                            ),
                                          ),
                                        ),

                                        // ONLINE DOT

                                        if (item['online'] == true)
                                          Positioned(
                                            bottom: 1.h,
                                            right: 0,
                                            child: Container(
                                              height: 12.h,
                                              width: 12.w,
                                              decoration:
                                              BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    SizedBox(width: 13.w),

                                    // =================================
                                    // NAME + MESSAGE
                                    // =================================

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'] ?? '',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style:
                                            GoogleFonts.poppins(
                                              letterSpacing: 1.1.w,
                                              fontSize: 14.sp,
                                              fontWeight:
                                              FontWeight.w600,
                                              color:
                                              const Color(0xff222222),
                                            ),
                                          ),

                                          SizedBox(height: 3.h),

                                          Text(
                                            item['lastMessage'] ??
                                                'No messages yet',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style:
                                            GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              color:
                                              const Color(0xff8E8E8E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 8.w),

                                    // =================================
                                    // TIME + UNREAD
                                    // =================================

                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item['time'] ??
                                              'Just now',
                                          style:
                                          GoogleFonts.poppins(
                                            fontSize: 10.sp,
                                            color:
                                            const Color(0xff8E8E8E),
                                          ),
                                        ),

                                        SizedBox(height: 7.h),

                                        if ((item['unreadCount'] ??
                                            0) >
                                            0)
                                          Container(
                                            height: 21.h,
                                            width: 21.w,
                                            alignment:
                                            Alignment.center,
                                            decoration:
                                            const BoxDecoration(
                                              color: orangeColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              item['unreadCount']
                                                  .toString(),
                                              style:
                                              GoogleFonts.poppins(
                                                fontSize: 10.sp,
                                                fontWeight:
                                                FontWeight.w600,
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
            ),
          ),
        ],
      ),
    );
  }
}