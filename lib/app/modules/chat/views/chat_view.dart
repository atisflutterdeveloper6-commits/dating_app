
// lib/app/modules/chat/views/chat_view.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/modules/chat/views/call_invitation_service.dart';
import 'package:dating_app/app/modules/chat/views/chat_service.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' as gf;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ChatView extends StatefulWidget {
const ChatView({super.key});

@override
State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
final TextEditingController messageController = TextEditingController();
final ScrollController scrollController = ScrollController();
final ImagePicker _picker = ImagePicker();

late final ChatService _chatService;

String? chatRoomId;
String? otherUserId;
String otherUserName = 'Srivalli';
String otherUserImage = '';
String? currentUserId;

bool _isLoading = true;
bool _isSending = false;
bool _otherUserOnline = false;
bool _isOtherUserTyping = false;

Timer? _typingDebounceTimer;
Timer? _markReadTimer;

bool _isFirstLoad = true;
bool _isMarkingRead = false;
String? _lastMessageId;
int _lastMessageCount = 0;

int _offlineConfirmCount = 0;

Future<void> _downloadOrOpenFile(String url) async {
try {
final uri = Uri.parse(url);

final launched = await launchUrl(
uri,
mode: LaunchMode.externalApplication,
);

if (!launched) {
CustomToast.error('Could not open file');
}
} catch (e) {
print('Error opening file: $e');
CustomToast.error('Could not open file');
}
}

void _showAttachMenu() {
showModalBottomSheet(
context: context,
builder: (context) => SafeArea(
child: Wrap(
children: [
ListTile(
leading: const Icon(
Icons.photo,
color: Color(0xffFF6A00),
),
title: const Text('Photo'),
onTap: () {
Navigator.pop(context);
_openGallery();
},
),
ListTile(
leading: const Icon(
Icons.videocam,
color: Color(0xffFF6A00),
),
title: const Text('Video'),
onTap: () {
Navigator.pop(context);
_pickVideo();
},
),
ListTile(
leading: const Icon(
Icons.insert_drive_file,
color: Color(0xffFF6A00),
),
title: const Text('Document'),
onTap: () {
Navigator.pop(context);
_pickDocument();
},
),
],
),
),
);
}

void _startCall(
bool isVideoCall, {
int retryCount = 0,
}) async {
if (currentUserId == null || currentUserId!.isEmpty) {
CustomToast.error(
'You must be logged in to start a call',
);
return;
}

if (otherUserId == null || otherUserId!.isEmpty) {
CustomToast.error(
'Cannot start call: user not found',
);
return;
}

final dashboardController =
Get.find<DashboardController>();

final bool granted =
await _checkCallPermissions(isVideoCall);

if (!granted) return;

final ready =
await dashboardController.ensureCallServiceReady();

if (!ready) {
CustomToast.error(
'Call service is currently unavailable. Please try again later.',
);
return;
}

try {
final bool success =
await CallInvitationService.sendInvitationWithRetry(
invitees: [
ZegoCallUser(
otherUserId!,
otherUserName,
),
],
isVideoCall: isVideoCall,
resourceID: "zego_call",
);

if (!success) {
dashboardController.markCallServiceUnavailable();

CustomToast.error(
'Call service is currently unavailable. Please try again later.',
);
return;
}

if (chatRoomId != null) {
_chatService.sendCallMessage(
chatRoomId: chatRoomId!,
isVideoCall: isVideoCall,
);
}
} catch (e) {
final errorStr = e.toString();

if (errorStr.contains('_pageManager') &&
retryCount < 2) {
print(
'⚠️ pageManager not ready yet, retrying... '
'(attempt ${retryCount + 1})',
);

await Future.delayed(
const Duration(milliseconds: 1000),
);

_startCall(
isVideoCall,
retryCount: retryCount + 1,
);

return;
}

if (errorStr.contains('signaling is not connected') ||
errorStr.contains('signaling plugin is null') ||
errorStr.contains('disconnected') ||
errorStr.contains('suspended') ||
errorStr.contains('expired')) {
dashboardController.markCallServiceUnavailable();

CustomToast.error(
'Call service is currently unavailable. Please try again later.',
);
} else if (errorStr.contains('107026') ||
errorStr.contains('not registered')) {
CustomToast.error(
'$otherUserName is currently unavailable.',
);
} else if (errorStr.contains('_pageManager')) {
CustomToast.error(
'Call service still starting up. Please try again.',
);
} else {
CustomToast.error(
'Failed to start call. Please try again.',
);
}
}
}

Future<bool> _checkCallPermissions(
bool isVideoCall,
) async {
final micStatus =
await Permission.microphone.status;

PermissionStatus camStatus =
PermissionStatus.granted;

if (isVideoCall) {
camStatus =
await Permission.camera.status;
}

if (micStatus.isGranted &&
(!isVideoCall || camStatus.isGranted)) {
return true;
}

final statuses = await [
Permission.microphone,
if (isVideoCall) Permission.camera,
].request();

final micGranted =
statuses[Permission.microphone]?.isGranted ??
false;

final camGranted = !isVideoCall ||
(statuses[Permission.camera]?.isGranted ??
false);

if (micGranted && camGranted) {
return true;
}

final permanentlyDenied =
statuses.values.any(
(s) => s.isPermanentlyDenied,
);

if (mounted) {
showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: const Text(
'Permission Required',
),
content: Text(
isVideoCall
? 'Call karne ke liye Camera aur Microphone permission allow karni hogi.'
    : 'Call karne ke liye Microphone permission allow karni hogi.',
),
actions: [
TextButton(
onPressed: () =>
Navigator.pop(ctx),
child: const Text('Cancel'),
),
TextButton(
onPressed: () async {
Navigator.pop(ctx);

if (permanentlyDenied) {
await openAppSettings();
} else {
await _checkCallPermissions(
isVideoCall,
);
}
},
child: const Text('Allow'),
),
],
),
);
}

return false;
}

String? _getCurrentUserId() {
try {
final storage =
Get.find<StorageService>();

final profileId =
storage.getProfileId();

if (profileId != null &&
profileId.isNotEmpty) {
return profileId;
}

final loginData =
storage.getLoginData();

if (loginData != null) {
final id =
loginData['profileId'] ??
loginData['profile_id'] ??
loginData['id'] ??
loginData['userId'] ??
loginData['_id'];

if (id != null &&
id.toString().isNotEmpty) {
return id.toString();
}
}

if (_chatService.currentUserId != null) {
return _chatService.currentUserId;
}

return null;
} catch (e) {
print(
'❌ Error getting current user ID: $e',
);
return null;
}
}

@override
void initState() {
super.initState();
_initializeChat();
}

Future<void> _initializeChat() async {
try {
_chatService = Get.find<ChatService>();

currentUserId =
_chatService.currentUserId;

final arguments =
Get.arguments as Map<String, dynamic>?;

if (arguments != null) {
otherUserId =
arguments['userId']?.toString();

otherUserName =
arguments['userName'] ??
'Srivalli';

otherUserImage =
arguments['userImage'] ?? '';

chatRoomId =
arguments['chatRoomId']?.toString();

if (otherUserId != null &&
otherUserId!.isNotEmpty) {
CallInvitationService
    .userAvatars[otherUserId!] =
otherUserImage;
}
}

if (chatRoomId == null ||
chatRoomId!.isEmpty) {
if (otherUserId != null &&
otherUserId!.isNotEmpty) {
chatRoomId =
await _chatService.getOrCreateChatRoom(
otherUserId!,
);
}
}

if (chatRoomId != null) {
_loadUserStatus();
_listenTypingStatus();

if (!_isMarkingRead) {
_isMarkingRead = true;

await _chatService.markMessagesAsRead(
chatRoomId!,
);
}
}

if (mounted) {
setState(() {
_isLoading = false;
_isFirstLoad = false;
});
}

_scrollToBottom();
} catch (e) {
print(
'Error initializing chat: $e',
);

if (mounted) {
setState(() {
_isLoading = false;
});
}
}
}

void _listenTypingStatus() {
if (chatRoomId == null ||
otherUserId == null) {
return;
}

_chatService
    .getConversationStream(chatRoomId!)
    .listen(
(snapshot) {
try {
if (snapshot.exists &&
mounted) {
final data =
snapshot.data()
as Map<String, dynamic>?;

final typingMap =
data?['typing']
as Map<String, dynamic>?;

final isTyping =
typingMap?[otherUserId] ?? false;

if (_isOtherUserTyping !=
isTyping) {
setState(() {
_isOtherUserTyping =
isTyping;
});
}
}
} catch (e) {
print(
'Error listening to typing status: $e',
);
}
},
onError: (error) {
print(
'Error in typing status stream: $error',
);
},
);
}

void _onMessageTextChanged(
String text,
) {
if (chatRoomId == null) return;

_chatService.setTypingStatus(
chatRoomId!,
text.isNotEmpty,
);

_typingDebounceTimer?.cancel();

if (text.isNotEmpty) {
_typingDebounceTimer = Timer(
const Duration(seconds: 3),
() {
_chatService.setTypingStatus(
chatRoomId!,
false,
);
},
);
}
}

void _loadUserStatus() {
if (otherUserId == null) return;

_chatService
    .getUserStatus(otherUserId!)
    .listen(
(snapshot) {
try {
if (snapshot.exists &&
mounted) {
final data =
snapshot.data()
as Map<String, dynamic>?;

final isOnlineFlag =
data?['online'] ?? false;

final lastSeen =
data?['lastSeen']
as Timestamp?;

bool computedOnline = false;

if (isOnlineFlag &&
lastSeen != null) {
final diff =
DateTime.now().difference(
lastSeen.toDate(),
);

computedOnline =
diff.inSeconds < 60;
} else if (isOnlineFlag &&
lastSeen == null) {
computedOnline =
_otherUserOnline;
}

if (!computedOnline) {
_offlineConfirmCount++;

if (_offlineConfirmCount < 2) {
return;
}
} else {
_offlineConfirmCount = 0;
}

if (_otherUserOnline !=
computedOnline) {
setState(() {
_otherUserOnline =
computedOnline;
});
}
}
} catch (e) {
print(
'Error loading user status: $e',
);
}
},
);
}

void _scrollToBottom() {
WidgetsBinding.instance
    .addPostFrameCallback((_) {
try {
if (scrollController.hasClients) {
scrollController.animateTo(
0,
duration:
const Duration(milliseconds: 300),
curve: Curves.easeOut,
);
}
} catch (e) {
print(
'Error scrolling: $e',
);
}
});
}

Future<void> _sendPushNotification({
required String message,
String? imageUrl,
String? fileName,
}) async {
try {
if (otherUserId == null ||
otherUserId!.isEmpty) {
print(
'⚠️ No otherUserId — skipping push notification',
);
return;
}

final storage =
Get.find<StorageService>();

final token =
storage.getLoginToken() ??
storage.getToken();

if (token == null ||
token.isEmpty) {
print(
'⚠️ No auth token — skipping push notification',
);
return;
}

String body;

if (imageUrl != null &&
imageUrl.isNotEmpty) {
body = '📷 Sent a photo';
} else if (fileName != null &&
fileName.isNotEmpty) {
body = '📎 $fileName';
} else if (message.isNotEmpty) {
body = message;
} else {
body = 'New message';
}

final response = await http.post(
Uri.parse(
'${ApiUrls.baseUrl}/v1/api/notification/send',
),
headers: {
'Accept': 'application/json',
'Content-Type':
'application/json',
'Authorization':
'Bearer $token',
},
body: jsonEncode({
'profileId': otherUserId,
'title': 'New message',
'body': body,
'data': {
'screen': 'chat',
'chatRoomId': chatRoomId,
},
}),
);

print(
'🔔 Notification Response: '
'${response.statusCode} ${response.body}',
);
} catch (e) {
print(
'❌ Error sending push notification: $e',
);
}
}

Future<void> _sendMessage({
String? imagePath,
String? filePath,
String? fileName,
}) async {
final text =
messageController.text.trim();

if (text.isEmpty &&
imagePath == null &&
filePath == null) {
return;
}

if (chatRoomId == null) {
CustomToast.error(
'Chat room not found',
);
return;
}

if (_isSending) {
return;
}

if (imagePath == null &&
filePath == null) {
messageController.clear();

_chatService.setTypingStatus(
chatRoomId!,
false,
);
}

setState(() {
_isSending = true;
});

try {
String? imageUrl;
String? uploadedFileUrl;

if (imagePath != null &&
imagePath.isNotEmpty) {
final file = File(imagePath);

if (!await file.exists()) {
throw Exception(
'Image file does not exist',
);
}

CustomToast.show(
message: 'Uploading image...',
backgroundColor: Colors.orange,
textColor: Colors.white,
duration: 2,
);

imageUrl =
await _chatService.uploadImage(file);

CustomToast.show(
message:
'Image uploaded successfully!',
backgroundColor: Colors.green,
textColor: Colors.white,
duration: 1,
);
}

if (filePath != null &&
filePath.isNotEmpty) {
final file = File(filePath);

if (!await file.exists()) {
throw Exception(
'File does not exist',
);
}

CustomToast.show(
message:
'Uploading ${fileName ?? "file"}...',
backgroundColor: Colors.orange,
textColor: Colors.white,
duration: 2,
);

uploadedFileUrl =
await _chatService.uploadFile(file);

CustomToast.show(
message:
'File uploaded successfully!',
backgroundColor: Colors.green,
textColor: Colors.white,
duration: 1,
);
}

await _chatService.sendMessage(
chatRoomId: chatRoomId!,
message: text,
imageUrl: imageUrl,
fileUrl: uploadedFileUrl,
fileName: fileName,
);

_sendPushNotification(
message: text,
imageUrl: imageUrl,
fileName: fileName,
);

messageController.clear();

_scrollToBottom();

_chatService.setTypingStatus(
chatRoomId!,
false,
);
} catch (e) {
CustomToast.error(
'Failed to send: ${e.toString()}',
);
} finally {
if (mounted) {
setState(() {
_isSending = false;
});
}
}
}

Future<void> _openCamera() async {
try {
final XFile? photo =
await _picker.pickImage(
source: ImageSource.camera,
imageQuality: 85,
);

if (photo != null) {
await _sendMessage(
imagePath: photo.path,
);
}
} catch (e) {
print(
'Error opening camera: $e',
);
CustomToast.error(
'Failed to open camera',
);
}
}

Future<void> _pickVideo() async {
try {
final XFile? video =
await _picker.pickVideo(
source: ImageSource.gallery,
);

if (video != null) {
final name =
video.path.split('/').last;

await _sendMessage(
filePath: video.path,
fileName: name,
);
}
} catch (e) {
print(
'Error picking video: $e',
);
CustomToast.error(
'Failed to pick video',
);
}
}

Future<void> _pickDocument() async {
try {
final result =
await FilePicker.platform.pickFiles(
type: FileType.custom,
allowedExtensions: [
'pdf',
'doc',
'docx',
'xls',
'xlsx',
'ppt',
'pptx',
'txt',
'zip',
],
);

if (result != null &&
result.files.single.path != null) {
final path =
result.files.single.path!;

final name =
result.files.single.name;

await _sendMessage(
filePath: path,
fileName: name,
);
}
} catch (e) {
print(
'Error picking document: $e',
);
CustomToast.error(
'Failed to pick document',
);
}
}

Future<void> _openFile(String url) async {
final uri = Uri.parse(url);

if (await canLaunchUrl(uri)) {
await launchUrl(
uri,
mode: LaunchMode.externalApplication,
);
} else {
CustomToast.error(
'Could not open file',
);
}
}

Future<void> _openGallery() async {
try {
final XFile? image =
await _picker.pickImage(
source: ImageSource.gallery,
imageQuality: 85,
);

if (image != null) {
await _sendMessage(
imagePath: image.path,
);
}
} catch (e) {
print(
'Error opening gallery: $e',
);
CustomToast.error(
'Failed to pick image',
);
}
}

void _showEmojiPicker() {
showModalBottomSheet(
context: context,
isScrollControlled: true,
builder: (context) => SizedBox(
height: 350.h,
child: emoji.EmojiPicker(
onEmojiSelected:
(category, emojiData) {
messageController.text +=
emojiData.emoji;
},
config: const emoji.Config(
height: 350,
checkPlatformCompatibility: true,
),
),
),
);
}

String _getMessageTime(
Timestamp? timestamp,
) {
if (timestamp == null) {
return 'Just now';
}

try {
final date = timestamp.toDate();
final now = DateTime.now();
final difference =
now.difference(date);

if (difference.inDays > 0) {
if (difference.inDays == 1) {
return 'Yesterday';
}

if (difference.inDays < 7) {
return '${difference.inDays}d ago';
}

return '${date.day}/${date.month}/${date.year}';
} else if (difference.inHours > 0) {
return '${difference.inHours}h ago';
} else if (difference.inMinutes > 0) {
return '${difference.inMinutes}m ago';
} else {
return 'Just now';
}
} catch (e) {
return 'Just now';
}
}

@override
void dispose() {
_typingDebounceTimer?.cancel();
_markReadTimer?.cancel();

messageController.dispose();
scrollController.dispose();

super.dispose();
}

@override
Widget build(BuildContext context) {
ScreenUtil.init(
context,
designSize: const Size(375, 812),
minTextAdapt: true,
splitScreenMode: true,
);

return Scaffold(
backgroundColor: const Color(0xFFF7F7F7),

// TRUE hi rakha hai
extendBodyBehindAppBar: true,

// Black bottom strip avoid karne ke liye false
extendBody: false,

appBar: _buildAppBar(),


body: Stack(
fit: StackFit.expand,
children: [
// Background
Positioned.fill(
    child: Container(
    color: const Color(0xFFF7F7F7),
  ),
  ),

  Positioned.fill(
  child: Image.asset(
  'assets/images/LoginBack2.png',
  fit: BoxFit.cover,
  ),
  ),

  // White overlay
  Positioned.fill(
  child: Container(
  color: Colors.white.withOpacity(0.70),
  ),
  ),

  // Main layout
  Positioned.fill(
  child: SafeArea(
  child: Padding(
  padding: EdgeInsets.fromLTRB(
  14.w,
  14.h,
  14.w,
  10.h,
  ),
  child: Column(
  children: [
  // ==============================
  // WHITE CHAT CONTAINER
  // ==============================
  Expanded(
  child: Container(
  width: double.infinity,
  padding: EdgeInsets.fromLTRB(
  10.w,
  12.h,
  10.w,
  10.h,
  ),
  decoration: BoxDecoration(
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
  ),
  child: Column(
  children: [
  // Today
  Container(
  padding: EdgeInsets.symmetric(
  horizontal: 12.w,
  vertical: 5.h,
  ),
  decoration: BoxDecoration(
  color: const Color(0xffE8DDD6),
  borderRadius: BorderRadius.circular(8.r),
  ),
  child: Text(
  'Today',
  style: gf.GoogleFonts.poppins(
  fontSize: 12.sp,
  color: Colors.black87,
  ),
  ),
  ),

  SizedBox(height: 12.h),

  // Messages
  Expanded(
  child: _isLoading
  ? const Center(
  child: CircularProgressIndicator(
  color: Color(0xffFF6A00),
  ),
  )
      : chatRoomId == null
  ? Center(
  child: Column(
  mainAxisAlignment:
  MainAxisAlignment.center,
  children: [
  Icon(
  Icons.chat_bubble_outline,
  size: 60.sp,
  color: Colors.grey.shade300,
  ),
  SizedBox(height: 16.h),
  Text(
  'No chat room found',
  style: gf.GoogleFonts.poppins(
  fontSize: 16.sp,
  color: Colors.grey.shade500,
  ),
  ),
  ],
  ),
  )
      : _buildMessagesStream(),
  ),
  ],
  ),
  ),
  ),

  // =================================
  // SPACE BETWEEN WHITE CONTAINER
  // AND TEXT FIELD
  // =================================
  SizedBox(height: 10.h),

  // =================================
  // MESSAGE INPUT - OUTSIDE CONTAINER
  // =================================
  SafeArea(
  top: false,
  child: Row(
  children: [
  Expanded(
  child: Container(
  height: 50.h,
  padding: EdgeInsets.symmetric(
  horizontal: 14.w,
  ),
  decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(25.r),
  border: Border.all(
  color: const Color(0xffFF6A00),
  width: 1.w,
  ),
  ),
  child: Row(
  children: [
  // Emoji
  GestureDetector(
  onTap: _showEmojiPicker,
  child: Icon(
  Icons.sentiment_satisfied_alt_outlined,
  color: Colors.grey.shade400,
  size: 22.sp,
  ),
  ),

  SizedBox(width: 8.w),

  // TextField
  Expanded(
  child: TextField(
  controller: messageController,
  decoration: InputDecoration(
  border: InputBorder.none,
  hintText: 'Type a message...',
  hintStyle: gf.GoogleFonts.poppins(
  fontSize: 13.sp,
  color: Colors.grey,
  ),
  ),
  onChanged: _onMessageTextChanged,
  onSubmitted: (_) => _sendMessage(),
  ),
  ),

  // Attachment
  GestureDetector(
  onTap: _showAttachMenu,
  child: Icon(
  Icons.attach_file,
  color: Colors.grey.shade400,
  size: 22.sp,
  ),
  ),

  SizedBox(width: 10.w),

  // Camera
  GestureDetector(
  onTap: _openCamera,
  child: Icon(
  Icons.camera_alt_outlined,
  color: Colors.grey.shade400,
  size: 22.sp,
  ),
  ),
  ],
  ),
  ),
  ),

  SizedBox(width: 10.w),

  // Send Button
  GestureDetector(
  onTap: _isSending ? null : _sendMessage,
  child: Container(
  height: 48.h,
  width: 48.w,
  decoration: const BoxDecoration(
  color: Color(0xffFF6A00),
  shape: BoxShape.circle,
  ),
  child: Center(
  child: Icon(
  Icons.send,
  color: Colors.white,
  size: 24.sp,
  ),
  ),
  ),
  ),
  ],
  ),
  ),
  ],
  ),
  ),
  ),
  ),
  ],
  ),


);
}

PreferredSizeWidget _buildAppBar() {
return AppBar(
backgroundColor: Colors.transparent,
elevation: 0,
surfaceTintColor: Colors.transparent,
shadowColor: Colors.transparent,

systemOverlayStyle:
const SystemUiOverlayStyle(
statusBarColor: Colors.transparent,
systemNavigationBarColor:
Colors.transparent,
statusBarIconBrightness:
Brightness.dark,
statusBarBrightness:
Brightness.light,
systemNavigationBarIconBrightness:
Brightness.dark,
),

flexibleSpace: Container(
decoration: BoxDecoration(
gradient: const LinearGradient(
begin: Alignment.centerLeft,
end: Alignment.centerRight,
colors: [
Color.fromARGB(
255,
253,
242,
234,
),
Color.fromARGB(
255,
253,
242,
234,
),
],
),
borderRadius: BorderRadius.only(
bottomLeft:
Radius.circular(24.r),
bottomRight:
Radius.circular(24.r),
),
),
),

leadingWidth: 70.w,

leading: Padding(
padding: EdgeInsets.only(left: 10.w),
child: IconButton(
onPressed: () => Get.back(),
padding: EdgeInsets.zero,
icon: Container(
width: 40.w,
height: 40.w,
decoration: BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color:
Colors.black.withOpacity(0.10),
blurRadius: 8.r,
offset: Offset(0, 3.h),
),
],
),
child: Center(
child: Icon(
Icons.chevron_left_rounded,
size: 24.sp,
color:
const Color(0xFFFF6B00),
),
),
),
),
),

titleSpacing: 5.w,

title: Row(
children: [
CircleAvatar(
radius: 18.r,
backgroundImage:
otherUserImage.isNotEmpty
? NetworkImage(
otherUserImage,
)
    : const AssetImage(
'assets/images/profile1.png',
) as ImageProvider,
),

SizedBox(width: 10.w),

Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
  SizedBox(
    width: 146.w,
    child: Text(
      otherUserName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: gf.GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
  ),

_isOtherUserTyping
? Text(
'typing...',
style:
gf.GoogleFonts.poppins(
fontSize: 11.sp,
color:
const Color(
0xffFF6A00,
),
fontStyle:
FontStyle.italic,
),
)
    : Row(
children: [
Container(
height: 7.h,
width: 7.w,
decoration:
BoxDecoration(
color:
_otherUserOnline
? Colors.green
    : Colors.grey,
shape:
BoxShape.circle,
),
),

SizedBox(width: 4.w),

Text(
_otherUserOnline
? 'Online'
    : 'Offline',
style: gf
    .GoogleFonts
    .poppins(
fontSize: 11.sp,
color: Colors
    .grey
    .shade600,
),
),
],
),
],
),
],
),

actions: [
Padding(
padding:
EdgeInsets.only(right: 12.w),
child: Row(
children: [
Obx(() {
final dashboardController =
Get.find<
DashboardController>();

return GestureDetector(
onTap: dashboardController
    .isCallServiceReady
    .value
? () => _startCall(true)
    : null,
child: Container(
width: 40.w,
height: 40.w,
decoration:
BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.10),
blurRadius: 8.r,
offset:
Offset(0, 3.h),
),
],
),
child: Opacity(
opacity: dashboardController
    .isCallServiceReady
    .value
? 1.0
    : 0.4,
child: Center(
child:
SvgPicture.asset(
"assets/icons/vc.svg",
width: 18.w,
height: 18.w,
colorFilter:
const ColorFilter
    .mode(
Color(
0xFFFF6A00,
),
BlendMode.srcIn,
),
),
),
),
),
);
}),

SizedBox(width: 10.w),

GestureDetector(
onTap: () =>
_startCall(false),
child: Container(
width: 40.w,
height: 40.w,
decoration:
BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.10),
blurRadius: 8.r,
offset:
Offset(0, 3.h),
),
],
),
child: Center(
child:
SvgPicture.asset(
"assets/icons/Call.svg",
width: 18.w,
height: 18.w,
colorFilter:
const ColorFilter.mode(
Color(0xFFFF6A00),
BlendMode.srcIn,
),
),
),
),
),
],
),
),
],
);
}

Widget _buildMessagesStream() {
return StreamBuilder<QuerySnapshot>(
stream: _chatService
    .getMessages(chatRoomId!),
builder: (
context,
AsyncSnapshot<QuerySnapshot>
snapshot,
) {
if (snapshot.connectionState ==
ConnectionState.waiting &&
!snapshot.hasData) {
return const Center(
child: CircularProgressIndicator(
color: Color(0xffFF6A00),
),
);
}

if (snapshot.hasError) {
final errStr =
snapshot.error.toString();

final isPermRace =
errStr.contains(
'permission-denied',
) ||
errStr.contains(
'PERMISSION_DENIED',
);

if (isPermRace) {
Future.delayed(
const Duration(
milliseconds: 800,
),
() {
if (mounted) {
setState(() {});
}
},
);

return const Center(
child: CircularProgressIndicator(
color: Color(0xffFF6A00),
),
);
}

return Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.error_outline,
size: 60.sp,
color: Colors.red,
),
SizedBox(height: 16.h),
Text(
'Error loading messages',
style: gf.GoogleFonts.poppins(
fontSize: 16.sp,
color: Colors.red,
),
),
SizedBox(height: 8.h),
Text(
snapshot.error.toString(),
style: gf.GoogleFonts.poppins(
fontSize: 12.sp,
color:
Colors.grey.shade600,
),
),
],
),
);
}

if (!snapshot.hasData ||
snapshot.data == null ||
snapshot.data!.docs.isEmpty) {
return Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.chat_bubble_outline,
size: 60.sp,
color: Colors.grey.shade300,
),
SizedBox(height: 16.h),
Text(
'No messages yet',
style: gf.GoogleFonts.poppins(
fontSize: 16.sp,
color: Colors.grey.shade500,
),
),
SizedBox(height: 8.h),
Text(
'Say hello to $otherUserName',
style: gf.GoogleFonts.poppins(
fontSize: 14.sp,
color: Colors.grey.shade400,
),
),
],
),
);
}

final messages =
snapshot.data!.docs;

final currentMessageCount =
messages.length;

if (chatRoomId != null &&
currentMessageCount >
_lastMessageCount) {
_lastMessageCount =
currentMessageCount;

if (messages.isNotEmpty) {
final lastMsg =
messages.last.data()
as Map<String, dynamic>;

final lastMsgSender =
lastMsg['senderId'] ?? '';

final myId = currentUserId;

if (lastMsgSender != myId &&
lastMsgSender
    .toString()
    .isNotEmpty) {
_markMessagesAsReadDebounced(
chatRoomId!,
);
}
}
}

if (messages.isNotEmpty) {
_lastMessageId =
messages.last.id;
}

return NotificationListener<
ScrollNotification>(
onNotification:
(ScrollNotification
scrollInfo) {
return true;
},
child: ListView.builder(
key: const PageStorageKey(
'chat_messages_list',
),
controller:
scrollController,
padding:
EdgeInsets.symmetric(
horizontal: 6.w,
vertical: 8.h,
),
reverse: true,
itemCount: messages.length,
itemBuilder:
(context, index) {
try {
final reversedIndex =
messages.length -
1 -
index;

final doc =
messages[reversedIndex];

final msg =
doc.data()
as Map<String, dynamic>;

msg['id'] = doc.id;

final isSender =
msg['senderId'] ==
currentUserId;

final messageType =
msg['type'] ?? 'text';

final hasImage =
msg['imageUrl'] != null &&
msg['imageUrl']
    .toString()
    .isNotEmpty;

final hasFile =
msg['fileUrl'] != null &&
msg['fileUrl']
    .toString()
    .isNotEmpty;

final messageText =
msg['message'] ?? '';

final timestamp =
msg['timestamp']
as Timestamp?;

final time =
_getMessageTime(timestamp);

if (messageType == 'call') {
return RepaintBoundary(
key: ValueKey(doc.id),
child: _callMessage(
callType:
msg['callType'] ??
'voice',
time: time,
isSender: isSender,
),
);
}

if (hasFile) {
return RepaintBoundary(
key: ValueKey(doc.id),
child: _buildFileMessage(
fileUrl:
msg['fileUrl'],
fileName:
msg['fileName'] ??
'File',
time: time,
isSender: isSender,
),
);
}

return RepaintBoundary(
key: ValueKey(doc.id),
child: hasImage
? _buildImageMessage(
imageUrl:
msg['imageUrl'],
time: time,
isSender:
isSender,
)
    : isSender
? _senderMessage(
message:
messageText,
time: time,
)
    : _receiverMessage(
message:
messageText,
time: time,
),
);
} catch (e) {
print(
'❌ Error building message: $e',
);

return const SizedBox.shrink();
}
},
),
);
},
);
}

void _markMessagesAsReadDebounced(
String chatRoomId,
) {
_markReadTimer?.cancel();

_markReadTimer = Timer(
const Duration(milliseconds: 500),
() async {
if (!_isMarkingRead) {
_isMarkingRead = true;

await _chatService.markMessagesAsRead(
chatRoomId,
);

_isMarkingRead = false;
}
},
);
}

Widget _senderMessage({
required String message,
required String time,
}) {
return Align(
alignment: Alignment.centerRight,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [
Container(
constraints:
BoxConstraints(
maxWidth: 250.w,
),
padding:
EdgeInsets.symmetric(
horizontal: 14.w,
vertical: 10.h,
),
decoration:
const BoxDecoration(
color: Color(0xffFF6A00),
borderRadius:
BorderRadius.only(
topLeft:
Radius.circular(14),
topRight:
Radius.circular(14),
bottomLeft:
Radius.circular(14),
),
),
child: Text(
message,
style: gf.GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.white,
),
),
),
SizedBox(height: 3.h),
Text(
time,
style: gf.GoogleFonts.poppins(
fontSize: 10.sp,
color: Colors.grey,
),
),
SizedBox(height: 8.h),
],
),
);
}

Widget _callMessage({
required String callType,
required String time,
required bool isSender,
}) {
return Align(
alignment: Alignment.center,
child: Container(
margin:
EdgeInsets.symmetric(
vertical: 6.h,
),
padding:
EdgeInsets.symmetric(
horizontal: 14.w,
vertical: 8.h,
),
decoration:
BoxDecoration(
color: Colors.grey.shade200,
borderRadius:
BorderRadius.circular(20.r),
),
child: Row(
mainAxisSize:
MainAxisSize.min,
children: [
Icon(
callType == 'video'
? Icons.videocam
    : Icons.call,
size: 16.sp,
color:
const Color(0xffFF6A00),
),
SizedBox(width: 6.w),
Text(
'${isSender ? "Outgoing" : "Incoming"} '
'${callType == "video" ? "video" : "voice"} call',
style: gf.GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.black87,
),
),
SizedBox(width: 6.w),
Text(
time,
style: gf.GoogleFonts.poppins(
fontSize: 10.sp,
color: Colors.grey,
),
),
],
),
),
);
}

Widget _receiverMessage({
required String message,
required String time,
}) {
return Align(
alignment: Alignment.centerLeft,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
constraints:
BoxConstraints(
maxWidth: 180.w,
),
padding:
EdgeInsets.symmetric(
horizontal: 14.w,
vertical: 10.h,
),
decoration:
BoxDecoration(
color:
const Color(0xffA89D99),
borderRadius:
BorderRadius.circular(8.r),
),
child: Text(
message,
style: gf.GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.white,
),
),
),
SizedBox(height: 3.h),
Text(
time,
style: gf.GoogleFonts.poppins(
fontSize: 10.sp,
color: Colors.grey,
),
),
SizedBox(height: 8.h),
],
),
);
}

Widget _buildFileMessage({
required String fileUrl,
required String fileName,
required String time,
required bool isSender,
}) {
final ext =
fileName.split('.').last.toLowerCase();

IconData icon;

if (ext == 'pdf') {
icon = Icons.picture_as_pdf;
} else if ([
'mp4',
'mov',
'avi',
].contains(ext)) {
icon = Icons.videocam;
} else if ([
'doc',
'docx',
].contains(ext)) {
icon = Icons.description;
} else if ([
'xls',
'xlsx',
].contains(ext)) {
icon = Icons.table_chart;
} else {
icon = Icons.insert_drive_file;
}

return Align(
alignment: isSender
? Alignment.centerRight
    : Alignment.centerLeft,
child: Column(
crossAxisAlignment: isSender
? CrossAxisAlignment.end
    : CrossAxisAlignment.start,
children: [
GestureDetector(
onTap: () => _openFile(fileUrl),
child: Container(
constraints:
BoxConstraints(
maxWidth: 220.w,
),
padding:
EdgeInsets.symmetric(
horizontal: 12.w,
vertical: 10.h,
),
decoration:
BoxDecoration(
color: isSender
? const Color(0xffFF6A00)
    : const Color(0xffA89D99),
borderRadius:
BorderRadius.circular(12.r),
),
child: Row(
children: [
Icon(
icon,
color: Colors.white,
size: 28.sp,
),
SizedBox(width: 10.w),
Expanded(
child: Text(
fileName,
maxLines: 2,
overflow:
TextOverflow.ellipsis,
style:
gf.GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.white,
),
),
),
SizedBox(width: 6.w),
Icon(
Icons.download,
color: Colors.white,
size: 18.sp,
),
],
),
),
),
SizedBox(height: 3.h),
Text(
time,
style: gf.GoogleFonts.poppins(
fontSize: 10.sp,
color: Colors.grey,
),
),
SizedBox(height: 8.h),
],
),
);
}

Widget _buildImageMessage({
required String imageUrl,
required String time,
required bool isSender,
}) {
return Align(
alignment: isSender
? Alignment.centerRight
    : Alignment.centerLeft,
child: Column(
crossAxisAlignment: isSender
? CrossAxisAlignment.end
    : CrossAxisAlignment.start,
children: [
Stack(
children: [
ClipRRect(
borderRadius:
BorderRadius.circular(12.r),
child: Image.network(
imageUrl,
width: 220.w,
fit: BoxFit.cover,
errorBuilder:
(
context,
error,
stackTrace,
) {
return Container(
width: 220.w,
height: 180.h,
color: Colors.grey.shade300,
child: Icon(
Icons.broken_image,
size: 50.sp,
),
);
},
),
),

if (!isSender)
Positioned.fill(
child: Center(
child: GestureDetector(
onTap: () =>
_downloadOrOpenFile(
imageUrl,
),
child: Container(
padding:
EdgeInsets.all(10.w),
decoration:
BoxDecoration(
color: Colors.black
    .withOpacity(0.45),
shape:
BoxShape.circle,
),
child: Icon(
Icons.download,
color: Colors.white,
size: 24.sp,
),
),
),
),
),
],
),

SizedBox(height: 4.h),

Text(
time,
style: gf.GoogleFonts.poppins(
fontSize: 10.sp,
color: Colors.grey,
),
),

SizedBox(height: 8.h),
],
),
);
}
}

