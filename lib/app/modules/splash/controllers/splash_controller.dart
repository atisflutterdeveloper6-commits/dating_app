// lib/app/modules/splash/controllers/splash_controller.dart

import 'dart:convert';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../apiurl/api_url.dart';

import '../../onboarding/views/onboarding_view.dart';
import '../../login/views/login_view.dart';
import '../../dashboard/views/dashboard_view.dart';

class SplashController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var splashImageUrl = ''.obs;
  var errorMessage = ''.obs;
  var isFirstTime = true.obs;
  
  // Storage service instance
  final StorageService _storage = StorageService();
  
  // Navigation destination
  String? _destinationRoute;

  @override
  void onInit() {
    super.onInit();
    _fetchSplashScreen();
  }

  // ✅ API FUNCTION
  Future<void> _fetchSplashScreen() async {
    try {
      isLoading.value = true;
      print('🔄 Starting splash screen fetch...');
      
      // ✅ Add a timeout to prevent infinite loading
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.splashScreen}'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ API timeout - using default image');
          splashImageUrl.value = 'https://via.placeholder.com/150';
          return http.Response('{"success": false}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API Response: $data');
        
        if (data['success'] == true && data['data'] != null && data['data'].isNotEmpty) {
          splashImageUrl.value = data['data'][0]['splashImg'] ?? 'https://via.placeholder.com/150';
          print('✅ Splash image loaded: ${splashImageUrl.value}');
        } else {
          errorMessage.value = 'No splash image found';
          splashImageUrl.value = 'https://via.placeholder.com/150';
          print('⚠️ No splash image found, using default');
        }
      } else {
        errorMessage.value = 'Failed to load splash screen';
        splashImageUrl.value = 'https://via.placeholder.com/150';
        print('⚠️ API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      splashImageUrl.value = 'https://via.placeholder.com/150';
      print('❌ Splash error: $e');
    } finally {
      isLoading.value = false;
      print('✅ Loading completed, determining navigation...');
      determineNavigation(); // ✅ Now public
    }
  }

  // ✅ PUBLIC NAVIGATION METHOD (No underscore)
  void determineNavigation() {
    // ✅ Check if this is first time launch
    isFirstTime.value = _isFirstTimeLaunch();
    
    if (isFirstTime.value) {
      print('🎯 First time user - Navigating to Onboarding');
      _navigateToOnboarding();
    } else {
      print('🎯 Returning user - Checking status');
      _checkUserStatus();
    }
  }

  // ✅ CHECK IF FIRST TIME LAUNCH
  bool _isFirstTimeLaunch() {
    try {
      final hasSeenOnboarding = _storage.hasKey('has_seen_onboarding');
      print('📱 Has seen onboarding: $hasSeenOnboarding');
      return !hasSeenOnboarding;
    } catch (e) {
      print('❌ Error checking first time: $e');
      return true;
    }
  }

  // ✅ IMPROVED USER STATUS CHECK
  void _checkUserStatus() {
    try {
      final token = _storage.getAuthToken();
      final isLoggedIn = _storage.isLoggedIn();
      final hasProfile = _storage.isProfileCreated();
      final hasToken = token != null && token.isNotEmpty;
      final profileId = _storage.getProfileId();
      
      print('🔍 User Status Check:');
      print('  Is Logged In: $isLoggedIn');
      print('  Has Profile: $hasProfile');
      print('  Has Token: $hasToken');
      print('  Profile ID: ${profileId ?? '❌ Not found'}');

      if (!hasToken) {
        print('🔴 No token found - Redirecting to Login');
        _navigateToLogin();
        return;
      }

  if (_storage.isSessionUsable() && isLoggedIn && hasProfile && profileId != null) {
        print('🟢 Valid session - Redirecting to Dashboard');
        _navigateToDashboard();
      } else if (isLoggedIn && hasToken && !hasProfile) {
        print('🟡 Logged in but no profile - Redirecting to Profile Creation');
        _navigateToProfileCreation();
      } else {
        print('🔴 Invalid session - Redirecting to Login');
        _navigateToLogin();
      }
    } catch (e) {
      print('❌ Error checking user status: $e');
      _navigateToLogin();
    }
  }

  // ✅ NAVIGATION METHODS
  void _navigateToOnboarding() {
    print('🚀 Navigating to Onboarding in 2 seconds...');
    Future.delayed(const Duration(seconds: 2), () {
      try {
        _storage.saveData('has_seen_onboarding', true);
        Get.offAll(() => const OnboardingView());
        print('✅ Navigated to Onboarding');
      } catch (e) {
        print('❌ Navigation error: $e');
        Get.offAll(() => const OnboardingView());
      }
    });
  }

  void _navigateToLogin() {
    print('🚀 Navigating to Login in 2 seconds...');
    Future.delayed(const Duration(seconds: 2), () {
      try {
        Get.offAll(() => const LoginView());
        print('✅ Navigated to Login');
      } catch (e) {
        print('❌ Navigation error: $e');
        Get.offAll(() => const LoginView());
      }
    });
  }

  void _navigateToDashboard() {
    print('🚀 Navigating to Dashboard in 2 seconds...');
    Future.delayed(const Duration(seconds: 2), () {
      try {
        Get.offAll(() => const DashboardView());
        print('✅ Navigated to Dashboard');
      } catch (e) {
        print('❌ Navigation error: $e');
        Get.offAll(() => const DashboardView());
      }
    });
  }

  void _navigateToProfileCreation() {
    print('🚀 Navigating to Profile Creation in 2 seconds...');
    Future.delayed(const Duration(seconds: 2), () {
      try {
        Get.offAll(() => const LoginView());
        print('✅ Navigated to Profile Creation');
      } catch (e) {
        print('❌ Navigation error: $e');
        Get.offAll(() => const LoginView());
      }
    });
  }

  // ✅ RETRY FUNCTION
  void retry() {
    print('🔄 Retrying splash screen...');
    errorMessage.value = '';
    _fetchSplashScreen();
  }

  // ✅ MARK ONBOARDING AS SEEN
  void markOnboardingAsSeen() {
    _storage.saveData('has_seen_onboarding', true);
    print('✅ Onboarding marked as seen');
  }

  // ✅ RESET APP STATE
  void resetAppState() {
    print('🔄 Resetting app state...');
    _storage.clearAllIncludingPreferences();
    _fetchSplashScreen();
  }

  // ✅ GET METHODS
  String getSplashImage() => splashImageUrl.value;
  bool getIsLoading() => isLoading.value;
  String getErrorMessage() => errorMessage.value;
}