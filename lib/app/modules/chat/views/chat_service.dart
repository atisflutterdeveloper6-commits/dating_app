// lib/app/services/chat_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/app/modules/chat/views/upload_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';

class ChatService extends GetxService with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StorageService? _storageService;
  // ✅ Har API call se pehle token proactively refresh karo agar zaroorat ho
  Future<void> _ensureValidToken() async {
    try {
      final chatService = Get.find<ChatService>();
      await chatService.getValidAuthToken(); // internally refresh karta hai agar expire hone wala ho
    } catch (e) {
      print('⚠️ Could not ensure valid token: $e');
    }
  }
  // ✅ Token refresh state
  bool _isRefreshingToken = false;
  DateTime? _tokenExpiryTime;
  
  StorageService get storageService {
    if (_storageService == null) {
      try {
        _storageService = Get.find<StorageService>();
      } catch (e) {
        print('❌ StorageService not found, creating new instance');
        _storageService = StorageService();
        if (!Get.isRegistered<StorageService>()) {
          Get.put(_storageService!, permanent: true);
        }
      }
    }
    return _storageService!;
  }
  Timer? _heartbeatTimer;

void _startHeartbeat() {
  _heartbeatTimer?.cancel();
  _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
    updateOnlineStatus(true);  // ✅ har 30 second me lastSeen refresh hoga
  });
}

void _stopHeartbeat() {
  _heartbeatTimer?.cancel();
  _heartbeatTimer = null;
}
  @override
  void onInit() {
    super.onInit();
      WidgetsBinding.instance.addObserver(this); 
    try {
      _storageService = Get.find<StorageService>();
      print('✅ ChatService: StorageService found');
    } catch (e) {
      print('❌ ChatService: StorageService not found, creating new');
      _storageService = StorageService();
      if (!Get.isRegistered<StorageService>()) {
        Get.put(_storageService!, permanent: true);
      }
    }
  }
  
  // ============================================================
  // ✅ COMPLETE TOKEN MANAGEMENT
  // ============================================================
  
  /// Refresh Firebase token (for Firestore)
  Future<bool> refreshFirebaseToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.getIdToken(true); // Force refresh
        print('✅ Firebase token refreshed');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error refreshing Firebase token: $e');
      return false;
    }
  }
  
  /// Get valid auth token for backend API with auto-refresh
Future<String?> getValidAuthToken() async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ No Firebase user logged in');
      return null;
    }

    // ✅ Firebase apna ID token khud refresh kar sakta hai — 
    // isse hamesha fresh, valid token milega (agar user session valid hai)
    final freshToken = await user.getIdToken(true);

    if (freshToken != null && freshToken.isNotEmpty) {
      // Storage me bhi update kar do taaki baaki app consistent rahe
      storageService.setAuthToken(freshToken);
      return freshToken;
    }

    return null;
  } catch (e) {
    print('❌ Error getting valid auth token: $e');
    return null;
  }
}
  /// Check if token needs refresh
  bool _needsTokenRefresh() {
    // If we don't have expiry time, assume needs refresh
    if (_tokenExpiryTime == null) return true;
    
    // Refresh if token expires in less than 5 minutes
    final timeUntilExpiry = _tokenExpiryTime!.difference(DateTime.now());
    return timeUntilExpiry.inMinutes < 5;
  }
  
  /// Refresh backend API token
Future<bool> refreshBackendToken() async {
  if (_isRefreshingToken) {
    print('⏳ Token refresh already in progress');
    return false;
  }
  
  _isRefreshingToken = true;
  print('🔄 Refreshing backend token...');
  
  try {
    final refreshToken = storageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      print('❌ No refresh token available, need to re-login');
      _isRefreshingToken = false;
      return false;
    }
    
    // Call your refresh token API
    final response = await http.post(
      Uri.parse('${ApiUrls.baseUrl}/v1/api/auth/refresh-token'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'refreshToken': refreshToken,
      }),
    );
    
    print('📥 Refresh token response: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      
      // Extract new tokens from response
      String? newAccessToken;
      String? newRefreshToken;
      int expiresIn = 3600; // ✅ Default to 1 hour (non-nullable)
      
      // Handle different response formats
      if (data.containsKey('data')) {
        final responseData = data['data'];
        newAccessToken = responseData['accessToken'] ?? 
                        responseData['token'] ?? 
                        responseData['access_token'];
        newRefreshToken = responseData['refreshToken'] ?? 
                         responseData['refresh_token'];
        // ✅ Handle null with null-aware operator and fallback
        expiresIn = (responseData['expiresIn'] as int?) ?? 3600;
      } else {
        newAccessToken = data['accessToken'] ?? data['token'] ?? data['access_token'];
        newRefreshToken = data['refreshToken'] ?? data['refresh_token'];
        // ✅ Handle null with null-aware operator and fallback
        expiresIn = (data['expiresIn'] as int?) ?? 3600;
      }
      
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        // Save new tokens
        if (newRefreshToken != null) {
          storageService.setRefreshToken(newRefreshToken);
        }
        storageService.setAuthToken(newAccessToken);
        
        // Update expiry time - ✅ expiresIn is guaranteed to be non-null now
        _tokenExpiryTime = DateTime.now().add(Duration(seconds: expiresIn));
        
        print('✅ Backend token refreshed successfully');
        print('✅ Token expires at: $_tokenExpiryTime');
        _isRefreshingToken = false;
        return true;
      } else {
        print('❌ No access token in refresh response');
        _isRefreshingToken = false;
        return false;
      }
    } else {
      // Token refresh failed, need to re-login
      print('❌ Token refresh failed with status: ${response.statusCode}');
      _isRefreshingToken = false;
      _handleTokenExpired();
      return false;
    }
  } catch (e) {
    print('❌ Error refreshing backend token: $e');
    _isRefreshingToken = false;
    return false;
  }
}
  /// Handle token expiry - show login dialog
  void _handleTokenExpired() {
    // Only show dialog if not already showing
    if (Get.isDialogOpen ?? false) return;
 
 
  }
  
  // ============================================================
  // ✅ GETTER METHODS
  // ============================================================
  
  // ✅ Get Firebase User UID
  String? get firebaseUid {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return user.uid;
      }
      return null;
    } catch (e) {
      print('Error getting Firebase UID: $e');
      return null;
    }
  }
  
  // ✅ Get current user ID from storage
String? get currentUserId {
  try {
    // ✅ Try from storage service directly
    final storage = Get.find<StorageService>();
    final profileId = storage.getProfileId();
    if (profileId != null && profileId.isNotEmpty) {
      return profileId;
    }
    
    // Try from login data
    final loginData = storage.getLoginData();
    if (loginData != null) {
      final id = loginData['profileId'] ?? 
                 loginData['profile_id'] ?? 
                 loginData['id'] ?? 
                 loginData['userId'] ??
                 loginData['_id'];
      if (id != null && id.toString().isNotEmpty) {
        return id.toString();
      }
    }
    
    // Fallback to storage service method
    return storageService.getProfileId();
  } catch (e) {
    print('Error getting current user ID: $e');
    return null;
  }
}
  String? get authToken {
    try {
      return storageService.getAuthToken();
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }
  
  Map<String, dynamic>? get currentUserProfile {
    try {
      final profileData = storageService.getProfileData();
      if (profileData != null) {
        return profileData;
      }
      return storageService.getLoginData();
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }
  
  // ============================================================
  // ✅ CHAT API METHODS WITH TOKEN REFRESH
  // ============================================================
  
  Future<Map<String, dynamic>?> startChat(String otherProfileId) async {
    try {
      // ✅ Get valid token with auto-refresh
      final token = await getValidAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final url = '${ApiUrls.baseUrl}/v1/api/chat/start';
      
      print('📤 Starting chat with profile: $otherProfileId');
      print('📤 URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'otherProfileId': otherProfileId,
        }),
      );

      print('📥 Response Status: ${response.statusCode}');
      
      // ✅ Handle 401 Unauthorized - Token expired
      if (response.statusCode == 401) {
        print('⚠️ Token expired, attempting refresh...');
        final refreshed = await refreshBackendToken();
        if (refreshed) {
          // Retry with new token
          return await startChat(otherProfileId);
        } else {
          _handleTokenExpired();
          return null;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        print('❌ Error: ${data['message'] ?? 'Unknown error'}');
        return null;
      }
    } catch (e) {
      print('❌ Error starting chat: $e');
      return null;
    }
  }
  
  String? getChatRoomId(Map<String, dynamic> response) {
    try {
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          if (data.containsKey('conversationId')) {
            return data['conversationId']?.toString();
          }
          return data['chatRoomId'] ?? data['chatId'] ?? data['id'] ?? data['_id'];
        }
      }
      return response['chatRoomId'] ?? 
             response['chatId'] ?? 
             response['id'] ?? 
             response['_id'] ??
             response['conversationId'];
    } catch (e) {
      print('Error extracting chat room ID: $e');
      return null;
    }
  }
  
  // ============================================================
  // ✅ FIRESTORE METHODS WITH TOKEN REFRESH
  // ============================================================
  
  Future<String> getOrCreateChatRoom(String otherUserId) async {
    try {
      // ✅ Refresh Firebase token before Firestore operations
      await refreshFirebaseToken();
      
      final myId = currentUserId;
      final myFirebaseUid = firebaseUid;
      
      if (myId == null) throw Exception('User not authenticated');
      if (myFirebaseUid == null) throw Exception('Firebase user not found');
      if (myId == otherUserId) throw Exception('Cannot chat with yourself');
      
      // Get other user's Firebase UID
      final otherFirebaseUid = await _getFirebaseUidByProfileId(otherUserId);
      
      List<String> userIds = [myId, otherUserId]..sort();
      List<String> firebaseUids = [myFirebaseUid, otherFirebaseUid]..sort();
      String chatRoomId = userIds.join('_');
      
      print('📤 Creating/Getting conversation...');
      print('📤 ChatRoomId: $chatRoomId');
      print('📤 Firebase UIDs: $firebaseUids');
      
      // Check if conversation exists with retry
      DocumentSnapshot chatDoc;
      try {
        chatDoc = await _firestore.collection('conversations').doc(chatRoomId).get();
      } catch (e) {
        if (e.toString().contains('PERMISSION_DENIED') || e.toString().contains('expired')) {
          await refreshFirebaseToken();
          chatDoc = await _firestore.collection('conversations').doc(chatRoomId).get();
        } else {
          rethrow;
        }
      }
      
      if (!chatDoc.exists) {
        final myDetails = await _getUserDetails(myId);
        final otherDetails = await _getUserDetails(otherUserId);
        
        // ✅ Create conversation with participantFirebaseUids (required by rules)
        await _firestore.collection('conversations').doc(chatRoomId).set({
          'participants': userIds,
          'participantFirebaseUids': firebaseUids, // ✅ REQUIRED by rules
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSender': '',
          'lastMessageType': 'text',
          'participantDetails': {
            userIds[0]: myDetails,
            userIds[1]: otherDetails,
          },
          'unreadCount': {
            userIds[0]: 0,
            userIds[1]: 0,
          },
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Conversation created: $chatRoomId');
      }
      
      return chatRoomId;
    } catch (e) {
      print('Error creating chat room: $e');
      rethrow;
    }
  }
  
  // ✅ Get Firebase UID by profile ID
Future<String> _getFirebaseUidByProfileId(String profileId) async {
  final userDoc = await _firestore.collection('users').doc(profileId).get();
  if (userDoc.exists) {
    final data = userDoc.data();
    if (data != null && data['firebaseUid'] != null && data['firebaseUid'].toString().isNotEmpty) {
      return data['firebaseUid'] as String;
    }
  }
  throw Exception('Firebase UID not found for profile: $profileId. Ensure user document is created on login.');
}
  Future<void> sendCallMessage({
    required String chatRoomId,
    required bool isVideoCall,
  }) async {
    try {
      await refreshFirebaseToken();

      final myId = currentUserId;
      final myFirebaseUid = firebaseUid;

      if (myId == null) throw Exception('User not authenticated');
      if (myFirebaseUid == null) throw Exception('Firebase user not found');

      final callLabel = isVideoCall ? '📹 Video call' : '📞 Voice call';

      final messageData = {
        'senderId': myId,
        'senderFirebaseUid': myFirebaseUid,
        'message': callLabel,
        'imageUrl': '',
        'videoUrl': '',
        'audioUrl': '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'call',
        'callType': isVideoCall ? 'video' : 'voice',
        'readBy': [myId],
        'deliveredTo': [myId],
        'isDeleted': false,
        'replyTo': '',
      };

      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);

      await _firestore.collection('conversations').doc(chatRoomId).update({
        'lastMessage': callLabel,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': myId,
        'lastMessageType': 'call',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Call message saved to Firestore');
    } catch (e) {
      print('❌ Error saving call message: $e');
    }
  }
  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() ?? {};
      }
      
      if (userId == currentUserId) {
        final profile = currentUserProfile;
        if (profile != null) {
          return {
            'name': '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim() ?? 'User',
            'photoURL': profile['profileImage'] ?? profile['image'] ?? '',
            'phone': profile['phone'] ?? '',
            'email': profile['email'] ?? '',
            'firebaseUid': firebaseUid ?? '',
          };
        }
      }
      
      return {'name': 'User', 'photoURL': ''};
    } catch (e) {
      return {'name': 'User', 'photoURL': ''};
    }
  }
  
Future<void> ensureUserDocument(String userId) async {
  try {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      final details = await _getUserDetails(userId);
      final targetFirebaseUid = await _getFirebaseUidByProfileId(userId); // ✅ sahi UID nikaalo
      await _firestore.collection('users').doc(userId).set({
        ...details,
        'firebaseUid': targetFirebaseUid, // ✅ ab userId ka khud ka UID hai
        'online': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Created user document for: $userId');
    }
  } catch (e) {
    print('Error ensuring user document: $e');
  }
}


Future<void> saveUserProfileToFirestore() async {
    try {
      final userId = currentUserId;
      final uid = firebaseUid;
      if (userId == null || uid == null) return;
      
      final profile = currentUserProfile;
      if (profile == null) return;
      
      // ✅ photos array se pehli image ka URL nikalo
      String photoUrl = '';
      final photos = profile['photos'];
      if (photos != null && photos is List && photos.isNotEmpty) {
        final firstPhoto = photos[0];
        if (firstPhoto is Map && firstPhoto['image'] != null) {
          photoUrl = firstPhoto['image'].toString();
        }
      }
      
      await _firestore.collection('users').doc(userId).set(
        {
          'name': '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim(),
          'photoURL': photoUrl, // ✅ ab photos array se sahi URL aayega
          'phone': profile['phone'] ?? '',
          'email': profile['email'] ?? '',
          'age': profile['age'] ?? 0,
          'gender': profile['gender'] ?? '',
          'location': profile['location'] ?? '',
          'firebaseUid': uid,
          'updatedAt': FieldValue.serverTimestamp(),
          'online': true,
          'lastSeen': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      print('✅ User profile saved to Firestore with photo: $photoUrl');
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }
  Future<bool> validateFile(File file) async {
    try {
      if (!await file.exists()) {
        print('❌ File does not exist: ${file.path}');
        return false;
      }
      
      final size = await file.length();
      if (size == 0) {
        print('❌ File is empty: ${file.path}');
        return false;
      }
      
      print('✅ File validated: ${file.path} (${size} bytes)');
      return true;
    } catch (e) {
      print('❌ Error validating file: $e');
      return false;
    }
  }
  
  // Helper method to get content type
  String _getContentType(String filePath) {
    final ext = filePath.toLowerCase();
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) return 'image/jpeg';
    if (ext.endsWith('.png')) return 'image/png';
    if (ext.endsWith('.gif')) return 'image/gif';
    if (ext.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg'; // default
  }
  
  // ============================================================
  // ✅ MESSAGE METHODS WITH TOKEN REFRESH
  // ============================================================
  
  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
       String? fileUrl,   // ✅ add
    String? fileName,
  }) async {
    try {
      // ✅ Refresh Firebase token
      await refreshFirebaseToken();
      
      final myId = currentUserId;
      final myFirebaseUid = firebaseUid;
      
      if (myId == null) throw Exception('User not authenticated');
      if (myFirebaseUid == null) throw Exception('Firebase user not found');
      
      print('📤 ========================================');
      print('📤 SAVING TO FIRESTORE');
      print('📤 ChatRoomId: $chatRoomId');
      print('📤 Message: $message');
      print('📤 IMAGE URL: $imageUrl');
      print('📤 ========================================');
      
      // ✅ Create message data
      final messageData = {
        'senderId': myId,
        'senderFirebaseUid': myFirebaseUid,
        'message': message,
        'imageUrl': imageUrl ?? '',
        'videoUrl': videoUrl ?? '',
        'audioUrl': audioUrl ?? '',
          'fileUrl': fileUrl ?? '',    // ✅ add
        'fileName': fileName ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': _getMessageType(message, imageUrl, videoUrl, audioUrl),
        'readBy': [myId],
        'deliveredTo': [myId],
        'isDeleted': false,
        'replyTo': '',
      };
      
      print('📤 Message Data:');
      print('📤   senderId: $myId');
      print('📤   imageUrl: ${messageData['imageUrl']}');
      print('📤   message: $message');
      print('📤   type: ${messageData['type']}');
      
      // ✅ Save to Firestore with retry
      try {
        final docRef = await _firestore
            .collection('conversations')
            .doc(chatRoomId)
            .collection('messages')
            .add(messageData);
        print('✅ Message saved to Firestore with ID: ${docRef.id}');
      } catch (e) {
        if (e.toString().contains('PERMISSION_DENIED') || e.toString().contains('expired')) {
          await refreshFirebaseToken();
          final docRef = await _firestore
              .collection('conversations')
              .doc(chatRoomId)
              .collection('messages')
              .add(messageData);
          print('✅ Message saved to Firestore with ID: ${docRef.id}');
        } else {
          rethrow;
        }
      }
      
      print('✅ Image URL in Firestore: ${messageData['imageUrl']}');
      
      // ✅ Update conversation
      final lastMessage = message.isNotEmpty ? message : 
                         (imageUrl != null && imageUrl.isNotEmpty ? '📷 Image' : 
                         (videoUrl != null && videoUrl.isNotEmpty ? '🎥 Video' : 
                         (audioUrl != null && audioUrl.isNotEmpty ? '🎵 Audio' : '')));
                           (fileUrl != null && fileUrl.isNotEmpty ? '📎 ${fileName ?? "File"}' : '');
      
      await _firestore.collection('conversations').doc(chatRoomId).update({
        'lastMessage': lastMessage,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': myId,
        'lastMessageType': _getMessageType(message, imageUrl, videoUrl, audioUrl, fileUrl), // ✅ fileUrl add
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Conversation updated');
      print('📤 ========================================');
      
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }
  
String _getMessageType(String message, String? imageUrl, String? videoUrl, String? audioUrl, [String? fileUrl]) {
    if (videoUrl != null && videoUrl.isNotEmpty) return 'video';
    if (audioUrl != null && audioUrl.isNotEmpty) return 'audio';
    if (imageUrl != null && imageUrl.isNotEmpty) return 'image';
    if (fileUrl != null && fileUrl.isNotEmpty) return 'file'; // ✅ add
    if (message.isNotEmpty) return 'text';
    return 'text';
  }
  
  // ✅ Latest messages first (newest at bottom)
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    try {
      return _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e) {
      print('Error setting up messages stream: $e');
      return Stream.empty();
    }
  }
  
  // ✅ Updated markMessagesAsRead - No index required
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      final myId = currentUserId;
      if (myId == null) return;
      
      // ✅ Get all messages first (no where conditions)
      final messages = await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .get();
      
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        final data = doc.data();
        final senderId = data['senderId'] ?? '';
        final readBy = List<String>.from(data['readBy'] ?? []);
        
        // ✅ Only update if sender is not current user and not already read
        if (senderId != myId && !readBy.contains(myId)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([myId]),
          });
        }
      }
      await batch.commit();
      
      // ✅ Reset unread count
      await _firestore.collection('conversations').doc(chatRoomId).update({
        'unreadCount.$myId': 0,
      });
      
      print('✅ Messages marked as read');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
  
  Future<int> getUnreadCountForChat(String chatRoomId) async {
    try {
      final myId = currentUserId;
      if (myId == null) return 0;
      
      final chatDoc = await _firestore.collection('conversations').doc(chatRoomId).get();
      if (chatDoc.exists) {
        final data = chatDoc.data();
        return (data?['unreadCount']?[myId] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
  
  // ============================================================
  // ✅ USER STATUS METHODS
  // ============================================================
  
  Stream<DocumentSnapshot> getUserStatus(String userId) {
    try {
      return _firestore.collection('users').doc(userId).snapshots();
    } catch (e) {
      print('Error getting user status: $e');
      return Stream.empty();
    }
  }
  // ✅ Conversation document ka live stream — typing status ke liye
  Stream<DocumentSnapshot> getConversationStream(String chatRoomId) {
    try {
      return _firestore.collection('conversations').doc(chatRoomId).snapshots();
    } catch (e) {
      print('Error getting conversation stream: $e');
      return Stream.empty();
    }
  }
  
Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      final myId = currentUserId;
      if (myId == null) return;
      
      // ✅ Firebase ID token ko force refresh karo — warna stale token se write fail hoti hai
      await refreshFirebaseToken();
      
      await _firestore.collection('users').doc(myId).update({
        'online': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
      print('✅ Online status updated: $isOnline');
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
  Future<void> setTypingStatus(String chatRoomId, bool isTyping) async {
    try {
      final myId = currentUserId;
      if (myId == null) return;
      
      await _firestore.collection('conversations').doc(chatRoomId).update({
        'typing.$myId': isTyping,
        'typing.updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error setting typing status: $e');
    }
  }
  Future<String> uploadFile(File file) async {
    try {
      final token = await getValidAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final uploadService = Get.find<UploadService>();
      return await uploadService.uploadFile(file);
    } catch (e) {
      print('❌ Error uploading file via API: $e');
      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        final refreshed = await refreshBackendToken();
        if (refreshed) {
          final uploadService = Get.find<UploadService>();
          return await uploadService.uploadFile(file);
        }
      }
      rethrow;
    }
  }
  // ============================================================
  // ✅ FILE UPLOAD METHODS WITH TOKEN REFRESH
  // ============================================================
  
  Future<String> uploadImage(File imageFile) async {
    try {
      // ✅ Get valid token with auto-refresh
      final token = await getValidAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }
      
      final uploadService = Get.find<UploadService>();
      final imageUrl = await uploadService.uploadImage(imageFile);
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading image via API: $e');
      
      // Check if it's a token error
      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        final refreshed = await refreshBackendToken();
        if (refreshed) {
          // Retry upload
          final uploadService = Get.find<UploadService>();
          return await uploadService.uploadImage(imageFile);
        }
      }
      rethrow;
    }
  }
  
  Future<void> deleteMessageForEveryone(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }
  
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error soft deleting message: $e');
      rethrow;
    }
  }
  
  // ============================================================
  // ✅ CHAT ROOM MANAGEMENT
  // ============================================================
  
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      final messages = await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .get();
      
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_firestore.collection('conversations').doc(chatRoomId));
      await batch.commit();
    } catch (e) {
      print('Error deleting chat room: $e');
      rethrow;
    }
  }
  
  Future<void> archiveChatRoom(String chatRoomId) async {
    try {
      await _firestore.collection('conversations').doc(chatRoomId).update({
        'isActive': false,
        'archivedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error archiving chat room: $e');
      rethrow;
    }
  }


Stream<QuerySnapshot> getChatRooms() {
    try {
      final myFirebaseUid = firebaseUid;
      if (myFirebaseUid == null) {
        return Stream.empty();
      }
      
      return _firestore
          .collection('conversations')
          .where('participantFirebaseUids', arrayContains: myFirebaseUid)
          .snapshots();   // ✅ isActive filter bhi hata diya
    } catch (e) {
      print('Error getting chat rooms: $e');
      return Stream.empty();
    }
  }
Future<void> fixCorruptChatRooms() async {
  final convos = await _firestore.collection('conversations').get();
  for (var doc in convos.docs) {
    final data = doc.data();
    final participants = List<String>.from(data['participants'] ?? []);
    List<String> correctUids = [];
    for (var pid in participants) {
      final userDoc = await _firestore.collection('users').doc(pid).get();
      final uid = userDoc.data()?['firebaseUid'];
      if (uid != null && uid.toString().isNotEmpty) {
        correctUids.add(uid.toString());
      }
    }
    if (correctUids.length == participants.length) {
      await doc.reference.update({'participantFirebaseUids': correctUids});
      print('✅ Fixed: ${doc.id}');
    } else {
      print('⚠️ Could not fix ${doc.id} — missing firebaseUid for some user');
    }
  }
}
Future<Map<String, dynamic>?> getUserOnce(String userId) async {
  try {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  } catch (e) {
    print('Error fetching user once: $e');
    return null;
  }
}
  Future<int> getTotalUnreadCount() async {
    try {
      final myId = currentUserId;
      if (myId == null) return 0;
      
      final chats = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: myId)
          .get();
      
      int totalUnread = 0;
      for (var doc in chats.docs) {
        final data = doc.data();
        final unreadCount = (data['unreadCount']?[myId] ?? 0) as int;
        totalUnread += unreadCount;
      }
      
      return totalUnread;
    } catch (e) {
      print('Error getting total unread count: $e');
      return 0;
    }
  }
  
  // ============================================================
  // ✅ LIFECYCLE METHODS
  // ============================================================
  
  @override
  void onReady() async {
    super.onReady();
    print('✅ ChatService is ready');

    // ✅ Refresh both tokens on startup
    await refreshFirebaseToken();
    await refreshBackendToken();

    print('✅ Firebase UID: $firebaseUid');
    print('✅ Current User ID: $currentUserId');
    
    await saveUserProfileToFirestore();
     await updateOnlineStatus(true);
       _startHeartbeat(); 
      
  }
  

    @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(true);
              _startHeartbeat();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        updateOnlineStatus(false);
        break;
    }
  }

  // ✅ add — poora naya method
  @override
  void onClose() {
      _stopHeartbeat();
    WidgetsBinding.instance.removeObserver(this);
    updateOnlineStatus(false);
    super.onClose();
  }
}

