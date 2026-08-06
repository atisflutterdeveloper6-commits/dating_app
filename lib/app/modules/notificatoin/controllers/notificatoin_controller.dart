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
    fetchLikes();
  }

  Future<void> fetchLikes() async {
    if (myProfileId.isEmpty || authToken.isEmpty) {
      errorMessage.value = 'Missing profile id or auth token';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uri = Uri.parse(
        '${ApiUrls.baseUrl}${ApiUrls.getMyLikes(myProfileId)}',
      );

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final List data = body['data'] ?? [];
          likes.value = data
              .map((e) => LikeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          errorMessage.value = body['message']?.toString() ??
              'Something went wrong';
        }
      } else {
        errorMessage.value = 'Failed to load likes (${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => fetchLikes();
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
    // NOTE: sample response had "data": [], so field names below are
    // best-guess based on your profiles schema. Send a non-empty
    // response and I'll correct these mappings.
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : null;

    String? extractedImage;
    final photos = json['photos'] ?? profile?['photos'];
    if (photos is List && photos.isNotEmpty) {
      extractedImage = photos[0]?.toString();
    }

    return LikeModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? profile?['name'] ?? 'Unknown').toString(),
      image: extractedImage,
      message: json['message']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      isUnread: json['isUnread'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'photos': image != null ? [image] : [],
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
      'isUnread': isUnread,
    };
  }
}