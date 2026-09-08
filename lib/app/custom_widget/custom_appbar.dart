import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? rightImage;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  /// When true, ignores [rightImage] and renders the coded
  /// photo-stack + camera + sparkles illustration instead.
  final bool useIllustration;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.rightImage,
    this.actions,
    this.onBackPressed,
    this.useIllustration = false,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return AppBar(
      // ============================================================
      // GRADIENT BACKGROUND (rounded bottom corners)
      // ============================================================

      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,

      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromARGB(255, 253, 242, 234),
              Color.fromARGB(255, 253, 242, 234),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
        ),
      ),

      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,

        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,

        systemNavigationBarIconBrightness: Brightness.dark,
      ),

      // ============================================================
      // APP BAR HEIGHT
      // ============================================================

      toolbarHeight: 64.h,

      // ============================================================
      // BACK BUTTON
      // ============================================================

      leadingWidth: 56.w,

      leading: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(50.r),
            onTap: onBackPressed ?? () => Get.back(),
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFEDEDED),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 21.sp,
                  color: const Color(0xFFFF6B00),
                ),
              ),
            ),
          ),
        ),
      ),

      // ============================================================
      // TITLE + SUBTITLE
      // ============================================================

      titleSpacing: 0,

      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF172033),
              height: 1.15,
            ),
          ),

          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 3.h),

            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF777777),
                height: 1.15,
              ),
            ),
          ],
        ],
      ),

      // ============================================================
      // RIGHT SIDE — ILLUSTRATION OR IMAGE
      // ============================================================

      actions: [
        if (useIllustration)
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: const _PhotoStackIllustration(),
          )
        else if (rightImage != null && rightImage!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: SizedBox(
              width: 82.w,
              height: 64.h,
              child: Image.asset(
                rightImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),

        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(64.h);
}

// ============================================================
// PHOTO STACK ILLUSTRATION (photos + camera badge + sparkles)
// ============================================================

class _PhotoStackIllustration extends StatelessWidget {
  const _PhotoStackIllustration();

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF6B00);

    return SizedBox(
      width: 80.w,
      height: 60.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ---------------------------------------------------
          // Big sparkle, left of the stack
          // ---------------------------------------------------
          Positioned(
            left: -18.w,
            top: 20.h,
            child: Icon(
              Icons.auto_awesome,
              size: 13.sp,
              color: orange.withOpacity(0.55),
            ),
          ),

          // ---------------------------------------------------
          // Small sparkle, top-left of the stack
          // ---------------------------------------------------
          Positioned(
            left: 6.w,
            top: -4.h,
            child: Icon(
              Icons.auto_awesome,
              size: 9.sp,
              color: orange.withOpacity(0.5),
            ),
          ),

          // ---------------------------------------------------
          // Small sparkle, top-right of the stack
          // ---------------------------------------------------
          Positioned(
            right: 4.w,
            top: 2.h,
            child: Icon(
              Icons.auto_awesome,
              size: 8.sp,
              color: orange.withOpacity(0.45),
            ),
          ),

          // ---------------------------------------------------
          // Back card (plain white/grey, tilted left)
          // ---------------------------------------------------
          Positioned(
            left: 14.w,
            top: 6.h,
            child: Transform.rotate(
              angle: -0.16,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFFEDEDED),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---------------------------------------------------
          // Front card (coral photo card, tilted right)
          // ---------------------------------------------------
          Positioned(
            left: 24.w,
            top: 16.h,
            child: Transform.rotate(
              angle: 0.14,
              child: Container(
                width: 34.w,
                height: 34.w,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFB199),
                      Color(0xFFFF6B4A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.image_rounded,
                  size: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),

          // ---------------------------------------------------
          // Camera badge, bottom-right overlapping the cards
          // ---------------------------------------------------
          Positioned(
            right: 2.w,
            bottom: 0,
            child: Container(
              width: 27.w,
              height: 27.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1C4),
                borderRadius: BorderRadius.circular(9.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: orange,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}