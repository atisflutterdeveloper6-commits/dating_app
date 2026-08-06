import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; // optional right-side widgets
  final VoidCallback? onBackPressed; // optional back button action

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil (Safe to call here)
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      surfaceTintColor: Colors.white,
      elevation: 0,
      leadingWidth: 70.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 5.w),
        child: InkWell(
          borderRadius: BorderRadius.circular(100.r),
          onTap: onBackPressed ?? () => Get.back(), // Use custom action if provided, else default
          child: Center(
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xffE5E5E5),
                  width: 1.w,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          letterSpacing: 1.5.w,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      actions: actions != null
          ? [
              Padding(
                padding: EdgeInsets.only(right: 14.w),
                child: Row(
                  children: actions!,
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}