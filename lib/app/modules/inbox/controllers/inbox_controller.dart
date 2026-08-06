// lib/app/modules/inbox/controllers/inbox_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/app/modules/chat/views/chat_service.dart';
import 'package:get/get.dart';

class InboxController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();

  // ✅ Poori chat list (jin users se already chat ho chuki hai)
  final RxList<Map<String, dynamic>> allChats = <Map<String, dynamic>>[].obs;

  // ✅ Search ke baad filtered list — UI isi ko use karti hai
  final RxList<Map<String, dynamic>> filteredChats = <Map<String, dynamic>>[].obs;

  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot>? _chatRoomsSub;

  // ✅ Har other-user ki online status ke liye alag subscriptions
  final Map<String, StreamSubscription<DocumentSnapshot>> _statusSubs = {};

  String _searchQuery = '';

  @override
  void onInit() {
    super.onInit();
    _listenToChatRooms();
  }

  // ✅ Firestore se real-time chat rooms suno — jin users se chat ho chuki hai unki hi list aayegi
void _listenToChatRooms() {
    final myId = _chatService.currentUserId;
    
    _chatRoomsSub = _chatService.getChatRooms().listen(
      (snapshot) async {
        try {
          final List<Map<String, dynamic>> chats = [];

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;

            final participants = List<String>.from(data['participants'] ?? []);
            if (participants.isEmpty) continue;

            final otherUserId = participants.firstWhere(
              (id) => id != myId,
              orElse: () => participants.first,
            );

            // ✅ Seedha users collection se ek baar fetch karo (fallback ke bajaye)
            String otherName = 'User';
            String otherImage = '';
            try {
              final userData = await _chatService.getUserOnce(otherUserId);
                print('🖼️ userData for $otherUserId: $userData');
              if (userData != null) {
                otherName = (userData['name'] ?? 'User').toString();
                otherImage = (userData['photoURL'] ?? '').toString();
                 print('🖼️ Extracted image: "$otherImage"'); 
              }
            } catch (e) {
              print('⚠️ Could not fetch user $otherUserId: $e');
            }

            final unreadCountMap = data['unreadCount'] as Map<String, dynamic>? ?? {};
            final unreadCount = (unreadCountMap[myId] ?? 0) as int;
            final lastMessageTime = data['lastMessageTime'] as Timestamp?;

            chats.add({
              'roomId': doc.id,
              'userId': otherUserId,
              'name': otherName,
              'image': otherImage,
              'lastMessage': (data['lastMessage'] ?? '').toString(),
              'lastMessageType': (data['lastMessageType'] ?? 'text').toString(),
              'time': _formatTime(lastMessageTime),
              'unreadCount': unreadCount,
              'online': false,
              '_rawTimestamp': lastMessageTime,
            });

            _listenUserOnlineStatus(otherUserId);
          }

          chats.sort((a, b) {
            final aTime = a['_rawTimestamp'] as Timestamp?;
            final bTime = b['_rawTimestamp'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          allChats.assignAll(chats);
          _applyFilter();
          isLoading.value = false;
        } catch (e) {
          print('❌ Error processing chat rooms: $e');
          isLoading.value = false;
        }
      },
      onError: (error) {
        print('❌ Error listening to chat rooms: $error');
        isLoading.value = false;
      },
    );
  }
void _listenUserOnlineStatus(String userId) {
    if (_statusSubs.containsKey(userId)) return;

    _statusSubs[userId] = _chatService.getUserStatus(userId).listen(
      (snapshot) {
        try {
          if (!snapshot.exists) {
            print('⚠️ users/$userId document does NOT exist'); // ✅ ADD
            return;
          }
          final data = snapshot.data() as Map<String, dynamic>?;
          print('👤 users/$userId data: $data'); // ✅ ADD — poora data print karo

          final isOnline = data?['online'] ?? false;
          final name = data?['name'] ?? 'User';
          final photoURL = data?['photoURL'] ?? '';
          
          print('👤 Extracted name: "$name", photoURL: "$photoURL"'); // ✅ ADD

          final index = allChats.indexWhere((c) => c['userId'] == userId);
          if (index != -1) {
            allChats[index] = {
              ...allChats[index],
              'online': isOnline,
              'name': name,
              'image': photoURL,
            };
            allChats.refresh();
            _applyFilter();
          }
        } catch (e) {
          print('❌ Error updating online status for $userId: $e');
        }
      },
      onError: (error) {
        print('❌ Error in status stream for $userId: $error');
      },
    );
  }
 
  void filterChats(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      filteredChats.assignAll(allChats);
    } else {
      filteredChats.assignAll(
        allChats.where((chat) {
          final name = (chat['name'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery);
        }),
      );
    }
  }

  // ✅ Timestamp ko readable time me convert karo
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) {
        if (diff.inDays == 1) return 'Yesterday';
        if (diff.inDays < 7) return '${diff.inDays}d ago';
        return '${date.day}/${date.month}/${date.year}';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  void onClose() {
    _chatRoomsSub?.cancel();
    for (var sub in _statusSubs.values) {
      sub.cancel();
    }
    _statusSubs.clear();
    super.onClose();
  }
}