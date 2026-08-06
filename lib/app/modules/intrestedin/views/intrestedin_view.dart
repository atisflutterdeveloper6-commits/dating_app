import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/intrestedin/controllers/intrestedin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IntrestedinView extends StatefulWidget {
  const IntrestedinView({super.key});

  @override
  State<IntrestedinView> createState() => _IntrestedinViewState();
}

class _IntrestedinViewState extends State<IntrestedinView> {
  final IntrestedinController controller = Get.put(IntrestedinController());

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // Standard design size (iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),

      appBar: const CustomAppBar(title: ""),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              child: Text(
            "Who Are You Interested In\nSeeing?",
                style: TextStyle(
                  letterSpacing: 1.5.w,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(height: 25.h),

            Column(
              children: List.generate(
                controller.interests.length,
                (index) {
                  final bool selected = controller.selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.selectedIndex = index;
                      });
                    },
                    child: Container(
                      height: 55.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xfffff2e8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: selected
                              ? const Color(0xffFF6B00)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          controller.interests[index],
                          style: TextStyle(
                            letterSpacing: 1.5.w,
                            fontSize: 12.sp,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            SafeArea(
              child: CustomButton(
                text: "Next",
                onPressed: () {
                  controller.next();
                },
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}