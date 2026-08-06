import 'dart:math' as Math;

import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/location_controller.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/models/profile_all_model.dart';
import 'package:dating_app/app/modules/homepage/views/like_services.dart';
import 'package:dating_app/app/modules/like2/controllers/like2_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum SwipeDirection { like, dislike }

class HomepageController extends GetxController {
  final StorageService _storage = StorageService();
  LikeStateService? _likeStateService;
  
  RxInt selectedIndex = 0.obs;
  RxList<Map<String, dynamic>> profiles = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  
  // Filter state
  RxString selectedDistance = '40km'.obs;
  RxString selectedAgeRange = '22-30'.obs;
  RxBool hasPhoto = false.obs;
  RxString selectedGender = 'Man'.obs;
  RxString selectedLocation = 'Pune, Mh'.obs;
  RxBool onlineStatus = true.obs;
  RxString selectedHasMeet = 'Yes'.obs;
  RxString selectedPosition = 'All'.obs;
  RxString selectedHeight = 'All'.obs;
  RxString selectedBodyType = 'All'.obs;
  RxString selectedLanguage = 'All'.obs;

  // ✅ Flag to track if filters are applied
  RxBool isFilterApplied = false.obs;

  String? currentProfileId;
  String? authToken;

  final List<Map<String, dynamic>> filters = [
    {"title": "All", "icon": null},
    {"title": "Distance", "icon": Icons.location_on_outlined},
    {"title": "Age", "icon": Icons.person_outline},
    {"title": "Has photo", "icon": Icons.image_outlined},
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _initializeUserSession();
      fetchProfiles(); 
  }
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Earth's radius in kilometers
  
  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);
  
  double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
             Math.cos(_degreesToRadians(lat1)) * Math.cos(_degreesToRadians(lat2)) *
             Math.sin(dLon / 2) * Math.sin(dLon / 2);
  
  double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  double distance = R * c;
  
  return distance;
}

// Convert degrees to radians
double _degreesToRadians(double degrees) {
  return degrees * Math.pi / 180.0;
}

// Format distance for display
String _formatDistance(double distance) {
  if (distance < 1.0) {
    // Less than 1 km - show in meters
    int meters = (distance * 1000).round();
    return '$meters m';
  } else {
    // 1 km or more - show in km with 1 decimal place
    return '${distance.toStringAsFixed(1)} km';
  }
}

// Format distance for display with "away" suffix
String _formatDistanceWithAway(double distance) {
  if (distance < 1.0) {
    int meters = (distance * 1000).round();
    return '$meters m away';
  } else {
    return '${distance.toStringAsFixed(1)} km away';
  }
}

// Calculate distance and return formatted string
String _getFormattedDistance(double lat1, double lon1, double lat2, double lon2) {
  double distance = _calculateDistance(lat1, lon1, lat2, lon2);
  return _formatDistance(distance);
}

// Get distance and return both raw and formatted values
Map<String, dynamic> _getDistanceWithFormatted(double lat1, double lon1, double lat2, double lon2) {
  double distance = _calculateDistance(lat1, lon1, lat2, lon2);
  return {
    'distanceInKm': distance,
    'formattedDistance': _formatDistance(distance),
    'formattedWithAway': _formatDistanceWithAway(distance),
  };
}
  void _initializeServices() {
    try {
      if (Get.isRegistered<LikeStateService>()) {
        _likeStateService = Get.find<LikeStateService>();
        print('✅ LikeStateService found');
      } else {
        print('⚠️ LikeStateService not registered, creating new instance');
        Get.put(LikeStateService(), permanent: true);
        _likeStateService = Get.find<LikeStateService>();
        print('✅ LikeStateService created and registered');
      }
    } catch (e) {
      print('❌ Error initializing LikeStateService: $e');
      _likeStateService = LikeStateService();
      Get.put(_likeStateService!, permanent: true);
    }
  }

  void _initializeUserSession() {
    try {
      _storage.debugPrintAllData();
      
      final profileId = _storage.getProfileId();
      if (profileId != null && profileId.isNotEmpty) {
        currentProfileId = profileId;
        print('✅ Current profile ID loaded from storage: $currentProfileId');
      } else {
        final loginData = _storage.getLoginData();
        if (loginData != null) {
          final id = loginData['profileId'] ?? 
                     loginData['profile_id'] ?? 
                     loginData['id'] ?? 
                     loginData['userId'] ??
                     loginData['_id'];
          
          if (id != null && id.toString().isNotEmpty) {
            currentProfileId = id.toString();
            _storage.saveProfileId(currentProfileId!);
            print('✅ Profile ID extracted from login data: $currentProfileId');
          }
        }
      }
      
      authToken = _storage.getAuthToken();
      if (authToken == null || authToken!.isEmpty) {
        print('⚠️ No auth token found');
      } else {
        print('✅ Auth token loaded');
      }
      
      if (currentProfileId == null || currentProfileId!.isEmpty) {
        final profileData = _storage.getProfileData();
        if (profileData != null) {
          final id = profileData['_id'] ?? 
                     profileData['id'] ?? 
                     profileData['profileId'];
          if (id != null && id.toString().isNotEmpty) {
            currentProfileId = id.toString();
            _storage.saveProfileId(currentProfileId!);
            print('✅ Profile ID extracted from profile data: $currentProfileId');
          }
        }
      }
      
      if (currentProfileId == null || currentProfileId!.isEmpty) {
        print('⚠️ No profile ID found in any storage location');
      } else {
        print('✅ Final profile ID: $currentProfileId');
      }
      
      // ✅ Fetch profiles without filters (default)
      fetchProfiles();
      
    } catch (e) {
      print('❌ Error initializing session: $e');
      errorMessage.value = 'Failed to initialize session';
    }
  }

  void _reloadProfileId() {
    try {
      final profileId = _storage.getProfileId();
      if (profileId != null && profileId.isNotEmpty) {
        currentProfileId = profileId;
        print('✅ Profile ID reloaded: $currentProfileId');
      } else {
        final loginData = _storage.getLoginData();
        if (loginData != null) {
          final id = loginData['profileId'] ?? 
                     loginData['profile_id'] ?? 
                     loginData['id'] ?? 
                     loginData['userId'];
          if (id != null && id.toString().isNotEmpty) {
            currentProfileId = id.toString();
            _storage.saveProfileId(currentProfileId!);
            print('✅ Profile ID reloaded from login data: $currentProfileId');
          }
        }
      }
    } catch (e) {
      print('❌ Error reloading profile ID: $e');
    }
  }

  void selectChip(int index) {
    selectedIndex.value = index;
  }

  // ============== ✅ DEFAULT: Fetch all profiles without filters ==============
  
  Future<void> fetchProfiles() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isFilterApplied.value = false;
      
      // ✅ Use simple profiles endpoint without filters
      final String url = '${ApiUrls.baseUrl}${ApiUrls.profiles}';
      
      print('📤 Fetching all profiles from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          ...await _getAuthHeaders(),
        },
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> profilesData = data['data'];
          
          List<Map<String, dynamic>> convertedProfiles = [];
          for (var profile in profilesData) {
            try {
              final converted = convertToProfileModel(profile as Map<String, dynamic>);
              convertedProfiles.add(converted);
            } catch (e) {
              print('❌ Error converting profile: $e');
            }
          }
          
          // Filter out current user's profile
          List<Map<String, dynamic>> filteredProfiles = [];
          if (currentProfileId == null || currentProfileId!.isEmpty) {
            _reloadProfileId();
          }
          
          for (var profile in convertedProfiles) {
            final profileId = profile['_id'] ?? profile['id'];
            if (currentProfileId != null && 
                currentProfileId!.isNotEmpty && 
                profileId == currentProfileId) {
              continue;
            }
            filteredProfiles.add(profile);
          }
          
          profiles.value = filteredProfiles;
          print('✅ Loaded ${profiles.value.length} profiles (no filters)');
          
          if (profiles.value.isEmpty) {
            print('⚠️ No profiles found');
          }
        } else {
          errorMessage.value = data['message'] ?? 'Failed to load profiles';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error loading profiles: ${e.toString()}';
      print('❌ Error fetching profiles: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============== ✅ FETCH WITH FILTERS (Only when filter button is clicked) ==============
  
// In fetchProfilesWithFilters method, remove the distance filter from API
// and calculate distance client-side
// ✅ FETCH PROFILES WITH AGE FILTER ONLY (Client-Side)
Future<void> fetchProfilesWithAgeFilter() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    isFilterApplied.value = true;
    
    print('🔄 Applying Age Filter: ${selectedAgeRange.value}');
    
    // First fetch all profiles
    final String url = '${ApiUrls.baseUrl}${ApiUrls.profiles}';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        ...await _getAuthHeaders(),
      },
    );

    print('📥 Response Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> profilesData = data['data'];
        
        List<Map<String, dynamic>> convertedProfiles = [];
        for (var profile in profilesData) {
          try {
            final converted = convertToProfileModel(profile as Map<String, dynamic>);
            convertedProfiles.add(converted);
          } catch (e) {
            print('❌ Error converting profile: $e');
          }
        }
        
        // Parse age range
        Map<String, int> ageRange = _parseAgeRange(selectedAgeRange.value);
        int minAge = ageRange['min'] ?? 0;
        int maxAge = ageRange['max'] ?? 100;
        
        // Filter by age and remove current user
        List<Map<String, dynamic>> filteredProfiles = [];
        if (currentProfileId == null || currentProfileId!.isEmpty) {
          _reloadProfileId();
        }
        
        for (var profile in convertedProfiles) {
          final profileId = profile['_id'] ?? profile['id'];
          
          // Skip current user
          if (currentProfileId != null && 
              currentProfileId!.isNotEmpty && 
              profileId == currentProfileId) {
            continue;
          }
          
          // ✅ Filter by age range
          int age = profile['age'] ?? 0;
          if (age >= minAge && age <= maxAge) {
            filteredProfiles.add(profile);
          }
        }
        
        profiles.value = filteredProfiles;
        print('✅ Loaded ${profiles.value.length} profiles with Age Filter: ${selectedAgeRange.value}');
        
        if (profiles.value.isEmpty) {
          Get.snackbar(
            'No Profiles Found',
            'No profiles found in age range ${selectedAgeRange.value}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      } else {
        errorMessage.value = data['message'] ?? 'Failed to load profiles';
      }
    } else {
      errorMessage.value = 'Server error: ${response.statusCode}';
    }
  } catch (e) {
    errorMessage.value = 'Error: ${e.toString()}';
    print('❌ Error: $e');
  } finally {
    isLoading.value = false;
  }
}
// ✅ FETCH PROFILES WITH DISTANCE FILTER ONLY (Client-Side)
Future<void> fetchProfilesWithDistanceFilter() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    isFilterApplied.value = true;
    
    final locationController = Get.find<LocationController>();
    
    print('🔄 Applying Distance Filter: ${selectedDistance.value}');
    
    // First fetch all profiles
    final String url = '${ApiUrls.baseUrl}${ApiUrls.profiles}';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        ...await _getAuthHeaders(),
      },
    );

    print('📥 Response Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> profilesData = data['data'];
        
        List<Map<String, dynamic>> convertedProfiles = [];
        for (var profile in profilesData) {
          try {
            final converted = convertToProfileModel(profile as Map<String, dynamic>);
            convertedProfiles.add(converted);
          } catch (e) {
            print('❌ Error converting profile: $e');
          }
        }
        
        // Get max distance in km
        double maxDistance = double.parse(selectedDistance.value.replaceAll('km', '').trim());
        
        // Get user's current location
        double userLat = locationController.latitude.value;
        double userLng = locationController.longitude.value;
        
        if (userLat == 0.0 && userLng == 0.0) {
          // Use default location if not available
          userLat = 18.5204;
          userLng = 73.8567;
          print('⚠️ Using default location (Pune) for distance calculation');
        }
        
        // Filter by distance and remove current user
        List<Map<String, dynamic>> filteredProfiles = [];
        if (currentProfileId == null || currentProfileId!.isEmpty) {
          _reloadProfileId();
        }
        
        for (var profile in convertedProfiles) {
          final profileId = profile['_id'] ?? profile['id'];
          
          // Skip current user
          if (currentProfileId != null && 
              currentProfileId!.isNotEmpty && 
              profileId == currentProfileId) {
            continue;
          }
          
          // Extract coordinates from profile
          double profileLat = 0.0;
          double profileLng = 0.0;
          
          // Try to get coordinates from profile
          if (profile['rawData'] != null) {
            final rawData = profile['rawData'] as Map<String, dynamic>;
            if (rawData['location'] != null) {
              final location = rawData['location'];
              if (location is Map<String, dynamic>) {
                final coordinates = location['coordinates'] as List?;
                if (coordinates != null && coordinates.length == 2) {
                  profileLng = (coordinates[0] as num).toDouble();
                  profileLat = (coordinates[1] as num).toDouble();
                }
              }
            }
          }
          
          // If coordinates not found, check if we have lat/lng fields
          if (profileLat == 0.0 && profileLng == 0.0) {
            profileLat = (profile['latitude'] as num?)?.toDouble() ?? 0.0;
            profileLng = (profile['longitude'] as num?)?.toDouble() ?? 0.0;
          }
          
          // Calculate distance and filter
          if (profileLat != 0.0 && profileLng != 0.0) {
            double distance = _calculateDistance(
              userLat, userLng, 
              profileLat, profileLng
            );
            
            // Update profile with distance
            profile['distance'] = _formatDistance(distance);
            profile['distanceInKm'] = distance;
            
            if (distance <= maxDistance) {
              filteredProfiles.add(profile);
            }
          } else {
            // If no coordinates, include with default distance
            profile['distance'] = 'N/A';
            profile['distanceInKm'] = 999;
            filteredProfiles.add(profile);
          }
        }
        
        // Sort by distance
        filteredProfiles.sort((a, b) {
          double distA = (a['distanceInKm'] as num?)?.toDouble() ?? 999;
          double distB = (b['distanceInKm'] as num?)?.toDouble() ?? 999;
          return distA.compareTo(distB);
        });
        
        profiles.value = filteredProfiles;
        print('✅ Loaded ${profiles.value.length} profiles with Distance Filter: ${selectedDistance.value}');
        
        if (profiles.value.isEmpty) {
          Get.snackbar(
            'No Profiles Found',
            'No profiles found within ${selectedDistance.value}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      } else {
        errorMessage.value = data['message'] ?? 'Failed to load profiles';
      }
    } else {
      errorMessage.value = 'Server error: ${response.statusCode}';
    }
  } catch (e) {
    errorMessage.value = 'Error: ${e.toString()}';
    print('❌ Error: $e');
  } finally {
    isLoading.value = false;
  }
}
Future<void> fetchProfilesWithFilters() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    isFilterApplied.value = true;
    
    final locationController = Get.find<LocationController>();
    
    // Build URL WITHOUT distance filter
    String url = '${ApiUrls.baseUrl}/v1/api/profiles/filter?';
    
    // Add age parameters only
    if (selectedAgeRange.value != 'Any') {
      Map<String, int> ageRange = _parseAgeRange(selectedAgeRange.value);
      url += 'minAge=${ageRange['min']}&maxAge=${ageRange['max']}';
    }
    
    print('📤 Fetching profiles with filters from: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        ...await _getAuthHeaders(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['success'] == true) {
        final List<dynamic> profilesData = data['data'] ?? [];
        
        List<Map<String, dynamic>> convertedProfiles = [];
        for (var profile in profilesData) {
          try {
            final converted = convertToProfileModel(profile as Map<String, dynamic>);
            convertedProfiles.add(converted);
          } catch (e) {
            print('❌ Error converting profile: $e');
          }
        }
        
        // Filter out current user and filter by distance client-side
        List<Map<String, dynamic>> filteredProfiles = [];
        if (currentProfileId == null || currentProfileId!.isEmpty) {
          _reloadProfileId();
        }
        
        // Get max distance in km
        double maxDistance = double.parse(selectedDistance.value.replaceAll('km', '').trim());
        
        for (var profile in convertedProfiles) {
          final profileId = profile['_id'] ?? profile['id'];
          
          // Skip current user
          if (currentProfileId != null && 
              currentProfileId!.isNotEmpty && 
              profileId == currentProfileId) {
            continue;
          }
          
          // Calculate distance client-side
          double profileLat = profile['latitude'] ?? 0.0;
          double profileLng = profile['longitude'] ?? 0.0;
          
          if (profileLat != 0.0 && profileLng != 0.0) {
            double distance = locationController.getDistanceToProfile(profileLat, profileLng);
            
            // Filter by distance
            if (distance <= maxDistance) {
              filteredProfiles.add(profile);
            }
          } else {
            // If no coordinates, include but show default distance
            filteredProfiles.add(profile);
          }
        }
        
        profiles.value = filteredProfiles;
        print('✅ Loaded ${profiles.value.length} profiles after client-side filtering');
      }
    }
  } catch (e) {
    errorMessage.value = 'Error: ${e.toString()}';
    print('❌ Error: $e');
  } finally {
    isLoading.value = false;
  }
}
// Helper method to parse age range
Map<String, int> _parseAgeRange(String ageRange) {
  if (ageRange == 'Any') {
    return {'min': 18, 'max': 100};
  }
  
  if (ageRange == '40+') {
    return {'min': 40, 'max': 100};
  }
  
  if (ageRange.contains('-')) {
    final parts = ageRange.split('-');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]) ?? 18;
      final max = int.tryParse(parts[1]) ?? 100;
      return {'min': min, 'max': max};
    }
  }
  
  // Default fallback
  return {'min': 18, 'max': 100};
}
 
// ✅ Naya — hamesha fresh Firebase ID token deta hai
Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {};
      final token = await user.getIdToken(false);
      if (token != null && token.isNotEmpty) {
        return {'Authorization': 'Bearer $token'};
      }
      return {};
    } catch (e) {
      print('❌ Error getting Firebase token: $e');
      return {};
    }
  }

  // Get profile by ID
  Future<Map<String, dynamic>?> getProfileById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(id)}'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          ... await _getAuthHeaders(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
  // ✅ Fetch profiles with only distance filter
Future<void> fetchProfilesWithDistanceOnly() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    
    final locationController = Get.find<LocationController>();
    
    String url = '${ApiUrls.baseUrl}/v1/api/profiles/filter?';
    
    final lat = locationController.latitude.value;
    final lng = locationController.longitude.value;
    
    if (lat != 0.0 && lng != 0.0) {
      url += 'lat=$lat&lng=$lng&';
    } else {
      url += 'lat=18.5204&lng=73.8567&';
    }
    
    String distance = selectedDistance.value.replaceAll('km', '').trim();
    if (distance.isNotEmpty && int.tryParse(distance) != null) {
      url += 'distance=$distance';
    } else {
      url += 'distance=40';
    }
    
    // ✅ NO age filter applied
    
    print('📤 Fetching profiles with distance only from: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        ...await _getAuthHeaders(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['success'] == true) {
        final List<dynamic> profilesData = data['data'] ?? [];
        
        List<Map<String, dynamic>> convertedProfiles = [];
        for (var profile in profilesData) {
          try {
            final converted = convertToProfileModel(profile as Map<String, dynamic>);
            convertedProfiles.add(converted);
          } catch (e) {
            print('❌ Error converting profile: $e');
          }
        }
        
        // Filter out current user
        List<Map<String, dynamic>> filteredProfiles = [];
        if (currentProfileId == null || currentProfileId!.isEmpty) {
          _reloadProfileId();
        }
        
        for (var profile in convertedProfiles) {
          final profileId = profile['_id'] ?? profile['id'];
          if (currentProfileId != null && 
              currentProfileId!.isNotEmpty && 
              profileId == currentProfileId) {
            continue;
          }
          filteredProfiles.add(profile);
        }
        
        profiles.value = filteredProfiles;
        print('✅ Loaded ${profiles.value.length} profiles (distance only)');
      }
    }
  } catch (e) {
    errorMessage.value = 'Error: ${e.toString()}';
  } finally {
    isLoading.value = false;
  }
}

// ✅ Fetch profiles with only distance filter

// ✅ Fetch profiles with only age filter
Future<void> fetchProfilesWithAgeOnly() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    
    final locationController = Get.find<LocationController>();
    
    String url = '${ApiUrls.baseUrl}/v1/api/profiles/filter?';
    
    final lat = locationController.latitude.value;
    final lng = locationController.longitude.value;
    
    if (lat != 0.0 && lng != 0.0) {
      url += 'lat=$lat&lng=$lng&';
    } else {
      url += 'lat=18.5204&lng=73.8567&';
    }
    
    // ✅ Use default distance if not set
    String distance = selectedDistance.value.replaceAll('km', '').trim();
    if (distance.isNotEmpty && int.tryParse(distance) != null) {
      url += 'distance=$distance';
    } else {
      url += 'distance=40';
    }
    
    print('📤 Fetching profiles with age only from: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        ...await _getAuthHeaders(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['success'] == true) {
        final List<dynamic> profilesData = data['data'] ?? [];
        
        List<Map<String, dynamic>> convertedProfiles = [];
        for (var profile in profilesData) {
          try {
            final converted = convertToProfileModel(profile as Map<String, dynamic>);
            convertedProfiles.add(converted);
          } catch (e) {
            print('❌ Error converting profile: $e');
          }
        }
        
        // ✅ Apply client-side age filtering
        int minAge = 0;
        int maxAge = 100;
        
        if (selectedAgeRange.value != 'Any') {
          if (selectedAgeRange.value == '40+') {
            minAge = 40;
            maxAge = 100;
          } else if (selectedAgeRange.value.contains('-')) {
            final parts = selectedAgeRange.value.split('-');
            if (parts.length == 2) {
              minAge = int.tryParse(parts[0]) ?? 0;
              maxAge = int.tryParse(parts[1]) ?? 100;
            }
          }
        }
        
        // Filter by age and remove current user
        List<Map<String, dynamic>> filteredProfiles = [];
        if (currentProfileId == null || currentProfileId!.isEmpty) {
          _reloadProfileId();
        }
        
        for (var profile in convertedProfiles) {
          final profileId = profile['_id'] ?? profile['id'];
          
          // Skip current user
          if (currentProfileId != null && 
              currentProfileId!.isNotEmpty && 
              profileId == currentProfileId) {
            continue;
          }
          
          // ✅ Filter by age range
          int age = profile['age'] ?? 0;
          if (age >= minAge && age <= maxAge) {
            filteredProfiles.add(profile);
          }
        }
        
        profiles.value = filteredProfiles;
        print('✅ Loaded ${profiles.value.length} profiles (age only: ${selectedAgeRange.value})');
      }
    }
  } catch (e) {
    errorMessage.value = 'Error: ${e.toString()}';
  } finally {
    isLoading.value = false;
  }
}

// ✅ Fetch profiles with only age filter
  final RxMap<String, int> likeCountOverrides = <String, int>{}.obs;
// ✅ Like count ke targeted updates ke liye — poori list reload kiye bina


  // ✅ Server se fresh count fetch karke override set karo (unlike ke baad ye call hoga)
Future<void> syncLikeCountFromServer(String profileId) async {
    try {
      final freshProfile = await getProfileById(profileId);
      if (freshProfile == null) return;

      final likesValue = freshProfile['likes'];
      int? likes;
      if (likesValue is int) likes = likesValue;
      else if (likesValue is num) likes = likesValue.toInt();
      else if (likesValue is String) likes = int.tryParse(likesValue);

      if (likes != null) {
        // ✅ Master `profiles` list ko bhi turant patch karo — isse
        // Homepage me already active `ever(controller.profiles, ...)` listener
        // turant fire hoga aur UI live update ho jayegi, refresh ki zaroorat nahi
        final index = profiles.indexWhere(
          (p) => (p['_id'] ?? p['id'])?.toString() == profileId,
        );
        if (index != -1) {
          final updated = Map<String, dynamic>.from(profiles[index]);
          updated['likes'] = likes;
          profiles[index] = updated;
        }

        likeCountOverrides[profileId] = likes;
        print('✅ Synced accurate like count for $profileId: $likes');
      }
    } catch (e) {
      print('❌ Error syncing like count: $e');
    }
  }
Future<bool> likeProfile(String profileId) async {
  try {
    if (currentProfileId == null || currentProfileId!.isEmpty) {
      _reloadProfileId();
      if (currentProfileId == null || currentProfileId!.isEmpty) {
        CustomToast.error('Please login again');
        return false;
      }
    }

    final url = '${ApiUrls.baseUrl}${ApiUrls.likeProfile(currentProfileId!, profileId)}';
    print('📤 LIKE URL: $url');

    Future<http.Response> send(String? token) => http.patch(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    var headers = await _getAuthHeaders();
    final tokenUsed = headers['Authorization']?.replaceFirst('Bearer ', '');
    print('📤 LIKE token present: ${tokenUsed != null}');

    var response = await send(tokenUsed);
    print('📥 LIKE Status (1st try): ${response.statusCode}');
    print('📥 LIKE Body (1st try): ${response.body}');

    if (response.statusCode == 401) {
      final user = FirebaseAuth.instance.currentUser;
      final freshToken = await user?.getIdToken(true);
      response = await send(freshToken);
      print('📥 LIKE Status (retry): ${response.statusCode}');
      print('📥 LIKE Body (retry): ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ Agar body empty ho ya 'success' key na ho, tab bhi 2xx ko success maano
      if (response.body.isEmpty) return true;
      try {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('success')) {
          return data['success'] == true;
        }
        return true; // 2xx aur 'success' key nahi hai to assume success
      } catch (_) {
        return true; // JSON parse fail but status 2xx tha
      }
    }
    return false;
  } catch (e, st) {
    print('❌ Error liking profile: $e');
    print('❌ Stacktrace: $st');
    return false;
  }
}
  Future<bool> unlikeProfile(String profileId) async {
    try {
      if (currentProfileId == null || currentProfileId!.isEmpty) {
        _reloadProfileId();
        if (currentProfileId == null || currentProfileId!.isEmpty) {
          CustomToast.error('Please login again');
          return false;
        }
      }

      final url = '${ApiUrls.baseUrl}${ApiUrls.unlikeProfile(currentProfileId!, profileId)}';
      print('📤 Unliking profile URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        print('✅ Profile unliked successfully: $profileId');
        _updateSharedLikeState(profileId, isLiked: false);
        _notifyLike2ControllerRefresh();
        CustomToast.success('Profile unliked');
        return true;
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        print('❌ Error: ${data['message']}');
        CustomToast.error(data['message'] ?? 'Failed to unlike profile');
        return false;
      }
    } catch (e) {
      print('❌ Error unliking profile: $e');
      CustomToast.error('Failed to unlike profile');
      return false;
    }
  }

  // ✅ Block user
  Future<bool> blockUser(String profileId) async {
    try {
      if (currentProfileId == null || currentProfileId!.isEmpty) {
        _reloadProfileId();
        if (currentProfileId == null || currentProfileId!.isEmpty) {
          CustomToast.error('Please login again');
          return false;
        }
      }

      final url = '${ApiUrls.baseUrl}${ApiUrls.blockUser(currentProfileId!, profileId)}';
      print('📤 Blocking user URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final success = data['success'] == true;
        
        if (success) {
          CustomToast.success('User blocked');
        }
        
        return success;
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        CustomToast.error(data['message'] ?? 'Failed to block user');
        return false;
      }
    } catch (e) {
      print('❌ Error blocking user: $e');
      CustomToast.error('Failed to block user');
      return false;
    }
  }

  // ✅ Unblock user
  Future<bool> unblockUser(String profileId) async {
    try {
      if (currentProfileId == null || currentProfileId!.isEmpty) {
        _reloadProfileId();
        if (currentProfileId == null || currentProfileId!.isEmpty) {
          CustomToast.error('Please login again');
          return false;
        }
      }

      final url = '${ApiUrls.baseUrl}${ApiUrls.unblockUser(currentProfileId!, profileId)}';
      print('📤 Unblocking user URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        CustomToast.success('User unblocked');
        return true;
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        CustomToast.error(data['message'] ?? 'Failed to unblock user');
        return false;
      }
    } catch (e) {
      print('❌ Error unblocking user: $e');
      CustomToast.error('Failed to unblock user');
      return false;
    }
  }

  void _updateSharedLikeState(String profileId, {required bool isLiked}) {
    try {
      if (_likeStateService == null) {
        print('⚠️ LikeStateService not available');
        return;
      }
      
      if (isLiked) {
        final profileData = profiles.firstWhereOrNull(
          (p) => p['_id'] == profileId || p['id'] == profileId
        );
        
        if (profileData != null) {
          final profileModel = ProfileModel.fromJson(profileData);
          _likeStateService!.addLikedProfile(profileModel);
          print('✅ Added to shared like state: $profileId');
        } else {
          _likeStateService!.addLikedProfileId(profileId);
          print('✅ Added profile ID to shared like state: $profileId');
        }
      } else {
        _likeStateService!.removeLikedProfile(profileId);
        print('✅ Removed from shared like state: $profileId');
      }
    } catch (e) {
      print('❌ Error updating shared like state: $e');
    }
  }

  void _notifyLike2ControllerRefresh() {
    try {
      if (Get.isRegistered<Like2Controller>()) {
        final like2Controller = Get.find<Like2Controller>();
        Future.delayed(Duration(milliseconds: 300), () {
          like2Controller.refreshLikedProfiles();
          print('✅ Notified Like2Controller to refresh');
        });
      } else {
        print('⚠️ Like2Controller not registered, skipping refresh');
      }
    } catch (e) {
      print('❌ Error notifying Like2Controller: $e');
    }
  }

  // ✅ Refresh profiles (default - no filters)
  Future<void> refreshProfiles() async {
    await fetchProfiles();
  }

  // ✅ Apply filters - CALLED ONLY FROM FILTER BUTTON
// ✅ Apply filters - Updated to use appropriate method
void applyFilters() {
  print('🔄 Applying filters');
  
  // Check which filters are active
  bool hasAgeFilter = selectedAgeRange.value != '22-30'; // Default value
  bool hasDistanceFilter = selectedDistance.value != '40km'; // Default value
  
  if (hasAgeFilter && hasDistanceFilter) {
    // Both filters active
    fetchProfilesWithFilters();
  } else if (hasAgeFilter) {
    // Only age filter
    fetchProfilesWithAgeFilter();
  } else if (hasDistanceFilter) {
    // Only distance filter
    fetchProfilesWithDistanceFilter();
  } else {
    // No filters - fetch all
    fetchProfiles();
  }
}
  // ✅ Reset to default (no filters)
  void resetFilters() {
    selectedDistance.value = '40km';
    selectedAgeRange.value = '22-30';
    isFilterApplied.value = false;
    fetchProfiles();
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      if (currentProfileId == null || currentProfileId!.isEmpty) {
        return null;
      }
      
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(currentProfileId!)}'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          ...await _getAuthHeaders(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }

  void setCurrentProfileId(String id) {
    currentProfileId = id;
    _storage.saveProfileId(id);
    print('✅ Current profile ID set: $id');
  }

  // Convert API profile to Profile model
  Map<String, dynamic> convertToProfileModel(Map<String, dynamic> apiProfile) {
    String firstName = apiProfile['firstName'] ?? '';
    String lastName = apiProfile['lastName'] ?? '';
    String fullName = '$firstName $lastName'.trim();
    if (fullName.isEmpty) fullName = apiProfile['nickName'] ?? 'User';
    
    List<String> allPhotos = [];
    String mainImage = '';
    
    if (apiProfile['photos'] != null && apiProfile['photos'] is List) {
      final photosList = apiProfile['photos'] as List;
      
      for (var photo in photosList) {
        if (photo is Map<String, dynamic>) {
          String? imageUrl = photo['image']?.toString();
          if (imageUrl != null && imageUrl.isNotEmpty) {
            allPhotos.add(imageUrl);
          }
        } else if (photo is String) {
          if (photo.isNotEmpty) {
            allPhotos.add(photo);
          }
        }
      }
      
      if (allPhotos.isNotEmpty) {
        mainImage = allPhotos[0];
      }
    }
    
    if (allPhotos.isEmpty) {
      allPhotos = ['assets/images/hprofile.png'];
      mainImage = 'assets/images/hprofile.png';
    }
    
    int age = 0;
    if (apiProfile['birthday'] != null) {
      try {
        final birthday = DateTime.parse(apiProfile['birthday']);
        final now = DateTime.now();
        age = now.year - birthday.year;
        if (now.month < birthday.month || 
            (now.month == birthday.month && now.day < birthday.day)) {
          age--;
        }
      } catch (e) {
        print('Error calculating age: $e');
      }
    }
    
    String locationString = 'Unknown location';
    if (apiProfile['location'] != null) {
      if (apiProfile['location'] is Map<String, dynamic>) {
        final locationMap = apiProfile['location'] as Map<String, dynamic>;
        final coordinates = locationMap['coordinates'] as List?;
        if (coordinates != null && coordinates.length == 2) {
          final lng = coordinates[0];
          final lat = coordinates[1];
          locationString = '$lat, $lng';
        }
      } else if (apiProfile['location'] is String) {
        locationString = apiProfile['location'] as String;
      }
    }
    
    int likes = 0;
    if (apiProfile.containsKey('likes')) {
      final likesValue = apiProfile['likes'];
      if (likesValue is int) {
        likes = likesValue;
      } else if (likesValue is String) {
        likes = int.tryParse(likesValue) ?? 0;
      } else if (likesValue is num) {
        likes = likesValue.toInt();
      } else if (likesValue != null) {
        try {
          likes = int.parse(likesValue.toString());
        } catch (e) {
          print('⚠️ Could not parse likes value: $likesValue');
          likes = 0;
        }
      }
    }
    
    if (likes == 0 && apiProfile['likedBy'] != null && apiProfile['likedBy'] is List) {
      final likedBy = apiProfile['likedBy'] as List;
      if (likedBy.isNotEmpty) {
        likes = likedBy.length;
        print('📊 Calculated likes from likedBy: $likes');
      }
    }
    
    print('❤️ Profile ${apiProfile['firstName'] ?? 'Unknown'} has $likes likes');
    
    bool placeToMeet = apiProfile['placeToMeet'] ?? false;
    bool isVerified = apiProfile['isVerified'] ?? false;
    
    return {
      'id': apiProfile['_id'] ?? '',
      'name': fullName,
      'age': age,
      'distance': '0 km',
      'location': locationString,
      'image': mainImage,
      'photos': allPhotos,
      'bio': apiProfile['bio'] ?? 'Hello, I\'m using this app',
      'hobbies': _extractHobbies(apiProfile),
      'hasPhoto': allPhotos.isNotEmpty && allPhotos[0] != 'assets/images/hprofile.png',
      'likes': likes,
      'placeToMeet': placeToMeet,
      'isVerified': isVerified,
      '_id': apiProfile['_id'] ?? '',
      'firstName': apiProfile['firstName'] ?? '',
      'lastName': apiProfile['lastName'] ?? '',
      'nickName': apiProfile['nickName'] ?? '',
      'birthday': apiProfile['birthday'] ?? '',
      'interest': apiProfile['interest'] ?? '',
      'height': apiProfile['height'] ?? '',
      'weight': apiProfile['weight'] ?? '',
      'phone': apiProfile['phone']?.toString() ?? '',
      'rawData': apiProfile,
    };
  }

  List<String> _extractHobbies(Map<String, dynamic> profile) {
    List<String> hobbies = [];
    
    if (profile['looking'] != null) {
      if (profile['looking'] is Map<String, dynamic>) {
        final title = profile['looking']['title']?.toString();
        if (title != null && title.isNotEmpty) {
          hobbies.add(title);
        }
      } else if (profile['looking'] is String) {
        final title = profile['looking'] as String;
        if (title.isNotEmpty) {
          hobbies.add(title);
        }
      }
    }
    
    if (profile['interest'] != null && profile['interest'].toString().isNotEmpty) {
      final interest = profile['interest'].toString();
      hobbies.add(interest);
    }
    
    if (profile['position'] != null) {
      if (profile['position'] is Map<String, dynamic>) {
        final title = profile['position']['title']?.toString();
        if (title != null && title.isNotEmpty) {
          hobbies.add(title);
        }
      } else if (profile['position'] is String) {
        final title = profile['position'] as String;
        if (title.isNotEmpty) {
          hobbies.add(title);
        }
      }
    }
    
    if (hobbies.isEmpty) {
      hobbies = ['Social', 'Chat'];
    }
    
    return hobbies.take(3).toList();
  }
}