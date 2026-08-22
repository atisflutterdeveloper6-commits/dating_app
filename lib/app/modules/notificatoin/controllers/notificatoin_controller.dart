import 'dart:convert';
import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificatoinController extends GetxController {
  final _storageService = StorageService();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final likes = <LikeModel>[].obs;

  // Splitting into "new" (unread) and "earlier" (read) like your UI expects
  List<LikeModel> get newNotifications =>
      likes.where((e) => e.isUnread).toList();

  List<LikeModel> get earlierNotifications =>
      likes.where((e) => !e.isUnread).toList();

  String get myProfileId => _storageService.getProfileId() ?? '';
  String get authToken => _storageService.getAuthToken() ?? '';

  @override
  void onInit() {
    super.onInit();
    print('========================================');
    print('🔔 [NotificationController] onInit called');
    print('========================================');
    fetchLikes();
  }

  Future<void> fetchLikes() async {
    print('========================================');
    print('🔔 [NotificationController] fetchLikes() called');
    print('👤 myProfileId: $myProfileId');
    print('🔑 authToken: ${authToken.isNotEmpty ? "${authToken.substring(0, authToken.length > 20 ? 20 : authToken.length)}..." : "EMPTY"}');
    print('========================================');

    if (myProfileId.isEmpty || authToken.isEmpty) {
      errorMessage.value = 'Missing profile id or auth token';
      print('❌ [NotificationController] Missing profileId or authToken — aborting fetch');
      print('   myProfileId isEmpty: ${myProfileId.isEmpty}');
      print('   authToken isEmpty: ${authToken.isEmpty}');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uri = Uri.parse(
        '${ApiUrls.baseUrl}${ApiUrls.getMyLikes(myProfileId)}',
      );

      print('📤 [NotificationController] GET request to: $uri');

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print('📥 [NotificationController] Response status: ${response.statusCode}');
      print('📥 [NotificationController] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print('📦 [NotificationController] Decoded body: $body');

        if (body['success'] == true) {
          final List data = body['data'] ?? [];
          print('✅ [NotificationController] success=true, data length: ${data.length}');

          likes.value = data
              .map((e) => LikeModel.fromJson(e as Map<String, dynamic>))
              .toList();

          print('✅ [NotificationController] Parsed ${likes.length} LikeModel items');
          for (var i = 0; i < likes.length; i++) {
            final l = likes[i];
            print('   [$i] id=${l.id}, name=${l.name}, image=${l.image}, isUnread=${l.isUnread}, createdAt=${l.createdAt}');
          }
          print('🆕 [NotificationController] newNotifications count: ${newNotifications.length}');
          print('📜 [NotificationController] earlierNotifications count: ${earlierNotifications.length}');
        } else {
          errorMessage.value =
              body['message']?.toString() ?? 'Something went wrong';
          print('⚠️ [NotificationController] success=false — message: ${errorMessage.value}');
        }
      } else {
        errorMessage.value = 'Failed to load likes (${response.statusCode})';
        print('❌ [NotificationController] Non-200 status — ${errorMessage.value}');
      }
    } catch (e, stack) {
      errorMessage.value = 'Network error: $e';
      print('❌ [NotificationController] Exception during fetchLikes: $e');
      print('❌ [NotificationController] Stack trace: $stack');
    } finally {
      isLoading.value = false;
      print('🔔 [NotificationController] fetchLikes() finished — isLoading: ${isLoading.value}');
      print('========================================');
    }
  }

  Future<void> refresh() {
    print('🔄 [NotificationController] refresh() called');
    return fetchLikes();
  }
}

class LikeModel {
  final String id;
  final String name;
  final String? image;
  final String? message;
  final DateTime? createdAt;
  final bool isUnread;

  LikeModel({
    required this.id,
    required this.name,
    this.image,
    this.message,
    this.createdAt,
    this.isUnread = false,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    print('🧩 [LikeModel.fromJson] raw json: $json');

    // ✅ Actual backend shape (confirmed from real response):
    // { _id, photos: [{ image, _id }], firstName, lastName, createdAt, updatedAt }
    // There is NO 'name', 'message', or 'isUnread' field — handled below
    // with sensible fallbacks.

    String? extractedImage;
    final photos = json['photos'];
    if (photos is List && photos.isNotEmpty) {
      final firstPhoto = photos[0];
      if (firstPhoto is Map<String, dynamic>) {
        extractedImage = firstPhoto['image']?.toString();
      } else if (firstPhoto is String) {
        extractedImage = firstPhoto;
      }
    }

    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();
    final fullName = '$firstName $lastName'.trim();

    // ⚠️ Backend currently sends the literal string "Invalid Date" for
    // createdAt/updatedAt instead of a real ISO date string. Guard against
    // that explicitly so DateTime.tryParse doesn't waste a parse attempt —
    // result is null either way, so _timeAgo() shows '' until backend
    // fixes the date formatting on their side.
    final rawCreatedAt = json['createdAt']?.toString();
    final parsedCreatedAt =
        (rawCreatedAt != null && rawCreatedAt != 'Invalid Date')
            ? DateTime.tryParse(rawCreatedAt)
            : null;

    final model = LikeModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: fullName.isNotEmpty ? fullName : 'Unknown',
      image: extractedImage,
      message: json['message']?.toString(), // backend doesn't send this yet
      createdAt: parsedCreatedAt,
      // ⚠️ Backend doesn't send a read/unread flag yet. Defaulting to
      // true (unread) so likes show under "New" for now — once backend
      // adds a real flag (e.g. 'isRead' or 'seenAt'), map it here instead.
      isUnread: true,
    );

    print('🧩 [LikeModel.fromJson] parsed -> id=${model.id}, name=${model.name}, image=${model.image}, isUnread=${model.isUnread}');

    return model;
  }

  Map<String, dynamic> toJson() {
    final nameParts = name.split(' ');
    return {
      '_id': id,
      'firstName': nameParts.isNotEmpty ? nameParts.first : '',
      'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      'photos': image != null ? [{'image': image}] : [],
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
      'isUnread': isUnread,
    };
  }
}