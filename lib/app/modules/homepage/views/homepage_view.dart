import 'dart:math' as Math;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/location_controller.dart';
import 'package:dating_app/app/modules/chat/views/chat_service.dart';
import 'package:dating_app/app/modules/chat/views/chat_view.dart';
import 'package:dating_app/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:dating_app/app/modules/homepage/views/like_services.dart';
import 'package:dating_app/app/modules/notificatoin/views/notificatoin_view.dart';
import 'package:dating_app/app/modules/profiledetail/views/profiledetail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomepageView extends StatefulWidget {
  const HomepageView({super.key});

  @override
  State<HomepageView> createState() => _HomepageViewState();
}

// 🔥🔥🔥 UPDATED PROFILE CLASS WITH COORDINATES
// 🔥🔥🔥 UPDATED PROFILE CLASS WITH PHOTOS
class Profile {
  final String id;
  final String name;
  final int age;
  final String distance;
  final double distanceInKm;
  final String location;
  final String image;
  final List<String> photos;
  final String bio;
  final List<String> hobbies;
  final bool hasPhoto;
  int likes; // ✅ Make this mutable
  bool placeToMeet;
  final bool isVerified;
  final double latitude;
  final double longitude;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.distance,
    required this.distanceInKm,
    required this.location,
    required this.image,
    required this.photos,
    required this.bio,
    required this.hobbies,
    this.hasPhoto = true,
    this.likes = 0,// ✅ This will be overridden by the API data
    this.placeToMeet = true,
    this.isVerified = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
}

class _HomepageViewState extends State<HomepageView> with TickerProviderStateMixin {
  final HomepageController controller = Get.isRegistered<HomepageController>()
      ? Get.find<HomepageController>()
      : Get.put(HomepageController(), permanent: true);
  final LocationController locationController = Get.find<LocationController>();

  int _selectedFilterIndex = 0;

  bool _isLoadingLocation = false;
  bool _profilesLoaded = false;
  bool _isFetchingMore = false;

  // ✅ NAYA — per-profile photo index for left/right arrow navigation
  final Map<String, int> _photoIndexMap = {};

  // ✅ NAYA — flying heart animation (like button ke upar float + fade)
  late AnimationController _flyingHeartController;
  late Animation<double> _flyingHeartOffset;
  late Animation<double> _flyingHeartOpacity;
  bool _showFlyingHeart = false;
  // ✅ NAYA — flying X (dislike) animation, flying heart jaisa hi
  late AnimationController _flyingIgnoreController;
  late Animation<double> _flyingIgnoreOffset;
  late Animation<double> _flyingIgnoreOpacity;
  bool _showFlyingIgnore = false;
// ✅ NAYA — neeche pull karne pe refresh karo, koi swipe-conflict nahi kyunki
// downward drag pehle kisi card action se juda nahi tha
  void _triggerPullRefresh() {
    _resetPosition(); // card turant apni jagah wapas aa jaaye
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });


    controller.refreshProfiles().whenComplete(() {
      if (mounted) {
        setState(() {
          _isFetchingMore = false;
        });
      }
    });
  }
  // Filter state variables
  String _selectedDistance = "40km";
  String _selectedAgeRange = "22-30";
  bool _hasPhoto = false;
  String _selectedGender = "Man";
  String _selectedLocation = "Pune, Mh";
  bool _onlineStatus = true;
  String _selectedHeight = "All";
  String _selectedBodyType = "All";
  String _selectedLanguage = "All";
  String _selectedPosition = "All";
  String _selectedHasMeet = "Yes";

  // Animation controllers
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  bool _isAnimatingLike = false;

  late AnimationController _swipeAnimationController;
  late Animation<double> _swipeProgressAnimation;
  bool _isSwiping = false;
  SwipeDirection _swipeDirection = SwipeDirection.like;

  bool _isButtonTapAction = false;
  final Duration _normalSwipeDuration = const Duration(milliseconds: 280);
  final Duration _buttonTapSwipeDuration = const Duration(milliseconds: 350);

  final List<Map<String, dynamic>> _filterOptions = [
    {'label': 'Filter', 'icon': Icons.filter_list_outlined, 'isFilter': true},
    {'label': 'Distance', 'icon': Icons.location_on_outlined, 'isFilter': false},
    {'label': 'Age', 'icon': Icons.cake_outlined, 'isFilter': false},
  ];

  List<Profile> _profiles = [];
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  double _rotation = 0.0;

  double _bubbleScale = 1.0;
  double _bubbleOpacity = 0.0;
  String _bubbleText = "";
  Color _bubbleColor = Colors.green;



  // Google Places search
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isSearchFocused = false;
  late AnimationController _resetAnimationController;
  Animation<Offset>? _resetOffsetAnimation;
  Animation<double>? _resetRotationAnimation;
  @override
  void initState() {
    super.initState();
    _resetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
      if (mounted && _resetOffsetAnimation != null) {
        setState(() {
          _dragOffset = _resetOffsetAnimation!.value;
          _rotation = _resetRotationAnimation!.value;
        });
      }
    });
    ever(controller.likeCountOverrides, (Map<String, int> overrides) {
      if (!mounted) return;
      setState(() {
        for (final entry in overrides.entries) {
          final idx = _profiles.indexWhere((p) => p.id == entry.key);
          if (idx != -1) {
            _profiles[idx].likes = entry.value;
          }
        }
      });
    });

    _initializeLocation();

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // ✅ NAYA — flying heart controller setup
    _flyingHeartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flyingHeartOffset = Tween<double>(begin: 0, end: 180).animate(
      CurvedAnimation(parent: _flyingHeartController, curve: Curves.easeOutCubic),
    );
    _flyingHeartOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _flyingHeartController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _flyingHeartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showFlyingHeart = false;
          });
        }
        _flyingHeartController.reset();
      }
    });

    // ✅ NAYA — flying ignore/X controller setup
    _flyingIgnoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flyingIgnoreOffset = Tween<double>(begin: 0, end: 180).animate(
      CurvedAnimation(parent: _flyingIgnoreController, curve: Curves.easeOutCubic),
    );
    _flyingIgnoreOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _flyingIgnoreController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _flyingIgnoreController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showFlyingIgnore = false;
          });
        }
        _flyingIgnoreController.reset();
      }
    });

    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: _normalSwipeDuration,
    );
    _swipeProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _swipeAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _swipeProgressAnimation.addListener(() {
      if (mounted) {
        setState(() {
          final progress = _swipeProgressAnimation.value;
          final isLike = _swipeDirection == SwipeDirection.like;
          final screenWidth = MediaQuery.of(context).size.width;
          final targetDy = -40.0;
          final targetDx = 300.0 * (isLike ? 1 : -1);

          final targetRotation = 0.5 * (isLike ? 1 : -1);

          _dragOffset = Offset(
            targetDx * progress,
            targetDy * progress,
          );
          _rotation = targetRotation * progress;

          if (progress > 0.3 && progress < 0.8) {
            _bubbleScale = 1.0 + (progress - 0.3) * 2.5;
            _bubbleOpacity = (progress - 0.3) * 3.0;
          } else if (progress >= 0.8) {
            _bubbleScale = 1.0 + (0.8 - 0.3) * 2.5;
            _bubbleOpacity = 1.0;
          } else {
            _bubbleScale = 1.0;
            _bubbleOpacity = 0.0;
          }
        });
      }
    });

    _swipeProgressAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            if (_profiles.isNotEmpty && _currentIndex < _profiles.length) {
              _currentIndex = (_currentIndex + 1) % _profiles.length;
            } else {
              _currentIndex = 0;
            }
            _dragOffset = Offset.zero;
            _rotation = 0.0;
            _isSwiping = false;
            _bubbleScale = 1.0;
            _bubbleOpacity = 0.0;
          });

          // ✅ NAYA — list khatam hone pe naye profiles fetch karo
          if (_currentIndex == 0 && _profiles.isNotEmpty) {
            _fetchMoreProfiles();
          }
        }
        _swipeAnimationController.reset();
      }
    });
    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isAnimatingLike = false;
          });
        }
        _likeAnimationController.reset();
      }
    });

    ever(locationController.locationFetched, (bool fetched) {
      if (fetched && mounted) {
        print('✅ Location fetched, loading profiles...');
        _loadProfiles();
      }
    });

    ever(controller.profiles, (List<Map<String, dynamic>> profilesData) {
      if (mounted) {
        print('📊 Received ${profilesData.length} profiles from controller');
        _updateProfiles(profilesData);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (locationController.locationFetched.value && !_profilesLoaded) {
        _loadProfiles();
      }
    });
  }

  // ✅ NAYA — current photo index nikalne ke liye helper
  int _getPhotoIndex(String profileId) => _photoIndexMap[profileId] ?? 0;

  // ✅ NAYA — left/right arrow tap pe photo change karo
  void _changePhoto(Profile profile, int direction) {
    if (profile.photos.length <= 1) return;
    setState(() {
      int current = _photoIndexMap[profile.id] ?? 0;
      current = (current + direction) % profile.photos.length;
      if (current < 0) current += profile.photos.length;
      _photoIndexMap[profile.id] = current;
    });
  }

  // ✅ NAYA method — list khatam hone pe fresh profiles fetch karo
  Future<void> _fetchMoreProfiles() async {
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      await controller.fetchProfiles();
    } catch (e) {
      print('❌ Error fetching more profiles: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMore = false;
        });
      }
    }
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      if (locationController.locationFetched.value) {
        print('✅ Location already fetched: ${locationController.getShortLocation()}');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        // Set default location
        locationController.fullAddress.value = 'Pune, Maharashtra, India';
        locationController.city.value = 'Pune';
        locationController.state.value = 'Maharashtra';
        locationController.locationFetched.value = true;
        Get.snackbar(
          'Location',
          'Using default location (Pune) as location services are disabled',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied');
          // Set default location
          locationController.fullAddress.value = 'Pune, Maharashtra, India';
          locationController.city.value = 'Pune';
          locationController.state.value = 'Maharashtra';
          locationController.locationFetched.value = true;
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permission permanently denied');
        // Set default location
        locationController.fullAddress.value = 'Pune, Maharashtra, India';
        locationController.city.value = 'Pune';
        locationController.state.value = 'Maharashtra';
        locationController.locationFetched.value = true;
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      final bool success = await locationController.getCurrentLocation();

      if (success && mounted) {
        print('✅ Location fetched successfully: ${locationController.getShortLocation()}');

      } else {
        print('❌ Failed to fetch location, using default');
        locationController.fullAddress.value = 'Pune, Maharashtra, India';
        locationController.city.value = 'Pune';
        locationController.state.value = 'Maharashtra';
        locationController.locationFetched.value = true;
      }
    } catch (e) {
      print('❌ Error fetching location: $e');
      locationController.fullAddress.value = 'Pune, Maharashtra, India';
      locationController.city.value = 'Pune';
      locationController.state.value = 'Maharashtra';
      locationController.locationFetched.value = true;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }
  // 🔥🔥🔥 Force refresh profiles with current location
  void _forceRefreshProfiles() {
    print('🔄 Force refreshing profiles for new location');

    setState(() {
      _profiles = [];
      _profilesLoaded = false;
      _currentIndex = 0;
      _dragOffset = Offset.zero;
      _rotation = 0.0;
      _bubbleOpacity = 0.0;
      _bubbleScale = 1.0;
      _isSwiping = false;
    });

    // Small delay to ensure location is updated
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        controller.fetchProfiles();
      }
    });
  }

  void _loadProfiles() {
    if (controller.profiles.isNotEmpty) {
      print('📊 Loading existing profiles: ${controller.profiles.length}');
      _updateProfiles(controller.profiles);
    } else if (!controller.isLoading.value) {
      print('📊 Fetching profiles from API...');
      controller.fetchProfiles();
    }
  }

  // 🔥🔥🔥 UPDATED: Convert profiles with real distance
// 🔥🔥🔥 FIXED: Convert profiles with real distance and like count
// 🔥🔥🔥 FIXED: Convert profiles with real distance and like count
  void _updateProfiles(List<Map<String, dynamic>> profilesData) {
    if (profilesData.isEmpty) {
      print('⚠️ No profiles data received');
      setState(() {
        _profiles = [];
        _profilesLoaded = true;
        _currentIndex = 0;
      });
      return;
    }

    print('🔄 Converting ${profilesData.length} profiles');

    // DEBUG: Print raw API data
    for (var p in profilesData) {
      print('🔍 RAW: ${p['firstName']} - likes: ${p['likes']}, likedBy: ${p['likedBy']}');
    }

    final newProfiles = profilesData.map((p) {
      // Get the converted data
      final converted = controller.convertToProfileModel(p);

      // DEBUG: Print converted data
      print('🔍 CONVERTED: ${converted['name']} - likes: ${converted['likes']}');

      // Extract photos
      List<String> allPhotos = [];
      if (p['photos'] != null && p['photos'] is List) {
        final photosList = p['photos'] as List;
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
      }

      if (allPhotos.isEmpty) {
        allPhotos = ['assets/images/hprofile.png'];
      }

      String mainImage = allPhotos.isNotEmpty ? allPhotos[0] : 'assets/images/hprofile.png';

      // Extract coordinates
      double profileLat = 0.0;
      double profileLon = 0.0;

      if (p['location'] != null && p['location'] is Map<String, dynamic>) {
        final locationMap = p['location'] as Map<String, dynamic>;
        final coordinates = locationMap['coordinates'] as List?;
        if (coordinates != null && coordinates.length == 2) {
          profileLon = (coordinates[0] as num).toDouble();
          profileLat = (coordinates[1] as num).toDouble();
        }
      }

      if (profileLat == 0.0 || profileLon == 0.0) {
        profileLat = 18.5204;
        profileLon = 73.8567;
      }

      double distanceInKm = locationController.getDistanceToProfile(profileLat, profileLon);
      String distanceDisplay = locationController.formatDistance(distanceInKm);

      // ✅ FIX: Get likes from converted data - use 'likes' not 'likeCount'
      int likes = converted['likes'] as int? ?? 0;

      // If still 0, try to get from the raw data directly
      if (likes == 0) {
        // Check if 'likes' exists in raw data
        if (p.containsKey('likes')) {
          final likesValue = p['likes'];
          if (likesValue is int) {
            likes = likesValue;
          } else if (likesValue is String) {
            likes = int.tryParse(likesValue) ?? 0;
          } else if (likesValue is num) {
            likes = likesValue.toInt();
          }
        }

        // If still 0, check likedBy array length
        if (likes == 0 && p['likedBy'] != null && p['likedBy'] is List) {
          final likedBy = p['likedBy'] as List;
          if (likedBy.isNotEmpty) {
            likes = likedBy.length;
            print('📊 Calculated likes from likedBy: $likes');
          }
        }
      }

      print('✅ FINAL likes for ${p['firstName']}: $likes');

      final profile = Profile(
        id: p['_id'] ?? '',
        name: '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim() != ''
            ? '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim()
            : p['nickName'] ?? 'User',
        age: _calculateAge(p['birthday']),
        distance: distanceDisplay,
        distanceInKm: distanceInKm,
        location: _getLocationNameFromCoordinates(profileLat, profileLon),
        image: mainImage,
        photos: allPhotos,
        bio: p['bio'] ?? 'Hello, I\'m using this app',
        hobbies: _extractHobbiesFromAPI(p),
        hasPhoto: allPhotos.isNotEmpty && allPhotos[0] != 'assets/images/hprofile.png',
        likes: likes, // ✅ Use 'likes' value
        placeToMeet: p['placeToMeet'] ?? false,
        isVerified: p['isVerified'] ?? false,
        latitude: profileLat,
        longitude: profileLon,
      );

      return profile;
    }).toList();

    setState(() {
      _profiles = _sortProfilesByDistance(newProfiles);
      _profilesLoaded = true;
      _currentIndex = _profiles.isNotEmpty ? 0 : 0;

      // DEBUG: Print final values
      print('📊 FINAL PROFILES:');
      for (var profile in _profiles) {
        print('📊 ${profile.name}: ${profile.likes} likes');
      }
    });

  }


  List<Profile> _sortProfilesByDistance(List<Profile> profiles) {
    final sorted = List<Profile>.from(profiles);
    sorted.sort((a, b) => a.distanceInKm.compareTo(b.distanceInKm));
    return sorted;
  }
  // Helper method to calculate age from birthday
  int _calculateAge(String? birthday) {
    if (birthday == null) return 0;
    try {
      final birthDate = DateTime.parse(birthday);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

// Helper method to extract hobbies from API data
  List<String> _extractHobbiesFromAPI(Map<String, dynamic> p) {
    List<String> hobbies = [];

    if (p['looking'] != null && p['looking'] is Map<String, dynamic>) {
      final title = p['looking']['title']?.toString();
      if (title != null && title.isNotEmpty) {
        hobbies.add(title);
      }
    }

    if (p['interest'] != null && p['interest'].toString().isNotEmpty) {
      hobbies.add(p['interest'].toString());
    }

    if (hobbies.isEmpty) {
      hobbies = ['Social', 'Chat'];
    }

    return hobbies.take(3).toList();
  }

// Simple location name from coordinates (without geocoding)
  String _getLocationNameFromCoordinates(double lat, double lon) {
    // Common Indian cities with their coordinates (lat, lon)
    final cities = {
      'Pune, Maharashtra': [18.5204, 73.8567],
      'Mumbai, Maharashtra': [19.0760, 72.8777],
      'Delhi, Delhi': [28.6139, 77.2090],
      'Bangalore, Karnataka': [12.9716, 77.5946],
      'Chennai, Tamil Nadu': [13.0827, 80.2707],
      'Hyderabad, Telangana': [17.3850, 78.4867],
      'Kolkata, West Bengal': [22.5726, 88.3639],
      'Ahmedabad, Gujarat': [23.0225, 72.5714],
      'Jaipur, Rajasthan': [26.9124, 75.7873],
      'Lucknow, Uttar Pradesh': [26.8467, 80.9462],
      'Nagpur, Maharashtra': [21.1458, 79.0882],
      'Indore, Madhya Pradesh': [22.7196, 75.8577],
      'Bhopal, Madhya Pradesh': [23.2599, 77.4126],
      'Patna, Bihar': [25.5941, 85.1376],
      'Vadodara, Gujarat': [22.3072, 73.1812],
      'Coimbatore, Tamil Nadu': [11.0168, 76.9558],
      'Kochi, Kerala': [9.9312, 76.2673],
    };

    String closestCity = 'Location available';
    double minDistance = double.infinity;

    for (var entry in cities.entries) {
      final cityLat = entry.value[0];
      final cityLon = entry.value[1];

      final distance = _calculateDistance(lat, lon, cityLat, cityLon);

      if (distance < minDistance) {
        minDistance = distance;
        closestCity = entry.key;
      }
    }

    if (minDistance > 50) {
      return 'Location available';
    }

    return closestCity;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(_degreesToRadians(lat1)) * Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * Math.pi / 180.0;
  }

  Future<void> _updateProfileCoordinates(Profile profile) async {
    if (profile.latitude == 0.0 || profile.longitude == 0.0) {
      try {
        final coords = await locationController.getCoordinatesFromCity(profile.location);
        if (coords['latitude'] != 0.0 && coords['longitude'] != 0.0) {
          final index = _profiles.indexWhere((p) => p.id == profile.id);
          if (index != -1) {
            final updatedProfile = Profile(
              id: profile.id,
              name: profile.name,
              age: profile.age,
              distance: profile.distance,
              distanceInKm: profile.distanceInKm,
              location: profile.location,
              image: profile.image,
              photos: profile.photos,
              bio: profile.bio,
              hobbies: profile.hobbies,
              hasPhoto: profile.hasPhoto,
              likes: profile.likes,
              placeToMeet: profile.placeToMeet,
              isVerified: profile.isVerified,
              latitude: coords['latitude']!,
              longitude: coords['longitude']!,
            );
            setState(() {
              _profiles[index] = updatedProfile;
            });
            print('✅ Updated coordinates for ${profile.name}');
          }
        }
      } catch (e) {
        print('❌ Error updating coordinates: $e');
      }
    }
  }

// 🔥 FIXED: Google Places API Methods with better error handling
  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.isEmpty || query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final String apiKey = ApiUrls.googleMapsApiKey;

      final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&key=$apiKey'
          '&types=geocode'
          '&language=en'
          '&components=country:in';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          print('✅ Found ${predictions.length} results for "$query"');

          setState(() {
            _searchResults = predictions.map((place) {
              return {
                'description': place['description']?.toString() ?? '',
                'placeId': place['place_id']?.toString() ?? '',
                'mainText': place['structured_formatting']?['main_text']?.toString() ?? '',
                'secondaryText': place['structured_formatting']?['secondary_text']?.toString() ?? '',
              };
            }).toList();
            _isSearching = false;
          });
        } else {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching locations: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    try {
      final String apiKey = ApiUrls.googleMapsApiKey;
      final String url = 'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=formatted_address,geometry'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          return {
            'formattedAddress': result['formatted_address'] ?? '',
            'latitude': result['geometry']['location']['lat'] as double,
            'longitude': result['geometry']['location']['lng'] as double,
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting place details: $e');
      return null;
    }
  }

  void _onPlaceSelected(Map<String, dynamic> place) async {
    // Close the keyboard immediately
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      // Show loading in the bottom sheet
      setState(() {
        _isSearching = true;
      });

      final details = await _getPlaceDetails(place['placeId']);

      if (details != null && mounted) {
        // Update location
        locationController.updateLocation(
            details['latitude'] as double,
            details['longitude'] as double
        );
        locationController.fullAddress.value = details['formattedAddress'] ?? place['description'];

        String city = _extractCity(details['formattedAddress'] ?? place['description']);
        locationController.city.value = city;

        String state = _extractState(details['formattedAddress'] ?? place['description']);
        if (state.isNotEmpty) {
          locationController.state.value = state;
        }



        // Close the bottom sheet
        Navigator.pop(context);

        // Force refresh profiles with new location
        _forceRefreshProfiles();

      } else {
        _handleFallbackLocation(place['description']);
      }
    } catch (e) {
      print('❌ Error getting place details: $e');
      _handleFallbackLocation(place['description']);
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchController.clear();
          _searchResults = [];
          _isSearchFocused = false;
        });
      }
    }
  }
  // Helper method to extract state from address
  String _extractState(String address) {
    final parts = address.split(',');
    if (parts.length >= 3) {
      // Check if the last part is a state or country
      String lastPart = parts.last.trim();
      String secondLastPart = parts[parts.length - 2].trim();

      // Common Indian states
      List<String> indianStates = [
        'Maharashtra', 'Karnataka',  'Tamil Nadu', 'Uttar Pradesh',
        'Gujarat', 'Rajasthan', 'West Bengal', 'Andhra Pradesh', 'Telangana',
        'Kerala', 'Punjab', 'Haryana', 'Bihar', 'Odisha', 'Madhya Pradesh',
        'Chhattisgarh', 'Jharkhand', 'Assam', 'Himachal Pradesh', 'Goa'
      ];

      if (indianStates.contains(secondLastPart)) {
        return secondLastPart;
      } else if (indianStates.contains(lastPart)) {
        return lastPart;
      }

      // If second last is not a state but last is a country, try third last
      if (parts.length >= 4) {
        String thirdLastPart = parts[parts.length - 3].trim();
        if (indianStates.contains(thirdLastPart)) {
          return thirdLastPart;
        }
      }
    }
    return '';
  }

  void _handleFallbackLocation(String locationName) {
    try {
      locationController.getCoordinatesFromCity(locationName).then((coords) {
        if (coords['latitude'] != 0.0 && coords['longitude'] != 0.0) {
          locationController.updateLocation(
              coords['latitude']!,
              coords['longitude']!
          );
          locationController.fullAddress.value = locationName;

          String city = _extractCity(locationName);
          locationController.city.value = city;

          String state = _extractState(locationName);
          if (state.isNotEmpty) {
            locationController.state.value = state;
          }


          Navigator.pop(context);
          _forceRefreshProfiles();
        } else {

        }
      });
    } catch (e) {
      print('❌ Fallback location error: $e');

    }
  }

  String _extractCity(String address) {
    final parts = address.split(',');
    if (parts.length >= 2) {
      String cityPart = parts[1].trim();
      if (cityPart.length <= 15) {
        return cityPart;
      }
      if (parts.length >= 3) {
        String thirdPart = parts[2].trim();
        if (thirdPart.length <= 15) {
          return thirdPart;
        }
      }
    }
    return parts[0].trim();
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _flyingHeartController.dispose(); // ✅ NAYA
    _swipeAnimationController.dispose();
    _resetAnimationController.dispose(); // ✅ NAYA
    _searchController.dispose();
    _flyingIgnoreController.dispose();
    super.dispose();
  }

  // ==================== FILTER METHODS ====================

  int _getFilterCount() {
    int count = 0;
    if (_selectedDistance != "40km" && _selectedDistance != "Select Distance") count++;
    if (_selectedAgeRange != "22-30" && _selectedAgeRange != "Select Age") count++;
    if (_hasPhoto) count++;
    if (_selectedGender != "Man") count++;
    if (_selectedLocation != "Pune, Mh") count++;
    if (!_onlineStatus) count++;
    if (_selectedHasMeet != "Yes") count++;
    if (_selectedPosition != "All") count++;
    if (_selectedHeight != "All") count++;
    if (_selectedBodyType != "All") count++;
    if (_selectedLanguage != "All") count++;
    return count;
  }
  void _applyFilters() {
    // ✅ Update controller values
    controller.selectedDistance.value = _selectedDistance;
    controller.selectedAgeRange.value = _selectedAgeRange;

    // ✅ Apply all filters (this calls fetchProfilesWithFilters which combines both)
    controller.fetchProfilesWithFilters();
  }
  void _showAllFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 300,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 35),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const SizedBox(width: 60),
                                const Expanded(
                                  child: Text(
                                    "All Filters",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextButton(
                                    onPressed: () {
                                      setModalState(() {
                                        _selectedDistance = "Select Distance";
                                        _selectedAgeRange = "Select Age";
                                      });
                                      setState(() {
                                        _selectedDistance = "Select Distance";
                                        _selectedAgeRange = "Select Age";
                                      });
                                      // Controller ka real default rakho — placeholder text
                                      // yahan bhejne se agar baad me Distance/Age sheet me
                                      // koi value select kiye bina "Apply" dabaye, parsing
                                      // crash ho sakta hai (double.parse fail).
                                      controller.selectedDistance.value = "40km";
                                      controller.selectedAgeRange.value = "22-30";
// sheet band karo
                                      _forceRefreshProfiles(); // saari (unfiltered) profiles
                                    },

                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                    child: const Text(
                                      "Reset",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                _filterTile(
                                  title: "Distance",
                                  value: _selectedDistance,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showDistanceFilter();
                                  },
                                ),
                                _filterTile(
                                  title: "Age Range",
                                  value: _selectedAgeRange,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showAgeFilter();
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // 🔥 Update controller values before applying
                                  controller.selectedDistance.value = _selectedDistance;
                                  controller.selectedAgeRange.value = _selectedAgeRange;
                                  controller.applyFilters();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  "Apply Filters (${_getFilterCount()})",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 265,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDistanceFilter() {
    List<String> distances = ["10km", "20km", "30km", "40km", "50km", "100km"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 300,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 35),
                          const Text(
                            "Select Distance",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: distances.map((distance) {
                                return _locationTile(
                                  title: distance,
                                  subtitle: "Show people within $distance",
                                  icon: Icons.location_on,
                                  isSelected: _selectedDistance == distance,
                                  onTap: () {
                                    setModalState(() {
                                      _selectedDistance = distance;
                                    });
                                    // ✅ Update controller immediately
                                    controller.selectedDistance.value = distance;
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  controller. fetchProfilesWithDistanceFilter();

                                  // ✅ Apply filters

                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Apply Distance",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 265,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _showAgeFilter() {
    List<Map<String, String>> ageRanges = [
      {"label": "18-22", "subtitle": "Young adults"},
      {"label": "22-30", "subtitle": "Adults"},
      {"label": "30-40", "subtitle": "Mature adults"},
      {"label": "40+", "subtitle": "40 and above"},
      {"label": "Any", "subtitle": "All ages"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 300,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 35),
                          const Text(
                            "Select Age Range",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: ageRanges.map((ageRange) {
                                return _locationTile(
                                  title: ageRange["label"]!,
                                  subtitle: ageRange["subtitle"]!,
                                  icon: Icons.cake,
                                  isSelected: _selectedAgeRange == ageRange["label"],
                                  onTap: () {
                                    setModalState(() {
                                      _selectedAgeRange = ageRange["label"]!;
                                    });
                                    // ✅ Update controller immediately
                                    controller.selectedAgeRange.value = ageRange["label"]!;
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // ✅ Apply filters
                                  _applyFilters();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Apply Age Range",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 265,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // 🔥🔥🔥 UPDATED: Show location picker with Google Places search
  // 🔥🔥🔥 UPDATED: Show location picker with Google Places search
  void _showLocationPicker() {
    _searchController.clear();
    _searchResults = [];
    _isSearchFocused = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 250,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 35),
                          const Text(
                            "Select Location",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // SEARCH TEXT FIELD
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffF5F5F5),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: TextField(
                                controller: _searchController,
                                // 🔥 FIX: Use onChanged for real-time search
                                onChanged: (value) {
                                  print('🔍 Typing: $value');

                                  // Immediately update the modal state
                                  setModalState(() {
                                    _isSearchFocused = true;
                                    _searchResults = []; // Clear old results
                                  });

                                  // Call API if text length > 2
                                  if (value.isNotEmpty && value.length >= 2) {
                                    // 🔥 FIX: Call search method with modal state
                                    _fetchLocationSuggestionsWithModalState(value, setModalState);
                                  } else if (value.isEmpty) {
                                    setModalState(() {
                                      _searchResults = [];
                                      _isSearching = false;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Search city or place...",
                                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      setModalState(() {
                                        _searchResults = [];
                                        _isSearching = false;
                                      });
                                    },
                                  )
                                      : null,
                                  filled: true,
                                  fillColor: const Color(0xffF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🔥 FIX: Show results based on search state
                          if (_isSearching)
                            const Expanded(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_searchResults.isNotEmpty && _isSearchFocused)
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  if (index >= _searchResults.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final place = _searchResults[index];
                                  final mainText = place['mainText']?.toString() ??
                                      place['description']?.toString() ??
                                      'Unknown';
                                  final secondaryText = place['secondaryText']?.toString() ??
                                      'Tap to select';

                                  return _locationTile(
                                    title: mainText,
                                    subtitle: secondaryText,
                                    icon: Icons.location_on,
                                    isSelected: false,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      _onPlaceSelected(place);
                                    },
                                    showChevron: false,
                                  );
                                },
                              ),
                            )
                          else if (_searchController.text.isNotEmpty &&
                                !_isSearching &&
                                _searchResults.isEmpty &&
                                _searchController.text.length >= 2)
                              const Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No locations found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Try searching with a different name',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                            // Show quick location options
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  children: [
                                    _locationTile(
                                      title: "Use Current Location",
                                      subtitle: locationController.locationFetched.value
                                          ? locationController.getShortLocation()
                                          : "Fetching...",
                                      icon: Icons.my_location,
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _isLoadingLocation = true;
                                        });
                                        _getCurrentLocationAndRefresh();
                                      },
                                    ),
                                    _locationTile(
                                      title: "Pune",
                                      subtitle: "Maharashtra",
                                      icon: Icons.location_on,
                                      onTap: () {
                                        locationController.city.value = 'Pune';
                                        locationController.state.value = 'Maharashtra';
                                        locationController.fullAddress.value = 'Pune, Maharashtra, India';
                                        locationController.locationFetched.value = true;
                                        locationController.updateLocation(18.5204, 73.8567);
                                        Navigator.pop(context);
                                        _forceRefreshProfiles();
                                      },
                                    ),
                                    _locationTile(
                                      title: "Mumbai",
                                      subtitle: "Maharashtra",
                                      icon: Icons.location_on,
                                      onTap: () {
                                        locationController.city.value = 'Mumbai';
                                        locationController.state.value = 'Maharashtra';
                                        locationController.fullAddress.value = 'Mumbai, Maharashtra, India';
                                        locationController.locationFetched.value = true;
                                        locationController.updateLocation(19.0760, 72.8777);
                                        Navigator.pop(context);
                                        _forceRefreshProfiles();
                                      },
                                    ),
                                    _locationTile(
                                      title: "Bangalore",
                                      subtitle: "Karnataka",
                                      icon: Icons.location_on,
                                      onTap: () {
                                        locationController.city.value = 'Bangalore';
                                        locationController.state.value = 'Karnataka';
                                        locationController.fullAddress.value = 'Bangalore, Karnataka, India';
                                        locationController.locationFetched.value = true;
                                        locationController.updateLocation(12.9716, 77.5946);
                                        Navigator.pop(context);
                                        _forceRefreshProfiles();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 215,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _searchController.clear();
        _searchResults = [];
        _isSearching = false;
        _isSearchFocused = false;
      });
    });
  }

// 🔥 NEW: Method to fetch suggestions with modal state
  Future<void> _fetchLocationSuggestionsWithModalState(
      String query,
      StateSetter setModalState
      ) async {
    if (query.isEmpty || query.length < 2) {
      setModalState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setModalState(() {
      _isSearching = true;
    });

    try {
      final String apiKey = ApiUrls.googleMapsApiKey;

      final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&key=$apiKey'
          '&types=geocode'
          '&language=en'
          '&components=country:in';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          print('✅ Found ${predictions.length} results for "$query"');

          setModalState(() {
            _searchResults = predictions.map((place) {
              return {
                'description': place['description']?.toString() ?? '',
                'placeId': place['place_id']?.toString() ?? '',
                'mainText': place['structured_formatting']?['main_text']?.toString() ?? '',
                'secondaryText': place['structured_formatting']?['secondary_text']?.toString() ?? '',
              };
            }).toList();
            _isSearching = false;
          });
        } else if (data['status'] == 'ZERO_RESULTS') {
          setModalState(() {
            _searchResults = [];
            _isSearching = false;
          });
        } else {
          print('❌ API Error: ${data['status']} - ${data['error_message'] ?? ''}');
          setModalState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      } else {
        setModalState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching locations: $e');
      setModalState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }
  void _getCurrentLocationAndRefresh() async {
    try {
      // Check if location permission is granted
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {

        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {

          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Location Error',
          'Location permissions are permanently denied. Please enable them in settings.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Current location fetched: ${position.latitude}, ${position.longitude}');

      // Update location controller
      locationController.updateLocation(position.latitude, position.longitude);

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
          String state = place.administrativeArea ?? place.subAdministrativeArea ?? '';
          String country = place.country ?? '';

          if (city.isNotEmpty) {
            locationController.city.value = city;
          }
          if (state.isNotEmpty) {
            locationController.state.value = state;
          }

          String fullAddress = '$city, $state, $country';
          if (fullAddress.trim() != ', , ') {
            locationController.fullAddress.value = fullAddress;
          } else {
            locationController.fullAddress.value = '$city, $state';
          }
        }
      } catch (e) {
        print('❌ Error getting address: $e');
      }

      locationController.locationFetched.value = true;



      // Force refresh profiles with new location
      _forceRefreshProfiles();

    } catch (e) {
      print('❌ Error getting current location: $e');

    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }
  // ==================== HELPER WIDGETS ====================

  Widget _locationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    bool isSelected = false,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange : Colors.orange.withOpacity(.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.orange,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isNotEmpty ? title : 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.orange : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle.isNotEmpty ? subtitle : 'Tap to select',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.orange,
                  )
                else if (showChevron)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
  Widget _filterTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Text(title, style: const TextStyle(letterSpacing: 1.5, fontSize: 12)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 12, letterSpacing: 1.5, color: Colors.orange)),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  void _resetPosition() {
    final startOffset = _dragOffset;
    final startRotation = _rotation;

    if (startOffset == Offset.zero && startRotation == 0.0) return;

    _resetOffsetAnimation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resetAnimationController,
      curve: Curves.easeOutBack, // ✅ halka bounce — Bumble jaisa
    ));

    _resetRotationAnimation = Tween<double>(
      begin: startRotation,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _resetAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _resetAnimationController.forward(from: 0.0);
  }

  // ==================== SWIPE METHODS ====================


  void _likeProfile() {
    if (_isSwiping || _profiles.isEmpty || _currentIndex >= _profiles.length) return;

    final currentProfile = _profiles[_currentIndex];
    final int currentIndex = _currentIndex;

    // ✅ Turant (optimistic) update karo — animation shuru hone se pehle,
    // taaki card hatne se pehle hi naya count dikh jaye
    setState(() {
      _profiles[currentIndex].likes += 1;
    });
    print('✅ Optimistically updated likes for ${_profiles[currentIndex].name}: ${_profiles[currentIndex].likes}');

    controller.likeProfile(currentProfile.id).then((success) async {
      if (!success && mounted) {
        setState(() {
          if (currentIndex < _profiles.length) {
            _profiles[currentIndex].likes -= 1;
          }
        });
        print('⚠️ Like API failed, rolled back count');
        return;
      }

      // ✅ Success hone pe — single-profile GET endpoint se accurate 'likes' fetch karo
      final freshProfile = await controller.getProfileById(currentProfile.id);
      if (freshProfile != null && mounted && currentIndex < _profiles.length) {
        final likesValue = freshProfile['likes'];
        int? accurateLikes;
        if (likesValue is int) accurateLikes = likesValue;
        else if (likesValue is num) accurateLikes = likesValue.toInt();
        else if (likesValue is String) accurateLikes = int.tryParse(likesValue);

        if (accurateLikes != null) {
          setState(() {
            _profiles[currentIndex].likes = accurateLikes!;
          });
          print('✅ Accurate like count set for ${currentProfile.name}: $accurateLikes');
        }
      }
    }).catchError((error) {
      print('❌ Error liking profile: $error');
      if (mounted) {
        setState(() {
          if (currentIndex < _profiles.length) {
            _profiles[currentIndex].likes -= 1;
          }
        });
      }
    });

    setState(() {
      _showFlyingHeart = true; // ✅ NAYA — heart float+fade animation trigger
      _isAnimatingLike = true;
      _isSwiping = true;
      _swipeDirection = SwipeDirection.like;
      _bubbleText = "LIKE";
      _bubbleColor = Colors.green;
      _bubbleScale = 1.0;
      _bubbleOpacity = 0.0;
    });

    _likeAnimationController.forward(from: 0.0);
    _flyingHeartController.forward(from: 0.0); // ✅ NAYA
    _swipeAnimationController.duration = _isButtonTapAction
        ? _buttonTapSwipeDuration
        : _normalSwipeDuration;
    _swipeAnimationController.forward(from: 0.0);
    _isButtonTapAction = false;
  }

  void _refreshProfileLikeCount(String profileId) async {
    try {
      // Get the updated profile from API
      final updatedProfile = await controller.getProfileById(profileId);

      if (updatedProfile != null && mounted) {
        // Extract the new like count
        int newLikeCount = 0;
        if (updatedProfile.containsKey('likes')) {
          if (updatedProfile['likes'] is int) {
            newLikeCount = updatedProfile['likes'] as int;
          } else if (updatedProfile['likes'] is String) {
            newLikeCount = int.tryParse(updatedProfile['likes'] as String) ?? 0;
          } else if (updatedProfile['likes'] is num) {
            newLikeCount = (updatedProfile['likes'] as num).toInt();
          }
        }

        // Update the profile in the list
        final index = _profiles.indexWhere((p) => p.id == profileId);
        if (index != -1) {
          setState(() {
            _profiles[index].likes = newLikeCount;
            print('✅ Updated like count for ${_profiles[index].name}: $newLikeCount');
          });
        }
      }
    } catch (e) {
      print('❌ Error refreshing like count: $e');
    }
  }
  void _dislikeProfile() {
    // Fix: Check if profiles list is empty or index is out of bounds
    if (_isSwiping || _profiles.isEmpty || _currentIndex >= _profiles.length) return;

    setState(() {
      _showFlyingIgnore = true; // ✅ NAYA — X float+fade animation trigger
      _isSwiping = true;
      _swipeDirection = SwipeDirection.dislike;
      _bubbleText = "NOPE";
      _bubbleColor = Colors.red;
      _bubbleScale = 1.0;
      _bubbleOpacity = 0.0;
    });

    _flyingIgnoreController.forward(from: 0.0); // ✅ NAYA

    _swipeAnimationController.duration = _isButtonTapAction
        ? _buttonTapSwipeDuration
        : _normalSwipeDuration;

    _swipeAnimationController.forward(from: 0.0);

    setState(() {
      _isButtonTapAction = false;
    });
  }

  void _openProfileDetail(Profile profile) {
    if (profile == null) return;

    List<String> allPhotos = profile.photos.isNotEmpty
        ? profile.photos
        : ['assets/images/hprofile.png'];

    List<Map<String, dynamic>> photoObjects = allPhotos.map((url) {
      return {'image': url};
    }).toList();

    final profileData = {
      '_id': profile.id,
      'id': profile.id,
      'firstName': profile.name.split(' ').first,
      'lastName': profile.name.split(' ').length > 1 ? profile.name.split(' ').last : '',
      'nickName': profile.name,
      'age': profile.age,
      'birthday': DateTime.now().subtract(Duration(days: profile.age * 365)).toIso8601String(),
      'distance': profile.distance,
      'distanceInKm': profile.distanceInKm,
      'location': profile.location,
      'bio': profile.bio,
      'profession': 'Professional Model',
      'interests': profile.hobbies,
      'photos': photoObjects,
      'isVerified': profile.isVerified,
      'likeCount': profile.likes,
      'placeToMeet': profile.placeToMeet,
      'gender': {'gender': 'Man'},
      'looking': {'title': 'New Friends'},
    };

    Get.to(() => ProfiledetailView(profileData: profileData));
  }

  String _getUserLocationDisplay() {
    if (_isLoadingLocation) {
      return "Fetching location...";
    }

    if (locationController.locationFetched.value) {
      final displayLocation = locationController.getShortLocation();
      if (displayLocation.isNotEmpty && !displayLocation.contains('null')) {
        final city = locationController.getCity();
        final state = locationController.getState();

        if (city.isNotEmpty && state.isNotEmpty) {
          return '$city, $state';
        } else if (city.isNotEmpty) {
          return city;
        } else if (displayLocation.isNotEmpty) {
          return displayLocation;
        }
      }
    }

    return "Pune, Maharashtra";
  }
  // ✅ NAYA — Top card ke peeche 3 decorative "peek" layers, Tinder-jaisa stacked deck look
  List<Widget> _buildStackPeekLayers() {
    return List.generate(3, (i) {
      final depth = i + 1; // 1 = sabse upar/paas, 3 = sabse peeche
      final inset = depth * 10.0;      // sides se kitna andar simटेगा
      final bottomPeek = depth * 8.0;  // kitna neeche se peek karega
      final opacity = (1.0 - depth * 0.15).clamp(0.35, 1.0);
      return Positioned(
        left: inset,
        right: inset,
        top: inset * 0.5,
        bottom: 0,
        height: null,
        child: Transform.translate(
          offset: Offset(0, bottomPeek),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
          ),
        ),
      );
    }).reversed.toList(); // sabse peeche wali pehle draw ho, taaki top card sabse upar rahe
  }
  List<Widget> _buildProfileStack() {
    if (_profiles.isEmpty || _currentIndex >= _profiles.length) {
      return [];
    }

    final visibleEntries = _profiles.asMap().entries
        .where((entry) => entry.key >= _currentIndex && entry.key < _currentIndex + 3)
        .toList();

    return visibleEntries.reversed.map((entry) {
      final index = entry.key;
      final profile = entry.value;
      final isTopCard = index == _currentIndex;
      final stackDepth = index - _currentIndex; // 0 = top, 1 = next, 2 = next-next

      // ✅ Top card jitna udta hai, neeche wala card utna scale-up hota hai
      final dragProgress = isTopCard
          ? (_dragOffset.distance / 200).clamp(0.0, 1.0)
          : 0.0;
      final baseScale = 1.0 - (stackDepth * 0.04);
      final effectiveScale = stackDepth == 1
          ? baseScale + (dragProgress * 0.04) // next card 0.96 → 1.0
          : baseScale;

      return Positioned.fill(
        child: Transform.translate(
          offset: isTopCard ? _dragOffset : Offset.zero,
          child: Transform.rotate(
            angle: isTopCard ? _rotation : 0,
            child: Transform.scale(
              scale: effectiveScale,
              child: buildProfileCard(profile, isTopCard),
            ),
          ),
        ),
      );
    }).toList();
  }
  Widget buildBubbleOverlay() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _bubbleOpacity.clamp(0.0, 1.0),
        duration: const Duration(milliseconds: 50),
        child: Center(
          child: Transform.scale(
            scale: _bubbleScale.clamp(0.5, 2.5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: _bubbleColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _bubbleColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Text(
                _bubbleText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SKELETON/SHIMMER LOADING WIDGETS ====================

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0E0E0),
                  Color(0xFFF5F5F5),
                  Color(0xFFE0E0E0),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 15,
            child: Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 15,
            child: Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStack() {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform.translate(
            offset: const Offset(0, 0),
            child: _buildShimmerCard(),
          ),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: const Offset(0, 0),
            child: _buildShimmerCard(),
          ),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: const Offset(0, 0),
            child: _buildShimmerCard(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String getShortAppName(String name) {
      if (name.length <= 15) {
        return name;
      }
      return '${name.substring(0, 15)}...';
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF2EA),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,

        toolbarHeight: 64.h,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
        ),

        titleSpacing: 20.w,

        title: GestureDetector(
          onTap: _showLocationPicker,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '👋 ',
                    style: TextStyle(
                      fontSize: 11.sp,
                    ),
                  ),

                  Text(
                    'Welcome to ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  Text(
                    getShortAppName(
                      'Vibely',
                    ),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF6B00),
                      letterSpacing: .3,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Icon(
                    Icons.location_on,
                    color: const Color(0xFFFF6B00),
                    size: 16.sp,
                  ),

                  SizedBox(width: 3.w),

                  Text(
                    _getUserLocationDisplay(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(width: 1.w),

                  Icon(
                    Icons.arrow_drop_down,
                    color: const Color(0xFF172033),
                    size: 20.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => NotificatoinView()),
            padding: EdgeInsets.zero,
            icon: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/notification.svg',
                      width: 22.w,
                      height: 22.h,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFF6B00),
                        BlendMode.srcIn,
                      ),
                    ),
                    Positioned(
                      right: -5.w,
                      top: -5.h,
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B00),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterOptions.length,
                        itemBuilder: (context, index) {
                          final option = _filterOptions[index];
                          return buildChip(
                            title: option['label'] as String,
                            selected: _selectedFilterIndex == index,
                            icon: option['icon'] as IconData,
                            isFilter: option['isFilter'] as bool? ?? false,
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = index;
                              });
                              switch (index) {
                                case 0:
                                  _showAllFilter();
                                  break;
                                case 1:
                                  _showDistanceFilter();
                                  break;
                                case 2:
                                  _showAgeFilter();
                                  break;
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  // ✅ NAYA — conflict-free manual refresh button (gesture-based pull ki jagah)


                ],
              ),


              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && _profiles.isEmpty) {
                    return _buildShimmerStack();
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.fetchProfiles,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_profiles.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No profiles found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_currentIndex >= _profiles.length) {
                    _currentIndex = 0;
                  }

                  return Stack(
                    children: [
                      ..._buildStackPeekLayers(),
                      ..._buildProfileStack(),
                      // ✅ NAYA — pull-to-refresh indicator, jab neeche khinch rahe ho ya refresh chal raha ho
                      if (_isFetchingMore || _dragOffset.dy > 10)
                        Positioned(
                          top: -10,

                          left: 0,
                          right: 0,
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: _isFetchingMore
                                  ? 1.0
                                  : (_dragOffset.dy / 100).clamp(0.0, 1.0),
                              duration: const Duration(milliseconds: 100),
                              child: _isFetchingMore
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.transparent,
                                ),
                              )
                                  : const Icon(Icons.refresh, size: 20, color:Colors.transparent),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥🔥🔥 BUILD PROFILE CARD WITH REAL DISTANCE
  Widget buildProfileCard(Profile profile, bool isTop) {
    print('🃏 Building card for ${profile.name}: likeCount = ${profile.likes}');
    return GestureDetector(
      onPanUpdate: isTop && !_isSwiping
          ? (details) {
        setState(() {
          _dragOffset += details.delta;
          _rotation = _dragOffset.dx / 300;

          final screenWidth = MediaQuery.of(context).size.width;
          final threshold = screenWidth * 0.18;

          if (_dragOffset.dx > 20) {
            _bubbleText = "LIKE";
            _bubbleColor = Colors.green;
            _bubbleScale = 1.0 + (_dragOffset.dx / threshold).clamp(0.0, 1.0) * 0.5;
            _bubbleOpacity = (_dragOffset.dx / threshold).clamp(0.0, 1.0);
          } else if (_dragOffset.dx < -20) {
            _bubbleText = "NOPE";
            _bubbleColor = Colors.red;
            _bubbleScale = 1.0 + (-_dragOffset.dx / threshold).clamp(0.0, 1.0) * 0.5;
            _bubbleOpacity = (-_dragOffset.dx / threshold).clamp(0.0, 1.0);
          } else {
            _bubbleOpacity = 0.0;
          }
        });
      }
          : null,
      onPanEnd: isTop && !_isSwiping
          ? (details) {
        final velocity = details.velocity.pixelsPerSecond;
        final screenWidth = MediaQuery.of(context).size.width;

        // Pull-to-refresh / detail view checks same rahenge
        if (velocity.dy > 500 || _dragOffset.dy > 100) {
          _triggerPullRefresh();
          return;
        }

        if (velocity.dy < -600 || _dragOffset.dy < -150) {
          _openProfileDetail(profile);
          _resetPosition();
          return;
        }

        setState(() {
          _isButtonTapAction = false;
        });

        // ✅ Threshold kaafi kam kar diya — sirf ~18% screen width
        // ya halki si velocity se hi next profile dikh jaayega
        final distanceThreshold = screenWidth * 0.18; // pehle 150px fixed tha
        final velocityThreshold = 300.0; // pehle 800 tha

        if (velocity.dx > velocityThreshold || _dragOffset.dx > distanceThreshold) {
          _likeProfile();
        } else if (velocity.dx < -velocityThreshold || _dragOffset.dx < -distanceThreshold) {
          _dislikeProfile();
        } else {
          _resetPosition();
          setState(() {
            _bubbleOpacity = 0.0;
          });
        }
      }
          : null,
      // ✅ NAYA — card ke kisi bhi khaali jagah tap karne se profile detail khule
      // (arrows/buttons/badges ka apna GestureDetector hai, so wahan tap karne se yeh fire nahi hoga)
      onTap: () => _openProfileDetail(profile),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ✅ NAYA — photo index ke hisaab se current image dikhao
            Builder(builder: (context) {
              final photoIndex = _getPhotoIndex(profile.id);
              final currentPhoto = profile.photos.isNotEmpty
                  ? profile.photos[photoIndex.clamp(0, profile.photos.length - 1)]
                  : profile.image;
              return currentPhoto.startsWith('http')
                  ? Image.network(currentPhoto, fit: BoxFit.fill, errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/hprofile.png', fit: BoxFit.fill);
              })
                  : Image.asset(currentPhoto, fit: BoxFit.fill);
            }),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0, 0.25),
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black45,
                    Colors.black87,
                    Colors.black,
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
            // ✅ NAYA — side vignette (left-right thoda dark) taaki edges pe photo halka dabа jaaye
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.28),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.28),
                  ],
                  stops: const [0.0, 0.18, 0.82, 1.0],
                ),
              ),
            ),
            if (isTop)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Opacity(
                          opacity: _dragOffset.dx > 30 ? (_dragOffset.dx / 180).clamp(0.0, 1.0) : 0.0,
                          child: Transform.rotate(
                            angle: -0.35,
                            child: const Icon(Icons.favorite, color: Colors.red, size: 120),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Opacity(
                          opacity: _dragOffset.dx < -30 ? (-_dragOffset.dx / 180).clamp(0.0, 1.0) : 0.0,
                          child: Transform.rotate(
                            angle: 0.35,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "NOPE",
                                style: TextStyle(color: Colors.red, fontSize: 45, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // ✅ FIXED — Left / Right arrow icons hamesha dikhenge (photo count condition hata di)
            if (isTop)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_isSwiping || _profiles.isEmpty || _currentIndex >= _profiles.length) return;
                      setState(() {
                        _isButtonTapAction = true;
                        _bubbleText = "NOPE";
                        _bubbleColor = Colors.red;
                      });
                      _dislikeProfile();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.35),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.45),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (isTop)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_isSwiping || _profiles.isEmpty || _currentIndex >= _profiles.length) return;
                      setState(() {
                        _isButtonTapAction = true;
                        _bubbleText = "LIKE";
                        _bubbleColor = Colors.green;
                      });
                      _likeProfile();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.35),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.45),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 15,
              top: 15,
              child: _buildOnlineStatusBadge(profile.id),  // ✅ Yahi ek line badli
            ),
            Positioned(
              right: 15,
              top: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      // 🖤 Glass background
                      color: Colors.black.withOpacity(0.35),

                      borderRadius: BorderRadius.circular(20),

                      // 🤍 Glass border
                      border: Border.all(
                        color: Colors.white.withOpacity(0.45),
                        width: 1,
                      ),

                      // ✨ Soft shadow
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _likeAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isAnimatingLike &&
                                  _currentIndex < _profiles.length &&
                                  _currentIndex == _profiles.indexOf(profile)
                                  ? _likeScaleAnimation.value
                                  : 1.0,
                              child: const Icon(
                                Icons.favorite_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 6),

                        Text(
                          _formatLikeCount(profile.likes),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom:10),
                        child: Text("${profile.name}, ${profile.age}",
                            style: const TextStyle(letterSpacing: 1.5, color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      if (profile.isVerified)
                        SvgPicture.asset(
                          "assets/icons/blue_tick.svg",
                          width: 18,
                          height: 18,
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _openProfileDetail(profile),
                        child: SvgPicture.asset(
                          "assets/icons/hshare.svg",
                          width: 35,
                          height: 35,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${profile.distance} away (${profile.location})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Chips
                      Row(
                        children: [
                          // Designer Chip
                          // MBA Chip
                          // Looking For Chip
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Place to meet
                      Row(
                        children: [
                          // 📍 Place to meet
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C4AB6).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.7),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Place to meet",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ✅ Yes / ❌ No
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                final index = _profiles.indexOf(profile);
                                if (index != -1) {
                                  _profiles[index].placeToMeet =
                                  !_profiles[index].placeToMeet;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: profile.placeToMeet
                                    ? const Color(0xFF56C271)
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.7),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    profile.placeToMeet
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    profile.placeToMeet ? "Yes" : "No",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 📝 Bio — only when available

                        ],
                      ),
                      SizedBox(height: 30,),
                    ],
                  ),

                ],
              ),
            ),
            if (isTop)
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child:

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ❌ Cancel / Dislike
                    actionButton(
                      Icons.close_rounded,
                      Colors.white,
                      const Color(0xFF64748B),
                      size: 65,
                      onTap: () {
                        setState(() {
                          _isButtonTapAction = true;
                          _bubbleText = "NOPE";
                          _bubbleColor = Colors.red;
                        });

                        _dislikeProfile();
                      },
                    ),

                    // ❤️ Like
                    actionButton(
                      Icons.favorite,
                      Colors.transparent,
                      Colors.white,
                      size: 80,
                      isLike: true,
                      onTap: () {
                        setState(() {
                          _isButtonTapAction = true;
                          _bubbleText = "LIKE";
                          _bubbleColor = Colors.green;
                        });

                        _likeProfile();
                      },
                    ),

                    // 💬 Chat
                    actionButton(
                      Icons.chat_bubble,
                      Colors.white,
                      const Color(0xFF4285F4),
                      size: 65,
                      imagePath: 'assets/icons/message.png',
                      onTap: () {
                        if (profile.id.isEmpty) {
                          Get.snackbar('Error', 'User ID not found');
                          return;
                        }

                        final chatService = Get.find<ChatService>();
                        final myId = chatService.currentUserId ?? '';

                        if (myId.isEmpty) {
                          Get.snackbar('Error', 'Please login first');
                          return;
                        }

                        final sortedIds = [myId, profile.id]..sort();
                        final localChatRoomId = sortedIds.join('_');

                        Get.to(
                              () => const ChatView(),
                          arguments: {
                            'userId': profile.id,
                            'userName': profile.name,
                            'userImage': profile.image,
                            'chatRoomId': localChatRoomId,
                          },
                        );

                        chatService.getOrCreateChatRoom(profile.id).catchError((e) {
                          print('⚠️ Background chat room creation failed: $e');
                          return '';
                        });

                        chatService.startChat(profile.id).catchError((e) {
                          print('⚠️ Background startChat failed: $e');
                          return null;
                        });
                      },
                    ),

                  ],
                ),
              ),
            // ✅ NAYA — Flying heart: like ke turant baad heart button ke upar se float+fade (bada + glow)
            if (isTop && _showFlyingHeart)
              AnimatedBuilder(
                animation: _flyingHeartController,
                builder: (context, child) {
                  return Positioned(
                    bottom: 50 + _flyingHeartOffset.value,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Opacity(
                          opacity: _flyingHeartOpacity.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 1.3 + (0.5 * _flyingHeartController.value),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF841F).withOpacity(0.65),
                                    blurRadius: 40,
                                    spreadRadius: 12,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFA146),
                                    Color(0xFFFF6100),
                                  ],
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 130,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            // ✅ NAYA — Flying X (dislike): left-swipe/NOPE ke turant baad button ke upar se float+fade (bada + glow)
            if (isTop && _showFlyingIgnore)
              AnimatedBuilder(
                animation: _flyingIgnoreController,
                builder: (context, child) {
                  return Positioned(
                    bottom: 50 + _flyingIgnoreOffset.value,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Opacity(
                          opacity: _flyingIgnoreOpacity.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 1.3 + (0.5 * _flyingIgnoreController.value),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF64748B).withOpacity(0.65),
                                    blurRadius: 40,
                                    spreadRadius: 12,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF94A3B8),
                                    Color(0xFF475569),
                                  ],
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 130,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  String _formatLikeCount(int count) {
    if (count >= 1000) {
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1)}M';
      }
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }

  Widget buildChip({
    required String title,
    required bool selected,
    required IconData icon,
    required bool isFilter,
    required VoidCallback onTap,
  }) {
    final bool firstChip = isFilter;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: firstChip
                    ? Colors.white
                    : Colors.black,
              ),

              const SizedBox(width: 5),

              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: firstChip
                      ? Colors.white
                      : Colors.black,
                  fontWeight: firstChip || selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),

              if (firstChip && _getFilterCount() > 0)
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getFilterCount().toString(),
                    style: const TextStyle(
                      color: Color(0xffFF6B00),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          // 🔥 FIRST CHIP = FULL ORANGE
          // ⚪ OTHER CHIPS = WHITE
          backgroundColor: firstChip
              ? const Color(0xffFF6B00)
              : Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: firstChip
                  ? const Color(0xffFF6B00)
                  : selected
                  ? Colors.orange
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
        ),
      ),
    );
  }

  Widget actionButton(
      IconData icon,
      Color bg,
      Color iconColor, {
        double size = 65,
        VoidCallback? onTap,
        bool isLike = false,
        String? imagePath,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: isLike
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFA146),
              Color(0xFFFF6100),
              Color(0xFFE55400),
            ],
          )
              : null,

          color: isLike ? null : bg,

          boxShadow: isLike
              ? [
            BoxShadow(
              color: const Color(0xFFFF6100).withOpacity(0.65),
              blurRadius: 18,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Center(
          child: imagePath != null
              ? Image.asset(
            imagePath,
            width: size * 0.70,
            height: size * 0.70,
            fit: BoxFit.contain,
          )
              : Icon(
            icon,
            color: iconColor,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }}
enum SwipeDirection {
  like,
  dislike,
}
Widget _buildOnlineStatusBadge(String profileId) {
  final chatService = Get.find<ChatService>();

  return StreamBuilder<DocumentSnapshot>(
    stream: chatService.getUserStatus(profileId),
    builder: (context, snapshot) {
      bool isOnline = false;

      if (snapshot.hasData && snapshot.data!.exists) {
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final isOnlineFlag = data?['online'] ?? false;
        final lastSeen = data?['lastSeen'] as Timestamp?;

        if (isOnlineFlag && lastSeen != null) {
          final diff = DateTime.now().difference(lastSeen.toDate());
          isOnline = diff.inSeconds < 60;
        }
      }

      return
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                // 🖤 Same glass background as Favorite
                color: Colors.black.withOpacity(0.35),

                borderRadius: BorderRadius.circular(20),

                // 🤍 Same glass border
                border: Border.all(
                  color: Colors.white.withOpacity(0.45),
                  width: 1,
                ),

                // ✨ Same soft shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🟢 Online / ⚪ Offline dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline
                          ? Colors.green
                          : Colors.grey,
                      boxShadow: [
                        BoxShadow(
                          color: (isOnline
                              ? Colors.green
                              : Colors.grey)
                              .withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Active / Offline
                  Text(
                    isOnline ? "Active" : "Offline",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    },
  );
}