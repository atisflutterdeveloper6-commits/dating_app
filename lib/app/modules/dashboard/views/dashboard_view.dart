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
    // Updated pages list with Discover at index 3
    final List<Widget> pages = [
      const HomepageView(),      // index 0
      InboxView(),               // index 1
      const LikeView(),          // index 2
        const HomepageView(),       // index 3 - NEW MIDDLE BUTTON
      PremiumView(),             // index 4
      ProfileView(),             // index 5
      SettingsView(),            // index 6
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Obx(
            () => Row(
              children: [
                // Home button (optional - you can add if needed)
                // _navItem(index: 0, svgPath: 'assets/icons/home.svg', title: "Home"),
                
                _navItem(index: 1, svgPath: 'assets/icons/inbox.svg', title: "Inbox"),
                _navItem(index: 2, svgPath: 'assets/icons/heart.svg', title: "Like"),
                
                // ─── MIDDLE DATING BUTTON ───
                _navItem(index: 3, svgPath: 'assets/icons/cupple.svg', title: "Match"),
                _navItem(index: 4, svgPath: 'assets/icons/primium.svg', title: "Premium"),
                _navItem(index: 5, svgPath: 'assets/icons/person.svg', title: "Profile"),
              ],
            ),
          ),
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
                selected ? const Color(0xffFF6100) : const Color(0xff6B3F2A),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? const Color(0xffFF6100) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}