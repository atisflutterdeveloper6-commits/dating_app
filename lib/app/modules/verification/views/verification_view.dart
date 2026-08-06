import 'dart:io';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../../custom_widget/custom_appbar.dart';


class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  File? selectedDocument;
  File? selfieImage;
  final ImagePicker picker = ImagePicker();
  
  // Get controller
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();
  
  bool _isSubmitting = false;

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
      appBar: const CustomAppBar(title: "Verification"),
      bottomNavigationBar: Container(
        color: Colors.transparent,
      
        child: Padding(
        
          padding: EdgeInsets.all(16.w),
          child: SafeArea(
            child: SizedBox(
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF6A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitVerification,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "Submit",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    
    
      body: Obx(() => SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message if any
            if (profileController.errorMessage.value.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        profileController.errorMessage.value,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Why Verify
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xffFFF4EB),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: const Color(0xffFFD6B5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: const Color(0xffFF6A00), size: 22.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Why Verify?",
                          style: GoogleFonts.poppins(
                            letterSpacing: 1.5.w,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Verify Your Identity For Build Trust.",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 25.h),

            // Verify Your Identity Heading
            Text(
              "Verify Your Identity",
              style: GoogleFonts.poppins(
                letterSpacing: 1.5.w,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Choose Any One Option To Verify",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 25.h),

            // Verify Document
            Row(
              children: [
                Text(
                  "Verify Document",
                  style: GoogleFonts.poppins(
                    letterSpacing: 1.5.w,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(width: 15.w),
                Text(
                  "Recommended",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              "Upload your government-issued ID like Aadhaar, PAN, Driving License or Passport.",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12.h),

            DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: Radius.circular(16.r),
                dashPattern: const [8, 4],
                color: Colors.grey,
                strokeWidth: 1.5.w,
                padding: EdgeInsets.zero,
              ),
              child: Container(
                width: double.infinity,
                child: selectedDocument == null
                    ? Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 30.sp, color: Colors.grey),
                            SizedBox(height: 8.h),
                            Text(
                              "select your file or drag and drop",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "pdf, jpg, docx accepted",
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Center(
                              child: ElevatedButton(
                                onPressed: pickDocument,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffFF6A00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                  minimumSize: Size(120.w, 40.h),
                                ),
                                child: Text(
                                  "Browse",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              selectedDocument!,
                              width: double.infinity,
                              height: 180.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDocument = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            SizedBox(height: 25.h),

            // Verify Photo (Selfie)
            Text(
              "Verify Photo (Selfie)",
              style: GoogleFonts.poppins(
                letterSpacing: 1.5.w,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Upload your government-issued ID like Aadhaar, PAN, Driving License or Passport.",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12.h),

            GestureDetector(
              onTap: pickSelfie,
              child: Container(
                width: double.infinity,
                height: 130.h,
                alignment: Alignment.center,
                child: selfieImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 80.h,
                                width: 80.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF0E6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 28.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Positioned(
                                bottom: -2.h,
                                right: -2.w,
                                child: Container(
                                  height: 24.h,
                                  width: 24.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xffEAEAEA),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 16.sp,
                                    color: const Color(0xFFFF6A00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Add Photo (Selfie)",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40.r,
                            backgroundColor: const Color(0xFFFFF0E6),
                            backgroundImage: FileImage(selfieImage!),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selfieImage = null;
                                });
                              },
                              child: Container(
                                height: 28.h,
                                width: 28.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xffEAEAEA),
                                    width: 1.w,
                                  ),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            SizedBox(height: 16.h),

            // Secure Message
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 18.sp, color: Colors.green),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      "Your information is secure and encrypted. We never share your data with anyone.",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      )),
    );
  }

  Future<void> pickDocument() async {
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() {
        selectedDocument = File(file.path);
      });
    }
  }

  Future<void> pickSelfie() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        selfieImage = File(image.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    // Validate at least one verification method is selected
    if (selectedDocument == null && selfieImage == null) {
      Get.snackbar(
        'Error',
        'Please upload a document or take a selfie to verify your identity.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await profileController.updateVerification(
        document: selectedDocument,
        selfie: selfieImage,
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Verification submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 3),
        );
        
        // Navigate back or to next screen
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        Get.snackbar(
          'Error',
          profileController.errorMessage.value.isNotEmpty
              ? profileController.errorMessage.value
              : 'Failed to submit verification. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}