
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

final controller = Get.put(
PrivacypolicyController(),
);

return Scaffold(
backgroundColor: Colors.transparent,
extendBodyBehindAppBar: true,
extendBody: true,

appBar: const CustomAppBar(
title: "Privacy Policy",
    subtitle: "Read our privacy policy carefully",
),

body: Stack(
fit: StackFit.expand,
children: [
// =========================================================
// BACKGROUND IMAGE
// =========================================================

Positioned.fill(
child: Image.asset(
"assets/images/LoginBack2.png",
fit: BoxFit.cover,
),
),

// =========================================================
// WHITE OVERLAY
// =========================================================

Positioned.fill(
child: Container(
color: Colors.white.withOpacity(0.70),
),
),

// =========================================================
// CONTENT
// =========================================================

Positioned.fill(
child: Obx(
() {
// ---------------------------------------------------
// LOADING
// ---------------------------------------------------

if (controller.isLoading.value) {
return _buildShimmerLoading();
}

// ---------------------------------------------------
// ERROR
// ---------------------------------------------------

if (controller.errorMessage.value.isNotEmpty) {
return _buildErrorWidget(controller);
}

// ---------------------------------------------------
// EMPTY
// ---------------------------------------------------

if (controller.privacyPolicyData.isEmpty) {
return _buildEmptyState();
}

// ---------------------------------------------------
// DATA
// ---------------------------------------------------

return _buildPolicyContent(controller);
},
),
),
],
),
);
}

// =================================================================
// MAIN WHITE CONTAINER DECORATION
// =================================================================

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

// =================================================================
// SHIMMER LOADING
// =================================================================

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
enabled: true,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Title
Container(
width: 160.w,
height: 24.h,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(6.r),
),
),

SizedBox(height: 14.h),

// Paragraph
...List.generate(
8,
(index) {
return Container(
width: index == 7
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

// Heading
Container(
width: 150.w,
height: 18.h,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(5.r),
),
),

SizedBox(height: 14.h),

// Paragraph
...List.generate(
6,
(index) {
return Container(
width: index == 5
? 200.w
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

// Heading
Container(
width: 180.w,
height: 18.h,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(5.r),
),
),

SizedBox(height: 14.h),

// Paragraph
...List.generate(
5,
(index) {
return Container(
width: index == 4
? 230.w
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
],
),
),
),
);
}

// =================================================================
// ERROR WIDGET
// =================================================================

Widget _buildErrorWidget(
PrivacypolicyController controller,
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
minHeight: MediaQuery.of(Get.context!).size.height - 210.h,
),
padding: EdgeInsets.symmetric(
horizontal: 20.w,
vertical: 24.h,
),
decoration: _mainContainerDecoration(),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
mainAxisSize: MainAxisSize.min,
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
backgroundColor: const Color(0xffFF6A00),
foregroundColor: Colors.white,
elevation: 0,
padding: EdgeInsets.symmetric(
horizontal: 32.w,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12.r),
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

// =================================================================
// EMPTY STATE
// =================================================================

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
minHeight: MediaQuery.of(Get.context!).size.height - 210.h,
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
Icons.privacy_tip_outlined,
size: 55.sp,
color: Colors.grey.shade400,
),

SizedBox(height: 14.h),

Text(
'No privacy policy data available',
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

// =================================================================
// POLICY CONTENT
// =================================================================

Widget _buildPolicyContent(
PrivacypolicyController controller,
) {
return SingleChildScrollView(
physics: const BouncingScrollPhysics(),
padding: EdgeInsets.fromLTRB(
16.w,
120.h, // AppBar ke niche
16.w,
90.h, // Bottom space
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
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: _buildPolicyItems(
controller.privacyPolicyData,
),
),
),
);
}

// =================================================================
// POLICY ITEMS
// =================================================================

List<Widget> _buildPolicyItems(
List<PrivacyPolicyItem> items,
) {
final List<Widget> widgets = [];

for (int i = 0; i < items.length; i++) {
final item = items[i];

widgets.add(
Padding(
padding: EdgeInsets.only(
bottom: 12.h,
top: i > 0 ? 24.h : 0,
),
child: Text(
_cleanText(item.title),
style: GoogleFonts.poppins(
letterSpacing: 1.0.w,
fontSize: 16.sp,
fontWeight: i == 0
? FontWeight.w700
    : FontWeight.w600,
color: Colors.black87,
height: 1.5,
),
),
),
);

widgets.addAll(
_parseHtmlInOrder(item.content),
);

if (i < items.length - 1) {
widgets.add(
Padding(
padding: EdgeInsets.symmetric(
vertical: 4.h,
),
child: Divider(
height: 32.h,
color: Colors.grey.shade200,
thickness: 1,
),
),
);
}
}

return widgets;
}

// =================================================================
// HTML PARSER
// =================================================================

List<Widget> _parseHtmlInOrder(
String html,
) {
final List<Widget> widgets = [];

if (html.trim().isEmpty) {
return widgets;
}

String content = html;

content = content.replaceAll(
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

for (final ulMatch in ulRegex.allMatches(content)) {
final ulContent = ulMatch.group(1) ?? '';

final liRegex = RegExp(
r'<li[^>]*>(.*?)</li>',
dotAll: true,
caseSensitive: false,
);

final listItems = <String>[];

for (final liMatch in liRegex.allMatches(ulContent)) {
listItems.add(
_cleanText(
liMatch.group(1) ?? '',
),
);
}

if (listItems.isNotEmpty) {
widgets.addAll(
_renderListItems(listItems),
);
}
}

content = content.replaceAll(
RegExp(
r'<ul[^>]*>.*?</ul>',
dotAll: true,
caseSensitive: false,
),
'',
);

final blockRegex = RegExp(
r'<(h1|h2|h3|h4|p|div|br)[^>]*>(.*?)</\1>',
dotAll: true,
caseSensitive: false,
);

final matches = blockRegex.allMatches(content).toList();

if (matches.isEmpty) {
final cleaned = _cleanText(content);

if (cleaned.isNotEmpty) {
widgets.add(
Padding(
padding: EdgeInsets.only(
bottom: 12.h,
),
child: RichText(
text: TextSpan(
style: GoogleFonts.poppins(
fontSize: 14.sp,
height: 1.8,
color: Colors.grey.shade700,
),
children: _processBoldText(content),
),
),
),
);
}

return widgets;
}

int lastPosition = 0;

for (final match in matches) {
if (match.start > lastPosition) {
final before = content.substring(
lastPosition,
match.start,
);

final cleanedBefore = _cleanText(before);

if (cleanedBefore.isNotEmpty) {
widgets.add(
Padding(
padding: EdgeInsets.only(
bottom: 12.h,
),
child: RichText(
text: TextSpan(
style: GoogleFonts.poppins(
fontSize: 14.sp,
height: 1.8,
color: Colors.grey.shade700,
),
children: _processBoldText(before),
),
),
),
);
}
}

final tag = match.group(1)?.toLowerCase() ?? '';
final inner = match.group(2) ?? '';
final cleaned = _cleanText(inner);

if (cleaned.isNotEmpty) {
if (tag == 'h1') {
widgets.add(
Padding(
padding: EdgeInsets.only(
top: 4.h,
bottom: 8.h,
),
child: Text(
cleaned,
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
widgets.add(
Padding(
padding: EdgeInsets.only(
top: 16.h,
bottom: 8.h,
),
child: Text(
cleaned,
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
widgets.add(
Padding(
padding: EdgeInsets.only(
top: 14.h,
bottom: 6.h,
),
child: Text(
cleaned,
style: GoogleFonts.poppins(
fontSize: 15.sp,
fontWeight: FontWeight.w600,
color: Colors.black87,
height: 1.5,
),
),
),
);
} else if (tag == 'h4') {
widgets.add(
Padding(
padding: EdgeInsets.only(
top: 12.h,
bottom: 6.h,
),
child: Text(
cleaned,
style: GoogleFonts.poppins(
fontSize: 15.sp,
fontWeight: FontWeight.w600,
color: Colors.black87,
height: 1.5,
),
),
),
);
} else if (tag == 'p') {
widgets.add(
Padding(
padding: EdgeInsets.only(
bottom: 12.h,
),
child: RichText(
text: TextSpan(
style: GoogleFonts.poppins(
fontSize: 14.sp,
height: 1.8,
color: Colors.grey.shade700,
),
children: _processBoldText(inner),
),
),
),
);
} else if (tag == 'div') {
widgets.add(
Padding(
padding: EdgeInsets.only(
bottom: 10.h,
),
child: RichText(
text: TextSpan(
style: GoogleFonts.poppins(
fontSize: 14.sp,
height: 1.8,
color: Colors.grey.shade700,
),
children: _processBoldText(inner),
),
),
),
);
}
}

lastPosition = match.end;
}

if (lastPosition < content.length) {
final remaining = content.substring(lastPosition);
final cleanedRemaining = _cleanText(remaining);

if (cleanedRemaining.isNotEmpty) {
widgets.add(
Padding(
padding: EdgeInsets.only(
bottom: 12.h,
),
child: RichText(
text: TextSpan(
style: GoogleFonts.poppins(
fontSize: 14.sp,
height: 1.8,
color: Colors.grey.shade700,
),
children: _processBoldText(remaining),
),
),
),
);
}
}

return widgets;
}

// =================================================================
// LIST ITEMS
// =================================================================

List<Widget> _renderListItems(
List<String> items,
) {
final List<Widget> widgets = [];

for (final item in items) {
final cleanedItem = _cleanText(item);

if (cleanedItem.isEmpty) {
continue;
}

widgets.add(
Padding(
padding: EdgeInsets.only(
bottom: 8.h,
left: 10.w,
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: EdgeInsets.only(
top: 1.h,
),
child: Text(
'•',
style: GoogleFonts.poppins(
fontSize: 15.sp,
height: 1.8,
color: const Color(0xffFF6A00),
fontWeight: FontWeight.bold,
),
),
),

SizedBox(width: 8.w),

Expanded(
child: RichText(
text: TextSpan(
style: GoogleFonts.poppins(
fontSize: 14.sp,
height: 1.8,
color: Colors.grey.shade700,
),
children: _processBoldText(item),
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

// =================================================================
// BOLD TEXT
// =================================================================

List<TextSpan> _processBoldText(
String text,
) {
final List<TextSpan> spans = [];

final boldRegex = RegExp(
r'<(?:strong|b)[^>]*>(.*?)</(?:strong|b)>',
dotAll: true,
caseSensitive: false,
);

int position = 0;

final matches = boldRegex.allMatches(text).toList();

if (matches.isEmpty) {
final cleaned = _cleanText(text);

if (cleaned.isEmpty) {
return [];
}

return [
TextSpan(
text: cleaned,
),
];
}

for (final match in matches) {
if (match.start > position) {
final beforeText = text.substring(
position,
match.start,
);

final cleanedBefore = _cleanText(beforeText);

if (cleanedBefore.isNotEmpty) {
spans.add(
TextSpan(
text: cleanedBefore,
),
);
}
}

final boldText = match.group(1) ?? '';
final cleanedBold = _cleanText(boldText);

if (cleanedBold.isNotEmpty) {
spans.add(
TextSpan(
text: cleanedBold,
style: const TextStyle(
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
);
}

position = match.end;
}

if (position < text.length) {
final afterText = text.substring(position);
final cleanedAfter = _cleanText(afterText);

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

// =================================================================
// CLEAN HTML
// =================================================================

String _cleanText(
String text,
) {
String cleaned = text;

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
RegExp(
r'<!--.*?-->',
dotAll: true,
),
'',
);

cleaned = cleaned.replaceAll(
RegExp(r'\s+'),
' ',
);

return cleaned.trim();
}
}

