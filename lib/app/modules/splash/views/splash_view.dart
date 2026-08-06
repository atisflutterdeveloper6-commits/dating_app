// lib/app/modules/splash/views/splash_view.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final SplashController controller = Get.find<SplashController>(); // ✅ Use Get.find()

  final List<ImageData> _imageData = const [
    ImageData("https://i.pravatar.cc/150?img=47", 66, left: 18, top: 50),
    ImageData("https://i.pravatar.cc/150?img=12", 56, left: 160, top: 60),
    ImageData("https://i.pravatar.cc/150?img=32", 44, right: 18, top: 123),
    ImageData("https://i.pravatar.cc/150?img=44", 48, right: 25, bottom: 90),
    ImageData("https://i.pravatar.cc/150?img=56", 48, left: 180, bottom: 38),
    ImageData("https://i.pravatar.cc/150?img=36", 42, left: 212, bottom: 117),
    ImageData("https://i.pravatar.cc/150?img=18", 45, left: 20, bottom: 118),
  ];

  late final List<_ImagePosition> _positions;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    const stackSize = 360.0;
    const center = Offset(stackSize / 2, stackSize / 2);

    _positions = _imageData.map((data) {
      double left, top;
      if (data.left != null) {
        left = data.left!;
      } else if (data.right != null) {
        left = stackSize - data.right! - data.size;
      } else {
        left = 0;
      }

      if (data.top != null) {
        top = data.top!;
      } else if (data.bottom != null) {
        top = stackSize - data.bottom! - data.size;
      } else {
        top = 0;
      }

      final cx = left + data.size / 2;
      final cy = top + data.size / 2;
      final offset = Offset(cx, cy) - center;
      final radius = offset.distance;
      final angle = atan2(offset.dy, offset.dx);
      return _ImagePosition(
        url: data.url,
        size: data.size,
        radius: radius,
        initialAngle: angle,
      );
    }).toList();
    
    // ✅ Add a timeout fallback navigation
    Future.delayed(const Duration(seconds: 8), () {
      if (controller.isLoading.value) {
        print('⚠️ Splash taking too long - forcing navigation');
        controller.isLoading.value = false;
        controller.determineNavigation(); // ✅ Now public method
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 360,
          height: 360,
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              final rotation = _rotationController.value * 2 * pi;

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: const Size(310, 310),
                    painter: DashedCirclePainter(),
                  ),

                  Container(
                    width: 225,
                    height: 225,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE4D6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 125,
                    height: 125,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  // ✅ SPLASH IMAGE
                  Container(
                    width: 74,
                    height: 74,
                    decoration: const BoxDecoration(
                      color: Color(0xffFF6338),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Obx(() => controller.splashImageUrl.value.isNotEmpty
                          ? Image.network(
                              controller.splashImageUrl.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Image loading error: $error');
                                return Container(
                                  color: const Color(0xffFF6338),
                                  child: const ShimmerLoading(),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: const Color(0xffFF6338),
                                  child: const ShimmerLoading(),
                                );
                              },
                            )
                          : Container(
                              color: const Color(0xffFF6338),
                              child: const ShimmerLoading(),
                            ),
                      ),
                    ),
                  ),

                  // Rotating profile images
                  ..._positions.map((pos) {
                    final currentAngle = pos.initialAngle + rotation;
                    final dx = pos.radius * cos(currentAngle);
                    final dy = pos.radius * sin(currentAngle);
                    final centerX = 180 + dx;
                    final centerY = 180 + dy;
                    final left = centerX - pos.size / 2;
                    final top = centerY - pos.size / 2;

                    return Positioned(
                      left: left,
                      top: top,
                      child: CircleAvatar(
                        radius: pos.size / 2,
                        backgroundColor: const Color(0xFFFFC3C9),
                        child: CircleAvatar(
                          radius: (pos.size / 2) - 2,
                          backgroundImage: NetworkImage(pos.url),
                        ),
                      ),
                    );
                  }).toList(),

                  // Floating icons
                  Positioned(
                    top: 30,
                    right: 82,
                    child: _floatingIcon(Icons.location_on),
                  ),
                  Positioned(
                    left: 85,
                    bottom: 20,
                    child: _floatingIcon(Icons.messenger_outline_rounded),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _floatingIcon(IconData icon) {
    return Container(
      width: 35,
      height: 35,
      decoration: const BoxDecoration(
        color: Color(0xffFF6338),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: icon == Icons.more_horiz ? 22 : 18,
      ),
    );
  }
}

// Helper classes
class ImageData {
  final String url;
  final double size;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  const ImageData(
    this.url,
    this.size, {
    this.left,
    this.right,
    this.top,
    this.bottom,
  });
}

class _ImagePosition {
  final String url;
  final double size;
  final double radius;
  final double initialAngle;

  _ImagePosition({
    required this.url,
    required this.size,
    required this.radius,
    required this.initialAngle,
  });
}

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD8CC)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    const dash = 14.0;
    const gap = 14.0;

    final count = ((2 * pi * radius) / (dash + gap)).floor();

    for (int i = 0; i < count; i++) {
      final start = (2 * pi / count) * i;
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(radius, radius),
          radius: radius,
        ),
        start,
        dash / radius,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          color: const Color(0xffFF6338),
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.0),
                ],
                stops: [
                  _shimmerController.value - 0.3,
                  _shimmerController.value,
                  _shimmerController.value + 0.3,
                ],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              color: const Color(0xffFF6338),
            ),
          ),
        );
      },
    );
  }
}