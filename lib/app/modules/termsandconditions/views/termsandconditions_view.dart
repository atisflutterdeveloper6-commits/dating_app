import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../custom_widget/custom_appbar.dart';
import '../controllers/termsandconditions_controller.dart';

class TermsandconditionsView extends StatelessWidget {
  const TermsandconditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    final controller = Get.put(
      TermsandconditionsController(),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: const CustomAppBar(
        title: "Terms & Conditions",
          subtitle: "Please read our terms and conditions carefully before using the app."
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // Background Overlay
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // Page Content
          Positioned.fill(
            child: Obx(
                  () {
                if (controller.isLoading.value) {
                  return _buildShimmerLoading();
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorWidget(controller);
                }

                if (controller.termsData.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildContent(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAME CONTAINER DECORATION AS PRIVACY POLICY
  // ============================================================

  BoxDecoration _mainContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),

      border: Border.all(
        color: const Color(0xFFF1E8E4),
        width: 0.8.w,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 12.r,
          offset: Offset(0, 3.h),
        ),
      ],
    );
  }

  // ============================================================
  // SHIMMER LOADING
  // ============================================================

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.w,
        120.h,
        16.w,
        90.h,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16.w,
          20.h,
          16.w,
          20.h,
        ),
        decoration: _mainContainerDecoration(),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 140.w,
                height: 22.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),

              SizedBox(height: 14.h),

              ...List.generate(
                7,
                    (index) {
                  return Container(
                    width: index == 6
                        ? 220.w
                        : double.infinity,
                    height: 14.h,
                    margin: EdgeInsets.only(
                      bottom: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  );
                },
              ),

              SizedBox(height: 22.h),

              Container(
                width: 160.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),

              SizedBox(height: 14.h),

              ...List.generate(
                6,
                    (index) {
                  return Container(
                    width: index == 5
                        ? 190.w
                        : double.infinity,
                    height: 14.h,
                    margin: EdgeInsets.only(
                      bottom: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  );
                },
              ),

              SizedBox(height: 22.h),

              Container(
                width: 120.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),

              SizedBox(height: 12.h),

              ...List.generate(
                5,
                    (index) {
                  return Container(
                    width: index.isEven
                        ? 200.w
                        : 150.w,
                    height: 13.h,
                    margin: EdgeInsets.only(
                      bottom: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorWidget(
      TermsandconditionsController controller,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16.w,
        120.h,
        16.w,
        90.h,
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight:
          MediaQuery.of(Get.context!).size.height - 210.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 24.h,
        ),
        decoration: _mainContainerDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 34.sp,
                color: Colors.red.shade300,
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 18.h),

            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: controller.retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xffFF6A00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16.w,
        120.h,
        16.w,
        90.h,
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight:
          MediaQuery.of(Get.context!).size.height - 210.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 22.h,
        ),
        decoration: _mainContainerDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 55.sp,
              color: Colors.grey.shade400,
            ),

            SizedBox(height: 14.h),

            Text(
              'No terms & conditions available',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildContent(
      TermsandconditionsController controller,
      ) {
    final String content =
    controller.termsData.isNotEmpty
        ? controller.termsData.first.content
        : '';

    final List<Widget> contentWidgets =
    _parseContent(content);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),

      // Same spacing as Privacy Policy
      padding: EdgeInsets.fromLTRB(
        16.w,
        120.h,
        16.w,
        90.h,
      ),

      child: Container(
        width: double.infinity,

        // Same inner padding
        padding: EdgeInsets.fromLTRB(
          16.w,
          20.h,
          16.w,
          20.h,
        ),

        // Same border + radius + shadow
        decoration: _mainContainerDecoration(),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: contentWidgets,
        ),
      ),
    );
  }

  // ============================================================
  // PARSE CONTENT
  // ============================================================

  List<Widget> _parseContent(String content) {
    if (content.trim().isEmpty) {
      return [];
    }

    final List<Widget> widgets = [];

    String cleanedContent = content.replaceAll(
      RegExp(
        r'<(script|style)[^>]*>.*?</\1>',
        dotAll: true,
        caseSensitive: false,
      ),
      '',
    );

    final ulRegex = RegExp(
      r'<ul[^>]*>(.*?)</ul>',
      dotAll: true,
      caseSensitive: false,
    );

    cleanedContent = cleanedContent.replaceAllMapped(
      ulRegex,
          (match) {
        final ulContent =
            match.group(1) ?? '';

        final liRegex = RegExp(
          r'<li[^>]*>(.*?)</li>',
          dotAll: true,
          caseSensitive: false,
        );

        final List<String> items = [];

        for (final li
        in liRegex.allMatches(ulContent)) {
          final item = _cleanText(
            li.group(1) ?? '',
          );

          if (item.isNotEmpty) {
            items.add(item);
          }
        }

        if (items.isNotEmpty) {
          widgets.addAll(
            _buildListItems(items),
          );
        }

        return '';
      },
    );

    final blockRegex = RegExp(
      r'<(h1|h2|h3|h4|p|div|br)[^>]*>(.*?)</\1>',
      dotAll: true,
      caseSensitive: false,
    );

    final matches =
    blockRegex.allMatches(
      cleanedContent,
    ).toList();

    if (matches.isEmpty) {
      final plainText =
      _cleanText(cleanedContent);

      if (plainText.isNotEmpty) {
        final lines =
        plainText.split('\n');

        for (final line in lines) {
          final value = line.trim();

          if (value.isEmpty) {
            continue;
          }

          if (RegExp(r'^\d+\.\s*')
              .hasMatch(value)) {
            widgets.add(
              _buildHeading(value),
            );
          } else if (value.contains(':') ||
              value == value.toUpperCase()) {
            widgets.add(
              _buildBoldText(value),
            );
          } else {
            widgets.add(
              _buildParagraph(value),
            );
          }
        }
      }

      return widgets;
    }

    int lastPosition = 0;

    for (final match in matches) {
      if (match.start > lastPosition) {
        final before =
        cleanedContent.substring(
          lastPosition,
          match.start,
        );

        final cleanedBefore =
        _cleanText(before);

        if (cleanedBefore.isNotEmpty) {
          widgets.add(
            _buildParagraph(
              cleanedBefore,
            ),
          );
        }
      }

      final tag =
          match.group(1)?.toLowerCase() ?? '';

      final inner =
          match.group(2) ?? '';

      final cleaned =
      _cleanText(inner);

      if (cleaned.isNotEmpty) {
        switch (tag) {
          case 'h1':
            widgets.add(
              _buildHeading(
                cleaned,
                fontSize: 17.sp,
              ),
            );
            break;

          case 'h2':
            widgets.add(
              _buildHeading(
                cleaned,
                fontSize: 16.sp,
              ),
            );
            break;

          case 'h3':
            widgets.add(
              _buildHeading(
                cleaned,
                fontSize: 15.sp,
              ),
            );
            break;

          case 'h4':
            widgets.add(
              _buildHeading(
                cleaned,
                fontSize: 15.sp,
              ),
            );
            break;

          case 'p':
            widgets.add(
              _buildRichParagraph(inner),
            );
            break;

          case 'div':
            widgets.add(
              _buildRichParagraph(inner),
            );
            break;

          case 'br':
            widgets.add(
              SizedBox(height: 8.h),
            );
            break;
        }
      }

      lastPosition = match.end;
    }

    if (lastPosition <
        cleanedContent.length) {
      final remaining =
      cleanedContent.substring(
        lastPosition,
      );

      final cleanedRemaining =
      _cleanText(remaining);

      if (cleanedRemaining.isNotEmpty) {
        final lines =
        cleanedRemaining.split('\n');

        for (final line in lines) {
          final value = line.trim();

          if (value.isEmpty) {
            continue;
          }

          if (RegExp(r'^\d+\.\s*')
              .hasMatch(value)) {
            widgets.add(
              _buildHeading(value),
            );
          } else {
            widgets.add(
              _buildParagraph(value),
            );
          }
        }
      }
    }

    return widgets;
  }

  // ============================================================
  // HEADING
  // ============================================================

  Widget _buildHeading(
      String text, {
        double? fontSize,
      }) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16.h,
        bottom: 10.h,
      ),
      child: Text(
        _cleanText(text),
        style: GoogleFonts.poppins(
          letterSpacing: 1.0.w,
          fontSize:
          fontSize ?? 16.sp,
          fontWeight:
          FontWeight.w600,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // PARAGRAPH
  // ============================================================

  Widget _buildParagraph(
      String text,
      ) {
    final cleaned =
    _cleanText(text);

    if (cleaned.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.h,
      ),
      child: Text(
        cleaned,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          height: 1.7,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // ============================================================
  // RICH PARAGRAPH
  // ============================================================

  Widget _buildRichParagraph(
      String text,
      ) {
    final spans =
    _processBoldText(text);

    if (spans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.h,
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            height: 1.7,
            color: Colors.grey.shade700,
          ),
          children: spans,
        ),
      ),
    );
  }

  // ============================================================
  // BOLD TEXT
  // ============================================================

  Widget _buildBoldText(
      String text,
      ) {
    final cleaned =
    _cleanText(text);

    if (cleaned.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8.h,
        top: 6.h,
      ),
      child: Text(
        cleaned,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight:
          FontWeight.w600,
          height: 1.7,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  // ============================================================
  // LIST ITEMS
  // ============================================================

  List<Widget> _buildListItems(
      List<String> items,
      ) {
    final List<Widget> widgets = [];

    for (final item in items) {
      final cleaned =
      _cleanText(item);

      if (cleaned.isEmpty) {
        continue;
      }

      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: 8.h,
            left: 8.w,
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  const Color(0xffFF6A00),
                  height: 1.7,
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: Text(
                  cleaned,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 13.sp,
                    height: 1.7,
                    color:
                    Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  // ============================================================
  // PROCESS BOLD HTML
  // ============================================================

  List<TextSpan> _processBoldText(
      String text,
      ) {
    final List<TextSpan> spans = [];

    final boldRegex = RegExp(
      r'<(?:strong|b)[^>]*>(.*?)</(?:strong|b)>',
      dotAll: true,
      caseSensitive: false,
    );

    final matches =
    boldRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      final cleaned =
      _cleanText(text);

      if (cleaned.isEmpty) {
        return [];
      }

      return [
        TextSpan(
          text: cleaned,
        ),
      ];
    }

    int position = 0;

    for (final match in matches) {
      if (match.start > position) {
        final before =
        text.substring(
          position,
          match.start,
        );

        final cleanedBefore =
        _cleanText(before);

        if (cleanedBefore.isNotEmpty) {
          spans.add(
            TextSpan(
              text: cleanedBefore,
            ),
          );
        }
      }

      final boldText =
          match.group(1) ?? '';

      final cleanedBold =
      _cleanText(boldText);

      if (cleanedBold.isNotEmpty) {
        spans.add(
          TextSpan(
            text: cleanedBold,
            style: const TextStyle(
              fontWeight:
              FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        );
      }

      position = match.end;
    }

    if (position < text.length) {
      final after =
      text.substring(position);

      final cleanedAfter =
      _cleanText(after);

      if (cleanedAfter.isNotEmpty) {
        spans.add(
          TextSpan(
            text: cleanedAfter,
          ),
        );
      }
    }

    return spans;
  }

  // ============================================================
  // CLEAN HTML
  // ============================================================

  String _cleanText(
      String text,
      ) {
    String cleaned = text;

    cleaned = cleaned.replaceAll(
      RegExp(
        r'<!--.*?-->',
        dotAll: true,
      ),
      '',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'<[^>]*>',
        dotAll: true,
      ),
      ' ',
    );

    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&apos;', "'");

    cleaned = cleaned.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return cleaned.trim();
  }
}