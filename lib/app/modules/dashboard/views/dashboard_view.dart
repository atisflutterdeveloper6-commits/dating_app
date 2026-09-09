import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/homepage/views/homepage_view.dart';
import 'package:dating_app/app/modules/inbox/views/inbox_view.dart';
import 'package:dating_app/app/modules/like/views/like_view.dart';
import 'package:dating_app/app/modules/premium/views/premium_view.dart';
import 'package:dating_app/app/modules/profile/views/profile_view.dart';
import 'package:dating_app/app/modules/settings/views/settings_view.dart';
import 'package:dating_app/app/modules/discover/views/discover_view.dart'; // Create this view
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Original pages list — same order/index as before
    final List<Widget> pages = [
      const HomepageView(), // index 0
      InboxView(),          // index 1
      const LikeView(),     // index 2
      const HomepageView(), // index 3 - MIDDLE BUTTON (Match) — replace with DiscoverView() if needed
      PremiumView(),         // index 4
      ProfileView(),          // index 5
      SettingsView(),          // index 6
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      extendBody: true,
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 90,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // ── Background bar ──
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: Container(
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(
                      () => Row(
                    children: [
                      // Home button (optional - commented like before)
                      // _navItem(index: 0, svgPath: 'assets/icons/home.svg', title: "Home"),

                      _navItem(
                        index: 1,
                        svgPath: 'assets/icons/inbox.svg',
                        title: "Inbox",
                      ),
                      _navItem(
                        index: 2,
                        svgPath: 'assets/icons/heart.svg',
                        title: "Like",
                      ),
                      // Empty space reserved for the floating Match button
                      const Expanded(child: SizedBox()),
                      _navItem(
                        index: 4,
                        svgPath: 'assets/icons/primium.svg',
                        title: "Premium",
                      ),
                      _navItem(
                        index: 5,
                        svgPath: 'assets/icons/person.svg',
                        title: "Profile",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Floating gradient Match button (index 3) ──
            // ── Floating Orange Match button (index 3) ──
            Positioned(
              top: 0,
              child: Obx(() {
                final bool selected = controller.currentIndex.value == 3;

                return GestureDetector(
                  onTap: () => controller.changeTab(3),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      // 🟠 Orange button
                      color: const Color(0xffFF6100),

                      // 🟠 Active = Orange outline
                      // ⚪ Inactive = White outline
                      border: Border.all(
                        color: selected
                            ? const Color(0xffFF6100)
                            : Colors.white,
                        width: 4,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffFF6100).withOpacity(
                            selected ? 0.55 : 0.40,
                          ),
                          blurRadius: selected ? 16 : 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required String svgPath,
    required String title,
  }) {
    final bool selected = controller.currentIndex.value == index;
    const Color activeColor = Color(0xffFF6100);

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                selected ? activeColor : const Color(0xff6B3F2A),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? activeColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: selected ? 16 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}