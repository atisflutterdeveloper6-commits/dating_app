import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AdvertisementResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<AdvertisementData> data;

  AdvertisementResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory AdvertisementResponse.fromJson(Map<String, dynamic> json) {
    return AdvertisementResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<AdvertisementData>.from(json['data'].map((x) => AdvertisementData.fromJson(x)))
          : [],
    );
  }
}

class AdvertisementData {
  final String id;
  final String title;
  final String backgroundVideo;
  final List<FeatureData> features;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  AdvertisementData({
    required this.id,
    required this.title,
    required this.backgroundVideo,
    required this.features,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdvertisementData.fromJson(Map<String, dynamic> json) {
    return AdvertisementData(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      backgroundVideo: json['backgroundVideo'] ?? '',
      features: json['features'] != null
          ? List<FeatureData>.from(json['features'].map((x) => FeatureData.fromJson(x)))
          : [],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class FeatureData {
  final String icon;
  final String title;
  final String description;

  FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });

  factory FeatureData.fromJson(Map<String, dynamic> json) {
    return FeatureData(
      icon: json['icon'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class PrimiumplanController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var advertisement = Rxn<AdvertisementData>();

  // media_kit player
  Player? player;
  VideoController? videoController;
  var isVideoInitialized = false.obs;

  // Default features (fallback)
  final List<Map<String, dynamic>> defaultFeatures = [
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'Unlimited Messages',
      'subtitle': 'Chat without any restrictions',
    },
    {
      'icon': Icons.favorite_border,
      'title': 'Unlimited Likes',
      'subtitle': 'Like as many profiles as you want',
    },
    {
      'icon': Icons.remove_red_eye_outlined,
      'title': 'See Who Liked You',
      'subtitle': 'Know who\'s interested in you',
    },
    {
      'icon': Icons.local_fire_department_outlined,
      'title': 'Advanced Filters',
      'subtitle': 'Find matches that fit your vibe',
    },
    {
      'icon': Icons.workspace_premium_outlined,
      'title': 'Premium Badge',
      'subtitle': 'Stand out with a golden badge!',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAdvertisement();
  }

  @override
  void onClose() {
    player?.dispose();
    super.onClose();
  }

  // 🔥 API Function in Controller
  Future<void> fetchAdvertisement() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.advertisement}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final responseData = AdvertisementResponse.fromJson(jsonData);

        if (responseData.success && responseData.data.isNotEmpty) {
          advertisement.value = responseData.data.first;
          await initializeVideo(responseData.data.first.backgroundVideo);
        } else {
          errorMessage.value = 'No advertisement data available';
          useDefaultData();
        }
      } else {
        errorMessage.value = 'Failed to load data (${response.statusCode})';
        useDefaultData();
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error fetching advertisement: $e');
      useDefaultData();
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 Initialize video using media_kit (audio hamesha muted)
  Future<void> initializeVideo(String videoUrl) async {
    try {
      await player?.dispose();

      player = Player();
      videoController = VideoController(player!);

      await player!.setVolume(0.0); // mute pehle hi set karo

      await player!.open(Media(videoUrl));
      await player!.setPlaylistMode(PlaylistMode.loop);

      await player!.setVolume(0.0); // double safety

      isVideoInitialized.value = true;
    } catch (e) {
      print('Error initializing video: $e');
      isVideoInitialized.value = false;

      // Local asset fallback
      try {
        await player?.dispose();
        player = Player();
        videoController = VideoController(player!);

        await player!.setVolume(0.0);
        await player!.open(Media('asset:///assets/videos/bg_video.mp4'));
        await player!.setPlaylistMode(PlaylistMode.loop);
        await player!.setVolume(0.0);

        isVideoInitialized.value = true;
      } catch (localError) {
        print('Local video also failed: $localError');
        isVideoInitialized.value = false;
      }
    }
  }

  // Use default data if API fails
  void useDefaultData() {
    advertisement.value = AdvertisementData(
      id: 'default',
      title: 'Upgrade Your\nDating Experience',
      backgroundVideo: '',
      features: [],
      isDeleted: false,
      createdAt: '',
      updatedAt: '',
    );
  }

  // 🎯 Get features (from API or default)
  List<Map<String, dynamic>> getFeatures() {
    if (advertisement.value != null && advertisement.value!.features.isNotEmpty) {
      return advertisement.value!.features.map((feature) {
        return {
          'icon': _getIconDataFromString(feature.icon),
          'title': feature.title,
          'subtitle': feature.description,
        };
      }).toList();
    }
    return defaultFeatures;
  }

  // 🔥 Convert icon string to IconData
  IconData _getIconDataFromString(String iconName) {
    const iconMap = {
      'chat_bubble_outline': Icons.chat_bubble_outline,
      'favorite_border': Icons.favorite_border,
      'remove_red_eye_outlined': Icons.remove_red_eye_outlined,
      'local_fire_department_outlined': Icons.local_fire_department_outlined,
      'workspace_premium_outlined': Icons.workspace_premium_outlined,
      'verified': Icons.verified,
      'star_border': Icons.star_border,
      'people_outline': Icons.people_outline,
      'psychology': Icons.psychology,
      'emoji_events': Icons.emoji_events,
      'rocket_launch': Icons.rocket_launch,
      'security': Icons.security,
      'bolt': Icons.bolt,
      'flash_on': Icons.flash_on,
    };

    return iconMap[iconName] ?? Icons.star_border;
  }

  // Get title
  String getTitle() {
    if (advertisement.value != null) {
      return advertisement.value!.title;
    }
    return 'Upgrade Your\nDating Experience';
  }

  // Check if video is available
  bool isVideoAvailable() {
    return isVideoInitialized.value && videoController != null;
  }

  // Retry loading
  void retryLoading() {
    fetchAdvertisement();
  }
}