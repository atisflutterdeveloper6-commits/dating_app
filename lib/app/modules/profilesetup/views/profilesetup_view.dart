// lib/app/modules/profilesetup/views/profilesetup_view.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/tellmeaboutyou/views/tellmeaboutyou_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../controllers/profilesetup_controller.dart';

// ========== Shimmer Widget ==========
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = Colors.grey,
    this.highlightColor = Colors.white,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShimmerMask(
          animationValue: _animation.value,
          baseColor: widget.baseColor,
          highlightColor: widget.highlightColor,
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerMask extends StatelessWidget {
  final double animationValue;
  final Color baseColor;
  final Color highlightColor;
  final Widget child;

  const ShimmerMask({
    super.key,
    required this.animationValue,
    required this.baseColor,
    required this.highlightColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        // Create a gradient that moves across the widget
        final double width = bounds.width;
        final double start = animationValue * width;
        final double end = start + width * 0.5;
        
        return LinearGradient(
          colors: [
            baseColor,
            baseColor,
            highlightColor,
            highlightColor,
            baseColor,
            baseColor,
          ],
          stops: const [
            0.0,
            0.2,
            0.3,
            0.7,
            0.8,
            1.0,
          ],
          begin: Alignment(start / width, 0),
          end: Alignment(end / width, 0),
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }
}

// ========== DottedBorder Widget ==========
class DottedBorder extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  const DottedBorder({
    super.key,
    required this.child,
    this.strokeWidth = 1.5,
    this.color = Colors.grey,
    this.radius = 16,
    this.dashWidth = 6,
    this.dashSpace = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        strokeWidth: strokeWidth,
        color: color,
        radius: radius,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      child: child,
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DottedBorderPainter({
    required this.strokeWidth,
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics();
    for (var metric in metrics) {
      double length = metric.length;
      double start = 0;
      while (start < length) {
        final end = math.min(start + dashWidth, length);
        final segment = metric.extractPath(start, end);
        canvas.drawPath(segment, paint);
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

// ========== Main ProfilesetupView ==========
class ProfilesetupView extends StatefulWidget {
  const ProfilesetupView({super.key});

  @override
  State<ProfilesetupView> createState() => _ProfilesetupViewState();
}

class _ProfilesetupViewState extends State<ProfilesetupView> {
  late ProfilesetupController controller;
  
  List<File?> photos = List<File?>.filled(6, null);
  bool isLoading = false;
  int uploadedCount = 0;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ProfilesetupController>()
        ? Get.find<ProfilesetupController>()
        : Get.put(ProfilesetupController());
    _loadPhotos();
  }

  void _loadPhotos() {
    if (controller.photos.isNotEmpty) {
      setState(() {
        photos = List<File?>.from(controller.photos);
        uploadedCount = photos.where((file) => file != null).length;
      });
    }
  }

  Future<void> pickImage(int index) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          photos[index] = File(image.path);
          controller.photos[index] = File(image.path);
          uploadedCount = photos.where((file) => file != null).length;
        });
        CustomToast.success("Image added successfully!");
      }
    } catch (e) {
      CustomToast.error("Failed to pick image");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void removeImage(int index) {
    if (isLoading) return;
    setState(() {
      photos[index] = null;
      controller.photos[index] = null;
      uploadedCount = photos.where((file) => file != null).length;
    });
  }

  bool get hasMinimumPhotos => uploadedCount >= 1;

  // ============================================================
  // UPLOAD PHOTOS - FIXED
  // ============================================================
  
  Future<bool> uploadPhotos() async {
    try {
      setState(() => isLoading = true);

      // Get list of File objects (not paths)
      final imageFiles = photos
          .where((file) => file != null)
          .map((file) => file!)
          .toList();

      if (imageFiles.isEmpty) {
        CustomToast.error("Please add at least one photo");
        setState(() => isLoading = false);
        return false;
      }

      // Get ProfileServiceController
      final profileController = Get.find<ProfileServiceController>();
      
      // Option 1: Send as List<File> (Recommended - uses updatePhotos)
      profileController.updatePhotos(imageFiles);
      
      // Option 2: Also set paths directly (backup)
      final imagePaths = imageFiles.map((file) => file.path).toList();
      profileController.setPhotoPaths(imagePaths);
      
      print('✅ Photos uploaded: ${imageFiles.length} photos');
      print('📸 Photo paths: $imagePaths');

      return true;
    } catch (e) {
      CustomToast.error("Failed to upload photos: $e");
      return false;
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> continueToTellmeabout() async {
    if (isLoading) return;

    if (!hasMinimumPhotos) {
      CustomToast.warning("Please add at least 1 photo to continue");
      return;
    }

    final success = await uploadPhotos();
    if (success) {
      // Debug print before navigating
      final profileController = Get.find<ProfileServiceController>();
      profileController.debugPrintProfile();
      
      Get.to(() => const TellmeaboutyouView());
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      appBar: const CustomAppBar(title: ""),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25.h),
              Text(
                "Great Choice! The More Photos You Have, The Better",
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "$uploadedCount/6 photos uploaded",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: hasMinimumPhotos ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),

              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final File? imageFile = photos[index];
                    
                    // If loading, show shimmer effect on the grid item
                    if (isLoading) {
                      return ShimmerEffect(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      );
                    }
                    
                    return GestureDetector(
                      onTap: isLoading ? null : () => pickImage(index),
                      child: DottedBorder(
                        color: imageFile != null ? Colors.orange : Colors.grey,
                        strokeWidth: imageFile != null ? 2.0 : 1.5,
                        radius: 16.r,
                        dashWidth: 6,
                        dashSpace: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 245, 245, 245),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Stack(
                            children: [
                              if (imageFile != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              else
                                const Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 32, 
                                    color: Colors.grey
                                  ),
                                ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () => imageFile != null
                                          ? removeImage(index)
                                          : pickImage(index),
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12, 
                                          blurRadius: 4
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      imageFile == null ? Icons.add : Icons.close,
                                      size: 18,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),
              CustomButton(
                text: "Continue",
                onPressed: isLoading ? () {} : continueToTellmeabout,
                isLoading: isLoading,
                backgroundColor: hasMinimumPhotos ? const Color(0xffFF6B00) : Colors.grey,
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}