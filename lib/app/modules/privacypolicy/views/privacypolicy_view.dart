import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../custom_widget/custom_appbar.dart';
import '../controllers/privacypolicy_controller.dart';

class PrivacypolicyView extends StatelessWidget {
  const PrivacypolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    final controller = Get.put(PrivacypolicyController());

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: const CustomAppBar(title: "Privacy Policy"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorWidget(controller);
        }

        if (controller.privacyPolicyData.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPolicyContent(controller);
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 160.w,
                height: 24.h,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              ...List.generate(8, (index) => 
                Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 22.h),
              Container(
                width: 150.w,
                height: 16.h,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              ...List.generate(6, (index) => 
                Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(PrivacypolicyController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60.sp,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: controller.retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 12.h,
              ),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No privacy policy data available',
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildPolicyContent(PrivacypolicyController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.4.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildPolicyItems(controller.privacyPolicyData),
        ),
      ),
    );
  }

  List<Widget> _buildPolicyItems(List<PrivacyPolicyItem> items) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      // Add title for each item
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: i > 0 ? 24.h : 0),
          child: Text(
            item.title.trim(),
            style: GoogleFonts.poppins(
              letterSpacing: 1.5.w,
              fontSize: i == 0 ? 16.sp : 16.sp,
              fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      );

      // Parse HTML content in order - preserves exact sequence
      widgets.addAll(_parseHtmlInOrder(item.content));

      // Add divider between items (except after the last one)
      if (i < items.length - 1) {
        widgets.add(
          Divider(
            height: 32.h,
            color: Colors.grey.shade200,
            thickness: 1,
          ),
        );
      }
    }

    return widgets;
  }

  // Parse HTML content and maintain exact order as in the API response
  List<Widget> _parseHtmlInOrder(String html) {
    final List<Widget> widgets = [];
    String content = html;

    // Find all HTML tags in order
    final tagRegex = RegExp(r'<(/?)([a-zA-Z0-9]+)[^>]*>');
    final textRegex = RegExp(r'[^<]+');
    
    // Process the HTML sequentially
    int position = 0;
    String currentText = '';
    
    // First, extract all matches in order
    final List<Map<String, dynamic>> elements = [];
    
    // Find all tags and text in order
    while (position < content.length) {
      // Check for text before next tag
      final textMatch = textRegex.matchAsPrefix(content, position);
      if (textMatch != null && textMatch.group(0)!.isNotEmpty) {
        final text = textMatch.group(0)!.trim();
        if (text.isNotEmpty) {
          elements.add({
            'type': 'text',
            'content': text,
          });
        }
        position = textMatch.end;
        continue;
      }
      
      // Check for tag
      final tagMatch = tagRegex.matchAsPrefix(content, position);
      if (tagMatch != null) {
        final isClosing = tagMatch.group(1) == '/';
        final tagName = tagMatch.group(2)?.toLowerCase() ?? '';
        
        // Get full tag content including attributes
        final fullTag = tagMatch.group(0) ?? '';
        
        // Extract content between tags if it's an opening tag
        if (!isClosing) {
          // Find closing tag
          final closingTag = '</$tagName>';
          final startPos = tagMatch.end;
          final endPos = content.indexOf(closingTag, startPos);
          
          if (endPos != -1) {
            final innerContent = content.substring(startPos, endPos).trim();
            elements.add({
              'type': 'tag',
              'tag': tagName,
              'content': innerContent,
              'fullTag': fullTag,
              'isClosing': false,
            });
            position = endPos + closingTag.length;
            continue;
          }
        }
        
        // Skip other tags (like closing tags or self-closing)
        position = tagMatch.end;
        continue;
      }
      
      // If no match, move forward
      position++;
    }

    // Now process all elements in order
    bool isInList = false;
    List<String> listItems = [];
    
    for (var element in elements) {
      if (element['type'] == 'tag') {
        final tag = element['tag'] as String;
        final content = element['content'] as String;
        
        if (tag == 'ul') {
          // Start of a list - collect list items
          isInList = true;
          listItems = [];
        } else if (tag == 'li' && isInList) {
          // Add list item
          listItems.add(_cleanText(content));
        } else if (tag == 'h1') {
          // If we were in a list, render it first
          if (isInList && listItems.isNotEmpty) {
            widgets.addAll(_renderListItems(listItems));
            isInList = false;
            listItems = [];
          }
          // Add heading
          widgets.add(
            Padding(
              padding: EdgeInsets.only(top: 0.h, bottom: 8.h),
              child: Text(
                _cleanText(content),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          );
        } else if (tag == 'h2') {
          // If we were in a list, render it first
          if (isInList && listItems.isNotEmpty) {
            widgets.addAll(_renderListItems(listItems));
            isInList = false;
            listItems = [];
          }
          // Add subheading
          widgets.add(
            Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
              child: Text(
                _cleanText(content),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          );
        } else if (tag == 'h3') {
          if (isInList && listItems.isNotEmpty) {
            widgets.addAll(_renderListItems(listItems));
            isInList = false;
            listItems = [];
          }
          widgets.add(
            Padding(
              padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
              child: Text(
                _cleanText(content),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          );
        } else if (tag == 'h4') {
          if (isInList && listItems.isNotEmpty) {
            widgets.addAll(_renderListItems(listItems));
            isInList = false;
            listItems = [];
          }
          widgets.add(
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 6.h),
              child: Text(
                _cleanText(content),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          );
        } else if (tag == 'p') {
          // If we were in a list, render it first
          if (isInList && listItems.isNotEmpty) {
            widgets.addAll(_renderListItems(listItems));
            isInList = false;
            listItems = [];
          }
          // Add paragraph with bold text support
          final processedText = _processBoldText(content);
          if (processedText.isNotEmpty) {
            widgets.add(
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      height: 1.8,
                      color: Colors.grey.shade700,
                    ),
                    children: processedText,
                  ),
                ),
              ),
            );
          }
        }
      } else if (element['type'] == 'text') {
        // Plain text outside of any tag (should be minimal)
        final text = element['content'] as String;
        if (text.isNotEmpty && !isInList) {
          widgets.add(
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                _cleanText(text),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  height: 1.8,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          );
        }
      }
    }
    
    // If there are remaining list items, render them
    if (isInList && listItems.isNotEmpty) {
      widgets.addAll(_renderListItems(listItems));
    }

    return widgets;
  }

  // Render list items with bullet points
  List<Widget> _renderListItems(List<String> items) {
    final List<Widget> widgets = [];
    
    for (var item in items) {
      final processedItem = _processBoldText(item);
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, left: 16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  height: 1.8,
                  color: const Color(0xff6C63FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      height: 1.8,
                      color: Colors.grey.shade700,
                    ),
                    children: processedItem,
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

  // Process bold/strong tags in text
  List<TextSpan> _processBoldText(String text) {
    final List<TextSpan> spans = [];
    final boldRegex = RegExp(r'<(?:strong|b)>(.*?)</(?:strong|b)>', dotAll: true);
    
    int position = 0;
    final matches = boldRegex.allMatches(text);
    
    if (matches.isEmpty) {
      // No bold text, return plain text
      return [
        TextSpan(
          text: _cleanText(text),
        ),
      ];
    }
    
    for (var match in matches) {
      // Add text before bold
      if (match.start > position) {
        final beforeText = text.substring(position, match.start);
        if (beforeText.isNotEmpty) {
          spans.add(
            TextSpan(
              text: _cleanText(beforeText),
            ),
          );
        }
      }
      
      // Add bold text
      final boldText = match.group(1)?.trim() ?? '';
      spans.add(
        TextSpan(
          text: _cleanText(boldText),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );
      
      position = match.end;
    }
    
    // Add remaining text
    if (position < text.length) {
      final afterText = text.substring(position);
      if (afterText.isNotEmpty) {
        spans.add(
          TextSpan(
            text: _cleanText(afterText),
          ),
        );
      }
    }
    
    return spans;
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}