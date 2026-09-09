import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final Widget? prefixIcon;
  final bool isLoading;

  final bool enabled;
  final bool showArrow;
  final Widget? suffixIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xffFF6B00),
    this.textColor = Colors.white,
    this.height = 50,
    this.borderRadius = 35,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.letterSpacing = 0,
    this.prefixIcon,
    this.isLoading = false,
    this.enabled = true,
    this.showArrow = true,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isLoading || !enabled;

    final Color lightShade = Color.lerp(
      backgroundColor,
      Colors.white,
      0.25,
    )!;

    return SizedBox(
      width: double.infinity,
      height: height.h,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isDisabled
                ? [
              Colors.grey.shade300,
              Colors.grey.shade300,
            ]
                : [
              backgroundColor,
              backgroundColor,
              lightShade,
            ],
            stops: isDisabled ? null : const [0.0, 0.72, 1.0],
          ),
          borderRadius: BorderRadius.circular(borderRadius.r),
          boxShadow: isDisabled
              ? []
              : [
            BoxShadow(
              color: backgroundColor.withOpacity(0.22),
              blurRadius: 12.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius.r),
            ),
          ),
          child: isLoading
              ? SizedBox(
            width: 22.w,
            height: 22.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                SizedBox(width: 8.w),
              ],

              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                  fontWeight: fontWeight,
                  letterSpacing: letterSpacing,
                ),
              ),

              if (suffixIcon != null) ...[
                SizedBox(width: 9.w),
                suffixIcon!,
              ] else if (showArrow) ...[
                SizedBox(width: 9.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: textColor,
                  size: 16.sp,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}