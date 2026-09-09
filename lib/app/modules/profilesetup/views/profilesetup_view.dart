// lib/app/modules/profilesetup/views/profilesetup_view.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/tellmeaboutyou/views/tellmeaboutyou_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../custom_widget/custom_appbar.dart';
import '../../../custom_widget/custom_button.dart';
import '../controllers/profilesetup_controller.dart';

// ============================================================
// COLORS
// ============================================================

const Color orange = Color(0xFFFF6B00);
const Color orangeLight = Color(0xFFFF8A3D);
const Color darkText = Color(0xFF172033);
const Color greyText = Color(0xFF85858F);
const Color lightOrange = Color(0xFFFFF4EE);

// ============================================================
// SHIMMER
// ============================================================

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

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(
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

// ============================================================
// DOTTED BORDER
// ============================================================

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
    this.strokeWidth = 1.0,
    this.color = Colors.grey,
    this.radius = 14,
    this.dashWidth = 5,
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

    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      final length = metric.length;
      double start = 0;

      while (start < length) {
        final end = math.min(
          start + dashWidth,
          length,
        );

        final segment = metric.extractPath(
          start,
          end,
        );

        canvas.drawPath(
          segment,
          paint,
        );

        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant _DottedBorderPainter oldDelegate,
      ) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

// ============================================================
// DECORATIVE BOTTOM WAVE
// ============================================================

class BottomDecoration extends StatelessWidget {
  const BottomDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 105.h,
        width: double.infinity,
        child: CustomPaint(
          painter: _BottomDecorationPainter(),
        ),
      ),
    );
  }
}

class _BottomDecorationPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final path = Path();

    path.moveTo(0, size.height * 0.58);

    path.cubicTo(
      size.width * 0.18,
      size.height * 0.80,
      size.width * 0.30,
      size.height * 0.70,
      size.width * 0.45,
      size.height * 0.84,
    );

    path.cubicTo(
      size.width * 0.62,
      size.height * 1.02,
      size.width * 0.76,
      size.height * 0.68,
      size.width,
      size.height * 0.82,
    );

    path.lineTo(
      size.width,
      size.height,
    );

    path.lineTo(
      0,
      size.height,
    );

    path.close();

    final paint = Paint()
      ..color = const Color(0xFFFFDCC8)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Inner lighter wave
    final path2 = Path();

    path2.moveTo(0, size.height * 0.73);

    path2.cubicTo(
      size.width * 0.20,
      size.height * 0.92,
      size.width * 0.32,
      size.height * 0.73,
      size.width * 0.47,
      size.height * 0.86,
    );

    path2.cubicTo(
      size.width * 0.65,
      size.height * 1.00,
      size.width * 0.80,
      size.height * 0.76,
      size.width,
      size.height * 0.86,
    );

    path2.lineTo(
      size.width,
      size.height,
    );

    path2.lineTo(
      0,
      size.height,
    );

    path2.close();

    final paint2 = Paint()
      ..color = const Color(0xFFFFF1E9)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      path2,
      paint2,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

// ============================================================
// LEAF DECORATION (bottom-left / bottom-right branch with leaves)
// ============================================================

class LeafDecoration extends StatelessWidget {
  final bool flip;
  final double width;
  final double height;

  const LeafDecoration({
    super.key,
    this.flip = false,
    this.width = 70,
    this.height = 95,
  });

  @override
  Widget build(BuildContext context) {
    Widget painter = CustomPaint(
      size: Size(width.w, height.h),
      painter: _LeafPainter(),
    );

    if (flip) {
      painter = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: painter,
      );
    }

    return IgnorePointer(child: painter);
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = const Color(0xFFF3B489)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final leafPaintDark = Paint()
      ..color = const Color(0xFFFFC9A0)
      ..style = PaintingStyle.fill;

    final leafPaintLight = Paint()
      ..color = const Color(0xFFFFE1C7)
      ..style = PaintingStyle.fill;

    // Curved stem rising from bottom-left corner of the box.
    final stem = Path()
      ..moveTo(size.width * 0.08, size.height)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.55,
        size.width * 0.85,
        size.height * 0.02,
      );

    canvas.drawPath(stem, stemPaint);

    final metric = stem.computeMetrics().first;

    void drawLeaf(double t, double angleOffset, double scale, Paint paint) {
      final tangent = metric.getTangentForOffset(metric.length * t);
      if (tangent == null) return;

      canvas.save();
      canvas.translate(tangent.position.dx, tangent.position.dy);
      canvas.rotate(tangent.angle + angleOffset);

      final leafPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(9 * scale, -7 * scale, 18 * scale, 0)
        ..quadraticBezierTo(9 * scale, 7 * scale, 0, 0)
        ..close();

      canvas.drawPath(leafPath, paint);
      canvas.restore();
    }

    drawLeaf(0.15, -1.0, 1.0, leafPaintDark);
    drawLeaf(0.32, 1.1, 0.85, leafPaintLight);
    drawLeaf(0.50, -0.9, 0.95, leafPaintDark);
    drawLeaf(0.68, 1.0, 0.8, leafPaintLight);
    drawLeaf(0.85, -0.85, 0.75, leafPaintDark);
    drawLeaf(0.97, 0.9, 0.6, leafPaintLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// MAIN VIEW
// ============================================================

class ProfilesetupView extends StatefulWidget {
  const ProfilesetupView({
    super.key,
  });

  @override
  State<ProfilesetupView> createState() =>
      _ProfilesetupViewState();
}

class _ProfilesetupViewState
    extends State<ProfilesetupView> {
  late ProfilesetupController controller;

  List<File?> photos =
  List<File?>.filled(6, null);

  bool isLoading = false;

  int uploadedCount = 0;

  final ImagePicker picker =
  ImagePicker();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    controller =
    Get.isRegistered<ProfilesetupController>()
        ? Get.find<ProfilesetupController>()
        : Get.put(
      ProfilesetupController(),
    );

    _loadPhotos();
  }

  // ============================================================
  // LOAD PHOTOS
  // ============================================================

  void _loadPhotos() {
    if (controller.photos.isNotEmpty) {
      setState(() {
        photos =
        List<File?>.from(
          controller.photos,
        );

        uploadedCount =
            photos
                .where(
                  (file) => file != null,
            )
                .length;
      });
    }
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage(
      int index,
      ) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final XFile? image =
      await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          photos[index] =
              File(image.path);

          controller.photos[index] =
              File(image.path);

          uploadedCount =
              photos
                  .where(
                    (file) => file != null,
              )
                  .length;
        });

        CustomToast.success(
          "Image added successfully!",
        );
      }
    } catch (e) {
      CustomToast.error(
        "Failed to pick image",
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  void removeImage(
      int index,
      ) {
    if (isLoading) return;

    setState(() {
      photos[index] = null;

      controller.photos[index] = null;

      uploadedCount =
          photos
              .where(
                (file) => file != null,
          )
              .length;
    });
  }

  // ============================================================
  // MINIMUM PHOTO
  // ============================================================

  bool get hasMinimumPhotos =>
      uploadedCount >= 1;

  // ============================================================
  // UPLOAD PHOTOS
  // ============================================================

  Future<bool> uploadPhotos() async {
    try {
      setState(() {
        isLoading = true;
      });

      final imageFiles = photos
          .where(
            (file) => file != null,
      )
          .map(
            (file) => file!,
      )
          .toList();

      if (imageFiles.isEmpty) {
        CustomToast.error(
          "Please add at least one photo",
        );

        setState(() {
          isLoading = false;
        });

        return false;
      }

      final profileController =
      Get.find<
          ProfileServiceController>();

      profileController.updatePhotos(
        imageFiles,
      );

      final imagePaths = imageFiles
          .map(
            (file) => file.path,
      )
          .toList();

      profileController.setPhotoPaths(
        imagePaths,
      );

      print(
        '✅ Photos uploaded: '
            '${imageFiles.length} photos',
      );

      print(
        '📸 Photo paths: $imagePaths',
      );

      return true;
    } catch (e) {
      CustomToast.error(
        "Failed to upload photos: $e",
      );

      return false;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  Future<void>
  continueToTellmeabout() async {
    if (isLoading) return;

    if (!hasMinimumPhotos) {
      CustomToast.warning(
        "Please add at least 1 photo to continue",
      );
      return;
    }

    final success =
    await uploadPhotos();

    if (success) {
      final profileController =
      Get.find<
          ProfileServiceController>();

      profileController
          .debugPrintProfile();

      Get.to(
            () =>
        const TellmeaboutyouView(),
      );
    }
  }

  // ============================================================
  // POPPINS
  // ============================================================

  TextStyle poppins({
    double size = 14,
    FontWeight weight =
        FontWeight.w400,
    Color color = darkText,
  }) {
    return GoogleFonts.poppins(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    ScreenUtil.init(
      context,
      designSize:
      const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    final screenHeight =
        MediaQuery.sizeOf(
          context,
        ).height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,


      appBar: const CustomAppBar(
        title: 'Add Photos',
        subtitle: 'Help others get to know you better',
        // rightImage: 'assets/icons/app_icon.jpeg',
        useIllustration: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/LoginBack2.png',
              fit: BoxFit.cover,
            ),
          ),
          // ========================================================
          // MAIN CONTENT
          // ========================================================
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFFF0E6)
                  .withOpacity(0.10),
            ),
          ),

          // ========================================================
          // BOTTOM DECORATION (wave)
          // ========================================================
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomDecoration(),
          ),

          // ========================================================
          // LEFT LEAVES
          // ========================================================
          Positioned(
            left: 2.w,
            bottom: 26.h,
            child: const LeafDecoration(),
          ),

          // ========================================================
          // RIGHT LEAVES
          // ========================================================
          Positioned(
            right: 2.w,
            bottom: 26.h,
            child: const LeafDecoration(flip: true),
          ),

          Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal: 22.w,
            ),
            child: Column(
              children: [
                // ==================================================
                // TOP ICON
                // ==================================================

                SizedBox(
                  height: 150.h,
                ),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 43.w,
                      width: 43.w,
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFFFF0E8,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          12.r,
                        ),
                      ),
                      child: Stack(
                        alignment:
                        Alignment.center,
                        children: [
                          Container(
                            height: 28.w,
                            width: 28.w,
                            decoration:
                            BoxDecoration(
                              color:
                              Colors.white,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                6.r,
                              ),
                            ),
                            child:
                            Icon(
                              Icons
                                  .image_outlined,
                              color:
                              orange,
                              size: 19.sp,
                            ),
                          ),

                          Positioned(
                            right: 1.w,
                            top: 2.h,
                            child:
                            Text(
                              "✦",
                              style:
                              TextStyle(
                                color:
                                orange,
                                fontSize:
                                11.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ============================================
                    // SMALL DOTS (top-right of icon)
                    // ============================================
                    Positioned(
                      right: -34.w,
                      top: 2.h,
                      child: const _Dots(),
                    ),
                  ],
                ),

                SizedBox(
                  height: 9.h,
                ),

                // ==================================================
                // TITLE
                // ==================================================

                RichText(
                  textAlign:
                  TextAlign.center,
                  text:
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                        "Great choice!\n",
                        style:
                        poppins(
                          size: 16,
                          weight:
                          FontWeight
                              .w700,
                        ),
                      ),
                      TextSpan(
                        text:
                        "The more photos you have,\n",
                        style:
                        poppins(
                          size: 15,
                          weight:
                          FontWeight
                              .w700,
                          color:
                          orange,
                        ),
                      ),
                      TextSpan(
                        text:
                        "the better",
                        style:
                        poppins(
                          size: 15,
                          weight:
                          FontWeight
                              .w700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 9.h,
                ),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                Text(
                  "Add more photos so people can get\n"
                      "to know you better.",
                  textAlign:
                  TextAlign.center,
                  style:
                  poppins(
                    size: 8,
                    color:
                    greyText,
                  ).copyWith(
                    height: 1.45,
                  ),
                ),

                SizedBox(
                  height: 40.h,
                ),

                // ==================================================
                // PHOTO CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    12.w,
                    20, // 👈 top padding hata diya, height sirf upar se kam hogi
                    12.w,
                    20.h,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius
                        .circular(
                      14.r,
                    ),
                    border:
                    Border.all(
                      color:
                      const Color(
                        0xFFF1E8E4,
                      ),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                          0.035,
                        ),
                        blurRadius:
                        12,
                        offset:
                        const Offset(
                          0,
                          3,
                        ),
                      ),
                    ],
                  ),
                  child:
                  GridView.builder(
                    shrinkWrap:
                    true,
                    padding:
                    EdgeInsets.zero,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      3,
                      crossAxisSpacing:
                      9.w,
                      mainAxisSpacing:
                      10.h,
                      childAspectRatio:
                      0.85,
                    ),
                    itemBuilder:
                        (
                        context,
                        index,
                        ) {
                      final File?
                      imageFile =
                      photos[
                      index];

                      // ==========================================
                      // SHIMMER
                      // ==========================================

                      if (isLoading) {
                        return ShimmerEffect(
                          baseColor:
                          const Color(
                            0xFFF2F2F2,
                          ),
                          highlightColor:
                          Colors
                              .white,
                          child:
                          Container(
                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFFF2F2F2,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                13.r,
                              ),
                            ),
                          ),
                        );
                      }

                      // ==========================================
                      // PHOTO BOX
                      // ==========================================

                      return GestureDetector(
                        onTap: () =>
                            pickImage(
                              index,
                            ),
                        child:
                        DottedBorder(
                          color:
                          imageFile !=
                              null
                              ? orange
                              .withOpacity(
                            0.35,
                          )
                              : const Color(
                            0xFFECE3DE,
                          ),
                          strokeWidth:
                          1,
                          radius:
                          13.r,
                          dashWidth:
                          5,
                          dashSpace:
                          4,
                          child:
                          Container(
                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFFFFFCFA,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                13.r,
                              ),
                            ),
                            child:
                            Stack(
                              children: [
                                // ==================================
                                // IMAGE
                                // ==================================

                                if (imageFile !=
                                    null)
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      13.r,
                                    ),
                                    child:
                                    Image.file(
                                      imageFile,
                                      fit:
                                      BoxFit.cover,
                                      width:
                                      double.infinity,
                                      height:
                                      double.infinity,
                                    ),
                                  )
                                else
                                  Center(
                                    child:
                                    Icon(
                                      Icons
                                          .photo_camera_outlined,
                                      size:
                                      17.sp,
                                      color:
                                      const Color(
                                        0xFFBDB8B5,
                                      ),
                                    ),
                                  ),

                                // ==================================
                                // PLUS / REMOVE
                                // ==================================

                                Positioned(
                                  right:
                                  5.w,
                                  bottom:
                                  5.h,
                                  child:
                                  GestureDetector(
                                    onTap:
                                    isLoading
                                        ? null
                                        : () {
                                      if (imageFile !=
                                          null) {
                                        removeImage(
                                          index,
                                        );
                                      } else {
                                        pickImage(
                                          index,
                                        );
                                      }
                                    },
                                    child:
                                    Container(
                                      height:
                                      23.w,
                                      width:
                                      23.w,
                                      decoration:
                                      BoxDecoration(
                                        color:
                                        Colors.white,
                                        shape:
                                        BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors
                                                .black
                                                .withOpacity(
                                              0.08,
                                            ),
                                            blurRadius:
                                            5,
                                          ),
                                        ],
                                      ),
                                      child:
                                      Icon(
                                        imageFile ==
                                            null
                                            ? Icons
                                            .add
                                            : Icons
                                            .close,
                                        size:
                                        15.sp,
                                        color:
                                        orange,
                                      ),
                                    ),
                                  ),
                                ),

                                // ==================================
                                // REMOVE ON IMAGE TOP
                                // ==================================

                                if (imageFile !=
                                    null)
                                  Positioned(
                                    right:
                                    3.w,
                                    top:
                                    3.h,
                                    child:
                                    GestureDetector(
                                      onTap:
                                          () =>
                                          removeImage(
                                            index,
                                          ),
                                      child:
                                      Container(
                                        height:
                                        20.w,
                                        width:
                                        20.w,
                                        decoration:
                                        const BoxDecoration(
                                          color:
                                          Colors.white,
                                          shape:
                                          BoxShape.circle,
                                        ),
                                        child:
                                        Icon(
                                          Icons
                                              .close,
                                          size:
                                          13.sp,
                                          color:
                                          orange,
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

                // ==================================================
                // SPACE
                // ==================================================

                SizedBox(
                  height: 20.h,
                ),

                // ==================================================
                // CONTINUE BUTTON
                // ==================================================

                CustomButton(
                  text: "Continue",
                  onPressed: continueToTellmeabout,
                  height: 43,
                  borderRadius: 30,
                  backgroundColor: orange,
                  textColor: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  isLoading: isLoading,
                  enabled: hasMinimumPhotos,
                  showArrow: true,
                ),


              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DOTS
// ============================================================

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: List.generate(
        4,
            (row) {
          return Row(
            children: List.generate(
              3,
                  (col) {
                return Padding(
                  padding:
                  EdgeInsets.all(
                    2.w,
                  ),
                  child: Container(
                    height: 3.w,
                    width: 3.w,
                    decoration:
                    const BoxDecoration(
                      color:
                      Color(
                        0xFFFFC7AF,
                      ),
                      shape:
                      BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}