import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomToast {
  // Success Toast
  static void success(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xffFF6B00),
      textColor: Colors.white,
      fontSize: 12.sp,
    );
  }

  // Error Toast
  static void error(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xffFF6B00),
      textColor: Colors.white,
      fontSize: 12.sp,
    );
  }

  // Warning Toast
  static void warning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xffFF6B00),
      textColor: Colors.white,
      fontSize: 12.sp,
    );
  }

  // Info Toast
  static void info(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 12.sp,
    );
  }

  // Custom Toast (Full Control)
  static void show({
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.TOP,
    int duration = 2,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration > 2 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 12.sp,
      timeInSecForIosWeb: duration,
    );
  }
}