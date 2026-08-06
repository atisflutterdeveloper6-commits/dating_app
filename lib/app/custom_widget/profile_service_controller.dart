// lib/app/controllers/profile_controller.dart

import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/notification_services.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/models/all_gender_model.dart';
import 'package:dating_app/app/models/profile_all_model.dart';
import 'package:dating_app/app/modules/chat/views/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dating_app/app/modules/like2/controllers/like2_controller.dart';
class ProfileServiceController extends GetxController {
  static ProfileServiceController get to => Get.find();
  

  final http.Client _client = http.Client();
  final StorageService _storage = StorageService();
  final blockedProfilesList = <ProfileModel>[].obs;

  // Observables
  final profile = ProfileModel().obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isProfileCreated = false.obs;
  final errorMessage = ''.obs;
  final profilesList = <ProfileModel>[].obs;
  final likedProfilesList = <ProfileModel>[].obs;

  // Profile ID
  String? profileId;

  // Phone number
  var phoneNumber = ''.obs;

  // Store local photo paths for multipart upload
  List<String> photoPaths = [];

  // ✅ Naya helper — hamesha valid/fresh Firebase ID token deta hai
// ✅ Naya helper — hamesha valid/fresh Firebase ID token deta hai
Future<String?> _getFirebaseAuthToken() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ No Firebase user found');
      return null;
    }

    // ✅ Pehle check karo ki cached token expire hone wala hai ya nahi
    bool needsForceRefresh = false;
    try {
      final tokenResult = await user.getIdTokenResult(false);
      final expiry = tokenResult.expirationTime;
      // Agar 5 minute se kam bacha hai ya already expire ho chuka hai, force refresh karo
      if (expiry == null || DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)))) {
        needsForceRefresh = true;
      }
    } catch (_) {
      needsForceRefresh = true;
    }

    final token = await user.getIdToken(needsForceRefresh);
    if (token != null && token.isNotEmpty) {
      await _storage.saveToken(token);
    }
    return token;
  } catch (e) {
    print('❌ Error getting Firebase token: $e');
    // ✅ Fallback: seedha force refresh try karo
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true);
        if (token != null) await _storage.saveToken(token);
        return token;
      }
    } catch (e2) {
      print('❌ Force refresh also failed: $e2');
    }
    return _storage.getToken(); // last resort fallback
  }
}
  // ============================================================
  // INTERNET CHECK
  // ============================================================

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // ============================================================
  // LOCATION METHODS - ADD THIS
  // ============================================================

  void updateLocation(String? location) {
    if (location != null && location.isNotEmpty) {
      profile.update((val) {
        val?.location = location;
      });
      _autoSave();
      print('📍 Location updated in profile: $location');
    }
  }

  String? getLocation() {
    return profile.value.location;
  }
// ============================================================
// VERIFICATION METHODS - ONLY DOCUMENT & SELFIE
// ============================================================
// ✅ Public method — OTP verify ke baad call hota hai, logout ke baad local storage
  // clear hone par bhi backend se profile match karke recover karta hai
  Future<bool> recoverProfileByPhone(String phone) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.isEmpty) return false;

      print('🔍 Trying to recover profile for phone: $cleanPhone');

      final fetched = await fetchAllProfiles();
      if (!fetched) return false;

      ProfileModel? found;
      final last10 = cleanPhone.length >= 10
          ? cleanPhone.substring(cleanPhone.length - 10)
          : cleanPhone;

      for (final p in profilesList) {
        final pPhone = (p.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
        if (pPhone.isNotEmpty && pPhone.endsWith(last10)) {
          found = p;
          break;
        }
      }

      if (found == null) {
        print('ℹ️ No matching profile found for this phone');
        return false;
      }

      profile.value = found;
      profileId = found.id;

      if (found.id != null && found.id!.isNotEmpty) {
        await _storage.saveProfileId(found.id!);
      }
      if (found.phone != null && found.phone!.isNotEmpty) {
        await _storage.savePhoneNumber(found.phone!);
        phoneNumber.value = found.phone!;
      }

      await _storage.saveProfileData(found.toJson());
      await _storage.setProfileCreated(true);
      isProfileCreated.value = true;

      print('✅ Profile recovered from backend: ${found.id}');
      return true;
    } catch (e) {
      print('❌ Error recovering profile: $e');
      return false;
    }
  }
Future<bool> updateVerification({
  File? document,
  File? selfie,
}) async {
  try {
    isSaving.value = true;
    errorMessage.value = '';

    print('========== UPDATE VERIFICATION ==========');
    print('📄 Document: ${document?.path ?? 'Not provided'}');
    print('📸 Selfie: ${selfie?.path ?? 'Not provided'}');

    if (!await checkInternet()) {
      errorMessage.value = 'No internet connection.';
      return false;
    }
    final firebaseToken = await _getFirebaseAuthToken();

    final currentProfileId = _storage.getProfileId();
    if (currentProfileId == null || currentProfileId.isEmpty) {
      errorMessage.value = 'Profile ID not found.';
      return false;
    }

    // Create multipart request
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiUrls.baseUrl}${ApiUrls.updateProfile(currentProfileId)}'),
    );

    request.headers['Accept'] = 'application/json';
    if (firebaseToken != null) {
      request.headers['Authorization'] = 'Bearer $firebaseToken';
    }

    // Add document if provided
    if (document != null && document.existsSync()) {
      final fileExtension = document.path.split('.').last.toLowerCase();
      final mimeType = _getMimeTypeForVerification(fileExtension);
      
      print('📄 Document file: ${document.path}');
      print('📄 File extension: $fileExtension');
      print('📄 MIME type: $mimeType');
      
      // Validate file size (max 10MB)
      final fileSize = document.lengthSync();
      if (fileSize > 10 * 1024 * 1024) {
        errorMessage.value = 'Document file size exceeds 10MB limit';
        return false;
      }
      
      // Validate file type
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'];
      if (!allowedExtensions.contains(fileExtension)) {
        errorMessage.value = 'Document must be JPG, PNG, PDF, DOC, or DOCX';
        return false;
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          document.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      print('✅ Document added to request');
    }

    // Add selfie if provided
    if (selfie != null && selfie.existsSync()) {
      final fileExtension = selfie.path.split('.').last.toLowerCase();
      final mimeType = _getMimeTypeForVerification(fileExtension);
      
      print('📸 Selfie file: ${selfie.path}');
      print('📸 File extension: $fileExtension');
      print('📸 MIME type: $mimeType');
      
      // Validate file size (max 5MB for selfie)
      final fileSize = selfie.lengthSync();
      if (fileSize > 5 * 1024 * 1024) {
        errorMessage.value = 'Selfie file size exceeds 5MB limit';
        return false;
      }
      
      // Validate file type - selfie should be image only
      final allowedExtensions = ['jpg', 'jpeg', 'png'];
      if (!allowedExtensions.contains(fileExtension)) {
        errorMessage.value = 'Selfie must be JPG or PNG image';
        return false;
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'selfie',
          selfie.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      print('✅ Selfie added to request');
    }

    print('📤 Sending ${request.files.length} file(s) for verification');

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(responseBody);
      final profileData = data['data'] ?? data;
      
      // Update profile with new data
      profile.value = ProfileModel.fromJson(profileData);
      
      if (profileData['phone'] != null) {
        phoneNumber.value = profileData['phone'].toString();
      }
      
      await _storage.saveProfileData(profileData);
      
      print('✅ Verification updated successfully');
      return true;
    } else {
      final data = jsonDecode(responseBody);
      errorMessage.value = data['message'] ?? 'Failed to update verification';
      print('❌ ${errorMessage.value}');
      return false;
    }
  } catch (e) {
    errorMessage.value = _handleError(e);
    print('❌ Error updating verification: $e');
    return false;
  } finally {
    isSaving.value = false;
  }
}

// Helper method to get MIME type for verification files
String _getMimeTypeForVerification(String extension) {
  switch (extension.toLowerCase()) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'pdf':
      return 'application/pdf';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    default:
      print('⚠️ Unknown file extension: $extension, defaulting to image/jpeg');
      return 'image/jpeg';
  }
}
  // ============================================================
  // FETCH ENUM VALUES FROM SERVER
  // ============================================================
Future<bool> likeProfile(String targetProfileId) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    if (!await checkInternet()) {
      errorMessage.value = 'No internet connection.';
      return false;
    }

    var firebaseToken = await _getFirebaseAuthToken();
    final currentProfileId = _storage.getProfileId();
    if (currentProfileId == null || currentProfileId.isEmpty) {
      errorMessage.value = 'Current profile ID not found';
      return false;
    }

    final url = '${ApiUrls.baseUrl}${ApiUrls.likeProfile(currentProfileId, targetProfileId)}';

    Future<http.Response> sendRequest(String? token) {
      return _client.patch(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
    }

    var response = await sendRequest(firebaseToken);

    if (response.statusCode == 401) {
      print('⚠️ Got 401, force refreshing token and retrying...');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        firebaseToken = await user.getIdToken(true);
        await _storage.saveToken(firebaseToken ?? '');
        response = await sendRequest(firebaseToken);
      }
    }

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Profile liked successfully');

      // ✅ FIX: Response me target profile ka poora data already aata hai —
      // usse seedha likedProfilesList me daal do, taaki Like2 screen
      // turant update ho jaaye bina extra fetch ke.
      try {
        final data = jsonDecode(response.body);
        final profileData = data['data'];
        if (profileData != null) {
          final likedProfile = ProfileModel.fromJson(profileData);

          // Duplicate na ho isliye check karo
          final alreadyExists = likedProfilesList.any((p) => p.id == likedProfile.id);
          if (!alreadyExists) {
            likedProfilesList.add(likedProfile);
            print('✅ Added ${likedProfile.firstName} to likedProfilesList (now ${likedProfilesList.length})');
          }
        }
      } catch (e) {
        print('⚠️ Could not parse liked profile from response: $e');
      }

      // ✅ FIX: Like2Controller ko force refresh karwao agar wo screen registered hai,
      // taaki uski apni likedProfiles Rx list bhi sync ho jaaye
      try {
        if (Get.isRegistered<Like2Controller>()) {
          Get.find<Like2Controller>().forceRefreshFromHomepage();
        }
      } catch (e) {
        print('⚠️ Could not notify Like2Controller: $e');
      }

      return true;
    } else {
      final data = jsonDecode(response.body);
      errorMessage.value = data['message'] ?? 'Failed to like profile';
      return false;
    }
  } catch (e) {
    errorMessage.value = _handleError(e);
    return false;
  } finally {
    isLoading.value = false;
  }
}
  Future<bool> unlikeProfile(String targetProfileId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('========== UNLIKE PROFILE ==========');
      print('📤 Target Profile ID: $targetProfileId');

      if (!await checkInternet()) {
        errorMessage.value = 'No internet connection.';
        return false;
      }
      final firebaseToken = await _getFirebaseAuthToken();
      final currentProfileId = _storage.getProfileId();
      if (currentProfileId == null || currentProfileId.isEmpty) {
        errorMessage.value = 'Current profile ID not found';
        return false;
      }

      final url = '${ApiUrls.baseUrl}${ApiUrls.unlikeProfile(currentProfileId, targetProfileId)}';
      print('📤 Unlike URL: $url');

      final response = await _client
          .patch(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              if (firebaseToken != null)
                'Authorization': 'Bearer $firebaseToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        likedProfilesList.removeWhere((profile) => profile.id == targetProfileId);
        print('✅ Profile unliked successfully');
        return true;
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to unlike profile';
        print('❌ ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = _handleError(e);
      print('❌ Error unliking profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> fetchBlockedUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!await checkInternet()) {
        errorMessage.value = 'No internet connection.';
        return false;
      }
      final firebaseToken = await _getFirebaseAuthToken();

      final profileId = _storage.getProfileId();
      if (profileId == null || profileId.isEmpty) {
        errorMessage.value = 'Profile ID not found';
        return false;
      }

      final url = '${ApiUrls.baseUrl}${ApiUrls.getBlockedUsers(profileId)}';
      print('📤 Fetching blocked users from: $url');

      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              if (firebaseToken != null)
                'Authorization': 'Bearer $firebaseToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📥 Response Body: ${response.body}');
        
        List<dynamic> profilesData = [];
        
        if (data['data'] != null && data['data'] is List) {
          profilesData = data['data'];
        } else if (data is List) {
          profilesData = data;
        }

        blockedProfilesList.value = profilesData
            .where((item) => item is Map<String, dynamic>)
            .map((item) => ProfileModel.fromJson(item))
            .toList();

        print('✅ Fetched ${blockedProfilesList.length} blocked users');
        return true;
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to fetch blocked users';
        print('❌ ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = _handleError(e);
      print('❌ Error fetching blocked users: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<GenderModel>> fetchGenders() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.gender}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        final genders = items.map((item) => GenderModel.fromJson(item)).toList();
        print('✅ Fetched ${genders.length} genders');
        return genders;
      } else {
        throw Exception('Failed to fetch genders');
      }
    } catch (e) {
      print('❌ Error fetching genders: $e');
      return [];
    }
  }

  Future<List<SexualOrientationModel>> fetchSexualOrientations() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.sexualOrientation}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        final orientations = items
            .map((item) => SexualOrientationModel.fromJson(item))
            .toList();
        print('✅ Fetched ${orientations.length} sexual orientations');
        return orientations;
      } else {
        throw Exception('Failed to fetch sexual orientations');
      }
    } catch (e) {
      print('❌ Error fetching sexual orientations: $e');
      return [];
    }
  }

  Future<List<PositionModel>> fetchPositions() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.position}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        final positions = items.map((item) => PositionModel.fromJson(item)).toList();
        print('✅ Fetched ${positions.length} positions');
        return positions;
      } else {
        throw Exception('Failed to fetch positions');
      }
    } catch (e) {
      print('❌ Error fetching positions: $e');
      return [];
    }
  }

  Future<List<LookingForModel>> fetchLookingFor() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.looking}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        final lookingOptions =
            items.map((item) => LookingForModel.fromJson(item)).toList();
        print('✅ Fetched ${lookingOptions.length} looking options');
        return lookingOptions;
      } else {
        throw Exception('Failed to fetch looking options');
      }
    } catch (e) {
      print('❌ Error fetching looking options: $e');
      return [];
    }
  }

  // ============================================================
  // SET PHONE NUMBER
  // ============================================================

  void setPhoneNumber(String phone) {
    phoneNumber.value = phone;
    profile.update((val) {
      val?.phone = phone;
    });
    print('📱 Phone number set: $phone');
  }

  String getPhoneNumber() {
    return phoneNumber.value;
  }

  // ============================================================
  // GET VALID ENUM IDs
  // ============================================================

  Future<Map<String, String>> getValidEnumIds() async {
    final Map<String, String> ids = {};
    
    try {
      final genders = await fetchGenders();
      if (genders.isNotEmpty) {
        final man = genders.firstWhere(
          (g) => g.gender == 'Man', 
          orElse: () => genders.first
        );
        ids['gender'] = man.id;
        print('✅ Gender ID: ${man.id} (${man.gender})');
      }
      
      final positions = await fetchPositions();
      if (positions.isNotEmpty) {
        final pos = positions.firstWhere(
          (p) => p.title == 'Versatile', 
          orElse: () => positions.first
        );
        ids['position'] = pos.id;
        print('✅ Position ID: ${pos.id} (${pos.title})');
      }
      
      final orientations = await fetchSexualOrientations();
      if (orientations.isNotEmpty) {
        final ori = orientations.firstWhere(
          (o) => o.title == 'Straight', 
          orElse: () => orientations.first
        );
        ids['sexualOrientation'] = ori.id;
        print('✅ Sexual Orientation ID: ${ori.id} (${ori.title})');
      }
      
      final lookingOptions = await fetchLookingFor();
      if (lookingOptions.isNotEmpty) {
        final look = lookingOptions.firstWhere(
          (l) => l.title == 'New Friends', 
          orElse: () => lookingOptions.first
        );
        ids['lookingFor'] = look.id;
        print('✅ Looking For ID: ${look.id} (${look.title})');
      }
      
      return ids;
    } catch (e) {
      print('❌ Error fetching enum IDs: $e');
      return ids;
    }
  }

  // ============================================================
  // CREATE PROFILE WITH MULTIPART FORM DATA
  // ============================================================

  Future<bool> unblockUser(String blockedProfileId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('========== UNBLOCK USER ==========');
      print('📤 Blocked Profile ID: $blockedProfileId');

      if (!await checkInternet()) {
        errorMessage.value = 'No internet connection.';
        return false;
      }
      final firebaseToken = await _getFirebaseAuthToken();
      final currentProfileId = _storage.getProfileId();
      if (currentProfileId == null || currentProfileId.isEmpty) {
        errorMessage.value = 'Current profile ID not found';
        return false;
      }

      final url = '${ApiUrls.baseUrl}${ApiUrls.unblockUser(currentProfileId, blockedProfileId)}';
      print('📤 Unblock URL: $url');

      final response = await _client
          .delete(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              if (firebaseToken != null)
                'Authorization': 'Bearer $firebaseToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        blockedProfilesList.removeWhere((profile) => profile.id == blockedProfileId);
        print('✅ User unblocked successfully');
        return true;
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to unblock user';
        print('❌ ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = _handleError(e);
      print('❌ Error unblocking user: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

Future<bool> createProfile() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    print('========== CREATE PROFILE START ==========');

    if (!await checkInternet()) {
      errorMessage.value = 'No internet connection.';
      return false;
    }
    if (!_validateProfile()) {
      print('❌ Validation failed: ${errorMessage.value}');
      return false;
    }

    // 🔥 GET FIREBASE ID TOKEN
    final User? user = FirebaseAuth.instance.currentUser;
    String? firebaseToken;
    
    if (user != null) {
      try {
        firebaseToken = await user.getIdToken(true);
        print('✅ Firebase ID Token obtained: ${firebaseToken?.substring(0, 20)}...');
      } catch (e) {
        print('❌ Error getting Firebase token: $e');
        errorMessage.value = 'Authentication error. Please try again.';
        return false;
      }
    } else {
      print('❌ No Firebase user found');
      errorMessage.value = 'Please login first';
      return false;
    }

    print('📤 Fetching valid enum IDs from server...');
    final validIds = await getValidEnumIds();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiUrls.baseUrl}${ApiUrls.profiles}'),
    );

    request.headers['Accept'] = 'application/json';
    
    // 🔥 ADD FIREBASE TOKEN TO AUTHORIZATION HEADER
    request.headers['Authorization'] = 'Bearer $firebaseToken';
    
    // Also store the token for future use
    if (firebaseToken != null) {
      await _storage.saveToken(firebaseToken);
      await _storage.saveLoginToken(firebaseToken);
    }

    // ============================================
    // ADD ALL TEXT FIELDS
    // ============================================

    if (profile.value.firstName != null && profile.value.firstName!.isNotEmpty) {
      request.fields['firstName'] = profile.value.firstName!;
    }
    if (profile.value.lastName != null && profile.value.lastName!.isNotEmpty) {
      request.fields['lastName'] = profile.value.lastName!;
    }
    if (profile.value.nickName != null && profile.value.nickName!.isNotEmpty) {
      request.fields['nickName'] = profile.value.nickName!;
    }
    if (profile.value.birthday != null && profile.value.birthday!.isNotEmpty) {
      request.fields['birthday'] = profile.value.birthday!;
    }

    // Phone - Use from profile or phoneNumber
    if (profile.value.phone != null && profile.value.phone!.isNotEmpty) {
      request.fields['phone'] = profile.value.phone!;
      print('📤 Phone (from profile): ${profile.value.phone}');
    } else if (phoneNumber.value.isNotEmpty) {
      request.fields['phone'] = phoneNumber.value;
      print('📤 Phone (from phoneNumber): ${phoneNumber.value}');
    } else {
      request.fields['phone'] = '7415743916';
      print('📤 Phone (default): 7415743916');
    }
     String? fcmToken;
try {
  fcmToken = await NotificationService.instance.getFCMToken();
  print('✅ FCM Token obtained: $fcmToken');
} catch (e) {
  print('⚠️ Could not get FCM token: $e');
}
if (fcmToken != null && fcmToken.isNotEmpty) {
  request.fields['fcmToken'] = fcmToken;
  print('📤 FCM Token added to request: $fcmToken');
} else {
  print('⚠️ FCM Token not available — skipping field');
}

    // Gender
    if (validIds.containsKey('gender') && validIds['gender']!.isNotEmpty) {
      request.fields['gender'] = validIds['gender']!;
      print('📤 Gender ID (valid): ${validIds['gender']}');
    } else if (profile.value.gender != null && profile.value.gender!.isNotEmpty) {
      request.fields['gender'] = profile.value.gender!;
      print('📤 Gender ID (from profile): ${profile.value.gender}');
    }

    // Position
    if (validIds.containsKey('position') && validIds['position']!.isNotEmpty) {
      request.fields['position'] = validIds['position']!;
      print('📤 Position ID (valid): ${validIds['position']}');
    } else if (profile.value.position != null && profile.value.position!.isNotEmpty) {
      request.fields['position'] = profile.value.position!;
      print('📤 Position ID (from profile): ${profile.value.position}');
    }

    // Sexual Orientation
    if (validIds.containsKey('sexualOrientation') && validIds['sexualOrientation']!.isNotEmpty) {
      request.fields['sexOrientation'] = validIds['sexualOrientation']!;
      print('📤 Sexual Orientation ID (valid): ${validIds['sexualOrientation']}');
    } else if (profile.value.sexualOrientation != null && 
              profile.value.sexualOrientation!.isNotEmpty) {
      request.fields['sexOrientation'] = profile.value.sexualOrientation!;
      print('📤 Sexual Orientation ID (from profile): ${profile.value.sexualOrientation}');
    }

    // Looking For
    if (validIds.containsKey('lookingFor') && validIds['lookingFor']!.isNotEmpty) {
      request.fields['looking'] = validIds['lookingFor']!;
      print('📤 Looking For ID (valid): ${validIds['lookingFor']}');
    } else if (profile.value.lookingFor != null && 
              profile.value.lookingFor!.isNotEmpty) {
      request.fields['looking'] = profile.value.lookingFor!;
      print('📤 Looking For ID (from profile): ${profile.value.lookingFor}');
    }

    // Other fields
    if (profile.value.interestedIn != null && profile.value.interestedIn!.isNotEmpty) {
      request.fields['interest'] = profile.value.interestedIn!;
    }

    if (profile.value.meetPlace != null && profile.value.meetPlace!.isNotEmpty) {
      request.fields['placeToMeet'] = profile.value.meetPlace!;
    }

    if (profile.value.bio != null && profile.value.bio!.isNotEmpty) {
      request.fields['bio'] = profile.value.bio!;
    }

    if (profile.value.showGender != null) {
      request.fields['showGender'] = profile.value.showGender.toString();
    }

    if (profile.value.showOrientation != null) {
      request.fields['showOrientation'] = profile.value.showOrientation.toString();
    }
  // ============================================
    // ADD LOCATION FIELD
    // ============================================
    
    // Get location from profile or use default
    String locationString = profile.value.location ?? '';
    
    if (locationString.isNotEmpty && locationString != 'Unknown') {
      // Try to parse location as coordinates (lat,lng format)
      final locationParts = locationString.split(',').map((e) => e.trim()).toList();
      
      if (locationParts.length == 2) {
        final lat = double.tryParse(locationParts[0]);
        final lng = double.tryParse(locationParts[1]);
        
        if (lat != null && lng != null) {
          // Send as GeoJSON object with coordinates
          final locationJson = {
            'type': 'Point',
            'coordinates': [lng, lat]  // GeoJSON uses [longitude, latitude]
          };
          request.fields['location'] = jsonEncode(locationJson);
          print('📍 Location added as GeoJSON: [$lng, $lat]');
        } else {
          // If parse fails, send as string (may not work)
          request.fields['location'] = locationString;
          print('⚠️ Location sent as string: $locationString');
        }
      } else {
        // Not in lat,lng format - send as string
        request.fields['location'] = locationString;
        print('⚠️ Location sent as string: $locationString');
      }
    } else {
      // No location set - use default coordinates
      final defaultLocation = {
        'type': 'Point',
        'coordinates': [0.0, 0.0]
      };
      request.fields['location'] = jsonEncode(defaultLocation);
      print('⚠️ No location set, using default coordinates [0, 0]');
    }

    // ============================================
    // ADD PHOTOS
    // ============================================

    if (photoPaths.isEmpty) {
      errorMessage.value = 'At least one photo is required';
      print('❌ No photos selected');
      return false;
    }

    print('📸 Sending ${photoPaths.length} photos');
    for (int i = 0; i < photoPaths.length; i++) {
      final filePath = photoPaths[i];
      if (File(filePath).existsSync()) {
        final extension = filePath.split('.').last.toLowerCase();

        String mainType = 'image';
        String subType = 'jpeg';

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mainType = 'image';
            subType = 'jpeg';
            break;
          case 'png':
            mainType = 'image';
            subType = 'png';
            break;
          case 'gif':
            mainType = 'image';
            subType = 'gif';
            break;
          case 'webp':
            mainType = 'image';
            subType = 'webp';
            break;
          default:
            mainType = 'image';
            subType = 'jpeg';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'photos',
            filePath,
            contentType: MediaType(mainType, subType),
          ),
        );
        print('📸 Added photo $i: $filePath');
      } else {
        print('❌ File not found: $filePath');
      }
    }

    if (request.files.isEmpty) {
      errorMessage.value = 'Failed to add photos. Please try again.';
      print('❌ No files were added to request');
      return false;
    }

    print('📤 URL: ${ApiUrls.baseUrl}${ApiUrls.profiles}');
    print('📤 Fields: ${request.fields}');
    print('📤 Files: ${request.files.length}');

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(responseBody);
      
      String? token = data['token'];
      String? profileIdFromResponse = data['data']?['_id'] ?? data['_id'] ?? data['id'];
      String? phoneFromResponse = data['data']?['phone']?.toString() ?? data['phone']?.toString();
      
      try {
        // Store Firebase token (already stored above)
        // Store any additional tokens from response
        if (token != null && token.isNotEmpty) {
          await _storage.saveLoginToken(token);
          await _storage.saveToken(token);
          await _storage.setLoggedIn(true);
          print('✅ Login token and status saved');
        }
        
        if (profileIdFromResponse != null && profileIdFromResponse.isNotEmpty) {
          await _storage.saveProfileId(profileIdFromResponse);
          this.profileId = profileIdFromResponse;
          print('✅ Profile ID saved: $profileIdFromResponse');
        }
        
        if (phoneFromResponse != null && phoneFromResponse.isNotEmpty) {
          await _storage.savePhoneNumber(phoneFromResponse);
          this.phoneNumber.value = phoneFromResponse;
          print('✅ Phone number saved: $phoneFromResponse');
        }
        
        if (data['data'] != null) {
          await _storage.saveProfileData(data['data']);
          await _storage.saveLoginData(data);
          print('✅ Profile and login data saved');
        }
        
        await _storage.setProfileCreated(true);
        print('✅ Profile creation status saved');
        
      } catch (storageError) {
        print('❌ Error saving to storage: $storageError');
      }
      
      isProfileCreated.value = true;
      
      if (profileIdFromResponse != null && profileIdFromResponse.isNotEmpty) {
        profileId = profileIdFromResponse;
      } else {
        profileId = data['id'] ?? data['_id'];
      }

      if (data['data'] != null) {
        profile.value = ProfileModel.fromJson(data['data']);
        if (data['data']['phone'] != null) {
          phoneNumber.value = data['data']['phone'].toString();
        }
      } else if (data != null) {
        profile.value = ProfileModel.fromJson(data);
        if (data['phone'] != null) {
          phoneNumber.value = data['phone'].toString();
        }
      }

      print('✅ Profile created successfully: $profileId');
      print('🔑 Login token saved: ${token != null ? 'Yes' : 'No'}');
      print('🔑 Login status: ${_storage.isLoggedIn()}');
      
      return true;
    } else {
      final data = jsonDecode(responseBody);
      errorMessage.value = data['message'] ?? 'Failed to create profile';
      return false;
    }
  } catch (e) {
    errorMessage.value = _handleError(e);
    print('❌ Error creating profile: $e');
    return false;
  } finally {
    isLoading.value = false;
  }
}
  
Future<bool> fetchLikedProfiles() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    if (!await checkInternet()) {
      errorMessage.value = 'No internet connection.';
      return false;
    }

    final firebaseToken = await _getFirebaseAuthToken();
    final currentProfileId = _storage.getProfileId();
    if (currentProfileId == null || currentProfileId.isEmpty) {
      errorMessage.value = 'Profile ID not found';
      return false;
    }

    // STEP 1: Apna profile fetch karo taaki likedProfiles ids mile
    final ownProfileResponse = await _client
        .get(
          Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(currentProfileId)}'),
          headers: {
            'Accept': 'application/json',
            if (firebaseToken != null) 'Authorization': 'Bearer $firebaseToken',
          },
        )
        .timeout(const Duration(seconds: 30));

    print('📤 Own profile status: ${ownProfileResponse.statusCode}');

    if (ownProfileResponse.statusCode != 200) {
      errorMessage.value = 'Failed to fetch your profile';
      return false;
    }

    final ownData = jsonDecode(ownProfileResponse.body);
    final ownProfileData = ownData['data'] ?? ownData;

    final List<dynamic> rawLikedIds = ownProfileData['likedProfiles'] ?? [];

    // Duplicate/empty/self id hata do
    final uniqueIds = rawLikedIds
        .map((e) => e.toString())
        .where((id) => id.isNotEmpty && id != currentProfileId)
        .toSet()
        .toList();

    print('📤 Liked profile IDs found (${uniqueIds.length}): $uniqueIds');

    if (uniqueIds.isEmpty) {
      likedProfilesList.value = [];
      print('ℹ️ No liked profiles found');
      return true;
    }

    // STEP 2: Har id ke liye alag profile fetch karo (parallel)
    final futures = uniqueIds.map((id) async {
      try {
        final res = await _client
            .get(
              Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(id)}'),
              headers: {
                'Accept': 'application/json',
                if (firebaseToken != null) 'Authorization': 'Bearer $firebaseToken',
              },
            )
            .timeout(const Duration(seconds: 30));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final profileData = data['data'] ?? data;
          return ProfileModel.fromJson(profileData);
        } else {
          print('⚠️ Failed to fetch profile $id: ${res.statusCode}');
          return null;
        }
      } catch (e) {
        print('⚠️ Error fetching profile $id: $e');
        return null;
      }
    });

    final results = await Future.wait(futures);
    likedProfilesList.value = results.whereType<ProfileModel>().toList();

    print('✅ Fetched ${likedProfilesList.length} liked profiles (out of ${uniqueIds.length} ids)');
    return true;
  } catch (e) {
    errorMessage.value = _handleError(e);
    print('❌ Error fetching liked profiles: $e');
    return false;
  } finally {
    isLoading.value = false;
  }
}
  // ============================================================
  // UPDATE PHOTO PATHS
  // ============================================================

  void setPhotoPaths(List<String> paths) {
    photoPaths = paths.where((p) => File(p).existsSync()).toList();
    print('📸 Set ${photoPaths.length} photo paths');

    profile.update((val) {
      val?.photos = photoPaths;
    });
  }

  void addPhotoPath(String path) {
    if (File(path).existsSync()) {
      photoPaths.add(path);
      print('📸 Added photo path: $path');

      profile.update((val) {
        val?.photos ??= [];
        val?.photos?.add(path);
      });
    }
  }

  void removePhotoPath(String path) {
    photoPaths.remove(path);
    print('📸 Removed photo path: $path');

    profile.update((val) {
      val?.photos?.remove(path);
    });
  }

  // ============================================================
  // UPDATE PHOTOS
  // ============================================================

  void updatePhotos(List<File>? photos) {
    if (photos != null && photos.isNotEmpty) {
      final existingPaths = photos
          .where((file) => file.existsSync())
          .map((file) => file.path)
          .toList();

      if (existingPaths.isNotEmpty) {
        profile.update((val) {
          val?.photos = existingPaths;
        });

        photoPaths = existingPaths;
        print('📸 Updated ${photoPaths.length} photos from File list');
        print('📸 Photo paths: $photoPaths');
        _autoSave();
      } else {
        print('⚠️ No valid files found');
      }
    } else {
      print('⚠️ Photos list is null or empty');
    }
  }

  void updatePhotosFromPaths(List<String>? photoPathsList) {
    if (photoPathsList != null && photoPathsList.isNotEmpty) {
      final existingPaths = photoPathsList
          .where((path) => File(path).existsSync())
          .toList();

      if (existingPaths.isNotEmpty) {
        profile.update((val) {
          val?.photos = existingPaths;
        });

        photoPaths = existingPaths;
        print('📸 Updated ${photoPaths.length} photos from paths');
        _autoSave();
      }
    }
  }

  void addPhoto(String photoUrl) {
    if (File(photoUrl).existsSync()) {
      photoPaths.add(photoUrl);
    }

    profile.update((val) {
      val?.photos ??= [];
      val?.photos?.add(photoUrl);
    });
    _autoSave();
  }

  // ============================================================
  // UPLOAD PHOTO FROM GALLERY/CAMERA
  // ============================================================

  Future<bool> uploadPhotoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final path = image.path;
        addPhotoPath(path);
        return true;
      }

      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> uploadPhotoFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final path = image.path;
        addPhotoPath(path);
        return true;
      }

      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  // ============================================================
  // OTHER PROFILE APIs
  // ============================================================

  Future<bool> fetchAllProfiles() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!await checkInternet()) {
        errorMessage.value = 'No internet connection.';
        return false;
      }
      final firebaseToken = await _getFirebaseAuthToken();
      print('📤 Fetching all profiles...');
      print('📤 URL: ${ApiUrls.baseUrl}${ApiUrls.profiles}');

      final response = await _client
          .get(
            Uri.parse('${ApiUrls.baseUrl}${ApiUrls.profiles}'),
            headers: {
              'Accept': 'application/json',
              if (firebaseToken != null)
                'Authorization': 'Bearer $firebaseToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> profilesData = [];
        
        if (data['data'] != null && data['data'] is List) {
          profilesData = data['data'];
          print('✅ Found ${profilesData.length} profiles in data.data');
        } else if (data is List) {
          profilesData = data;
          print('✅ Found ${profilesData.length} profiles in response list');
        } else if (data['profiles'] != null && data['profiles'] is List) {
          profilesData = data['profiles'];
          print('✅ Found ${profilesData.length} profiles in data.profiles');
        } else if (data['data'] != null && data['data'] is Map) {
          profilesData = [data['data']];
          print('✅ Found single profile in data.data');
        } else {
          for (var key in data.keys) {
            if (data[key] is List) {
              profilesData = data[key];
              print('✅ Found ${profilesData.length} profiles in data.$key');
              break;
            }
          }
        }

        if (profilesData.isEmpty) {
          print('⚠️ No profiles found in response');
          profilesList.value = [];
          return true;
        }

        final List<ProfileModel> parsedProfiles = [];
        for (var item in profilesData) {
          try {
            if (item is Map<String, dynamic>) {
              final profile = ProfileModel.fromJson(item);
              parsedProfiles.add(profile);
            } else {
              print('⚠️ Invalid profile item: $item');
            }
          } catch (e) {
            print('❌ Error parsing profile: $e');
          }
        }

        profilesList.value = parsedProfiles;
        print('✅ Successfully fetched ${profilesList.length} profiles');
        
        if (profilesList.isNotEmpty) {
          print('📋 First profile: ${profilesList.first.firstName} ${profilesList.first.lastName}');
        }
        
        return true;
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to fetch profiles (Status: ${response.statusCode})';
        print('❌ ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = _handleError(e);
      print('❌ Error fetching profiles: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> fetchProfileById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!await checkInternet()) {
        errorMessage.value = 'No internet connection.';
        return false;
      }
      final firebaseToken = await _getFirebaseAuthToken();

      final response = await _client
          .get(
            Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(id)}'),
            headers: {
              'Accept': 'application/json',
              if (firebaseToken != null)
                'Authorization': 'Bearer $firebaseToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profileData = data['data'] ?? data;
        profile.value = ProfileModel.fromJson(profileData);
        profileId = id;
        
        if (profileData['phone'] != null) {
          phoneNumber.value = profileData['phone'].toString();
        }
        
        print('✅ Profile fetched successfully');
        return true;
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to fetch profile';
        return false;
      }
    } catch (e) {
      errorMessage.value = _handleError(e);
      print('❌ Error fetching profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBasicInfo({
    String? firstName,
    String? lastName,
    String? nickName,
    String? phone,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      print('========== UPDATE BASIC INFO ==========');
      print('📤 Fields to update:');
      print('  First Name: $firstName');
      print('  Last Name: $lastName');
      print('  Nick Name: $nickName');
      print('  Phone: $phone');

      if (!await checkInternet()) {
        errorMessage.value = 'No internet connection.';
        return false;
      }
      final firebaseToken = await _getFirebaseAuthToken();
      final currentProfileId = _storage.getProfileId();
      if (currentProfileId == null || currentProfileId.isEmpty) {
        errorMessage.value = 'Profile ID not found.';
        return false;
      }

      print('📤 Fetching current profile...');
      final currentProfileResponse = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(currentProfileId)}'),
        headers: {
          'Accept': 'application/json',
          if (firebaseToken != null)
            'Authorization': 'Bearer $firebaseToken',
        },
      );

      if (currentProfileResponse.statusCode != 200) {
        errorMessage.value = 'Failed to fetch current profile';
        return false;
      }

      final currentData = jsonDecode(currentProfileResponse.body);
      final currentProfileData = currentData['data'] ?? currentData;
      print('✅ Current profile fetched');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.updateProfile(currentProfileId)}'),
      );

      request.headers['Accept'] = 'application/json';
      if (firebaseToken != null) {
        request.headers['Authorization'] = 'Bearer $firebaseToken';
      }

      // Text fields - use updated values or current ones
      request.fields['firstName'] = firstName ?? currentProfileData['firstName'] ?? '';
      request.fields['lastName'] = lastName ?? currentProfileData['lastName'] ?? '';
      request.fields['nickName'] = nickName ?? currentProfileData['nickName'] ?? '';
      request.fields['phone'] = phone ?? currentProfileData['phone']?.toString() ?? '';
      
      // Bio - keep existing
      request.fields['bio'] = currentProfileData['bio'] ?? '';
      
      // Birthday - keep existing
      request.fields['birthday'] = currentProfileData['birthday'] ?? '';
      
      // Interest - keep existing
      request.fields['interest'] = currentProfileData['interest'] ?? '';
      
      // Place to Meet - keep existing
      request.fields['placeToMeet'] = currentProfileData['placeToMeet']?.toString() ?? 'false';
      
      // Height - keep existing
      request.fields['height'] = currentProfileData['height'] ?? '';
      
      // Weight - keep existing
      request.fields['weight'] = currentProfileData['weight'] ?? '';
      
      // Selfie - keep existing
      request.fields['selfie'] = currentProfileData['selfie'] ?? '';
      
      // Document - keep existing
      request.fields['document'] = currentProfileData['document'] ?? '';

      // Location - ADD THIS
      request.fields['location'] = currentProfileData['location'] ?? '';

      // Send empty strings to avoid ObjectId errors
      request.fields['gender'] = '';
      request.fields['position'] = '';
      request.fields['sexOrientation'] = '';
      request.fields['looking'] = '';

      // Handle Photos
      bool hasExistingPhotos = false;
      if (currentProfileData['photos'] != null && 
          currentProfileData['photos'] is List && 
          currentProfileData['photos'].isNotEmpty) {
        hasExistingPhotos = true;
        print('📸 Found ${currentProfileData['photos'].length} existing photos');
      }

      if (hasExistingPhotos) {
        request.fields['photos'] = 'string';
      } else {
        request.fields['photos'] = '';
      }

      // Add any new photos if selected
      if (photoPaths.isNotEmpty) {
        for (final path in photoPaths) {
          if (File(path).existsSync()) {
            final extension = path.split('.').last.toLowerCase();
            String mainType = 'image';
            String subType = 'jpeg';

            switch (extension) {
              case 'jpg':
              case 'jpeg':
                mainType = 'image';
                subType = 'jpeg';
                break;
              case 'png':
                mainType = 'image';
                subType = 'png';
                break;
              default:
                mainType = 'image';
                subType = 'jpeg';
            }

            request.files.add(
              await http.MultipartFile.fromPath(
                'photos',
                path,
                contentType: MediaType(mainType, subType),
              ),
            );
            print('📸 Adding new photo: $path');
          }
        }
      }

      print('📤 Request fields: ${request.fields}');
      print('📤 Files: ${request.files.length}');

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        final profileData = data['data'] ?? data;
        
        profile.value = ProfileModel.fromJson(profileData);
        
        if (profileData['phone'] != null) {
          phoneNumber.value = profileData['phone'].toString();
          await _storage.savePhoneNumber(phoneNumber.value);
        }
        
        await _storage.saveProfileData(profileData);
        
        print('✅ Basic info updated successfully');
        return true;
      } else {
        final data = jsonDecode(responseBody);
        errorMessage.value = data['message'] ?? 'Failed to update profile';
        print('❌ ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = _handleError(e);
      print('❌ Error updating basic info: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> fetchMyProfile() async {
    try {
      final storedProfileId = _storage.getProfileId();
      if (storedProfileId == null || storedProfileId.isEmpty) {
        errorMessage.value = 'No profile ID found';
        return false;
      }
      return await fetchProfileById(storedProfileId);
    } catch (e) {
      errorMessage.value = _handleError(e);
      return false;
    }
  }
  // Add to ProfileServiceController
String getLocationAsJson() {
  if (profile.value.location != null && profile.value.location!.isNotEmpty) {
    final parts = profile.value.location!.split(',').map((e) => e.trim()).toList();
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0]);
      final lng = double.tryParse(parts[1]);
      if (lat != null && lng != null) {
        return jsonEncode({
          'type': 'Point',
          'coordinates': [lng, lat]
        });
      }
    }
    return profile.value.location!;
  }
  return jsonEncode({
    'type': 'Point',
    'coordinates': [0, 0]
  });
}

void updateLocationWithCoordinates(double lat, double lng) {
  final locationStr = '$lat,$lng';
  profile.update((val) {
    val?.location = locationStr;
  });
  _autoSave();
  print('📍 Location updated with coordinates: $locationStr');
}

Future<bool> updateProfile() async {
  try {
    isSaving.value = true;
    errorMessage.value = '';

    print('========== UPDATE PROFILE START ==========');

    if (!await checkInternet()) {
      errorMessage.value = 'No internet connection.';
      return false;
    }
    final firebaseToken = await _getFirebaseAuthToken();

    final currentProfileId = _storage.getProfileId();
    if (currentProfileId == null || currentProfileId.isEmpty) {
      errorMessage.value = 'Profile ID not found.';
      return false;
    }

    print('📤 Current Profile ID: $currentProfileId');

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiUrls.baseUrl}${ApiUrls.updateProfile(currentProfileId)}'),
    );

    request.headers['Accept'] = 'application/json';
    if (firebaseToken != null) {
      request.headers['Authorization'] = 'Bearer $firebaseToken';
    }

    // ============================================
    // FIRST - Get current profile data to merge
    // ============================================
    print('📤 Fetching current profile data...');
    final currentProfileResponse = await http.get(
      Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(currentProfileId)}'),
      headers: {
        'Accept': 'application/json',
        if (firebaseToken != null)
          'Authorization': 'Bearer $firebaseToken',
      },
    );

    Map<String, dynamic> currentData = {};
    if (currentProfileResponse.statusCode == 200) {
      final data = jsonDecode(currentProfileResponse.body);
      currentData = data['data'] ?? data;
      print('✅ Current profile data fetched');
    } else {
      print('⚠️ Could not fetch current profile, using existing data');
      currentData = profile.value.toJson();
    }

    // ============================================
    // TEXT FIELDS - Only update fields that are provided
    // ============================================
    
    // First Name
    if (profile.value.firstName != null && profile.value.firstName!.isNotEmpty) {
      request.fields['firstName'] = profile.value.firstName!;
    } else if (currentData['firstName'] != null) {
      request.fields['firstName'] = currentData['firstName'];
    }
    
    // Last Name
    if (profile.value.lastName != null && profile.value.lastName!.isNotEmpty) {
      request.fields['lastName'] = profile.value.lastName!;
    } else if (currentData['lastName'] != null) {
      request.fields['lastName'] = currentData['lastName'];
    }
    
    // Nick Name
    if (profile.value.nickName != null && profile.value.nickName!.isNotEmpty) {
      request.fields['nickName'] = profile.value.nickName!;
    } else if (currentData['nickName'] != null) {
      request.fields['nickName'] = currentData['nickName'];
    }
    
    // Birthday
    if (profile.value.birthday != null && profile.value.birthday!.isNotEmpty) {
      request.fields['birthday'] = profile.value.birthday!;
    } else if (currentData['birthday'] != null) {
      request.fields['birthday'] = currentData['birthday'];
    }
    
    // Phone
    if (profile.value.phone != null && profile.value.phone!.isNotEmpty) {
      request.fields['phone'] = profile.value.phone!;
    } else if (phoneNumber.value.isNotEmpty) {
      request.fields['phone'] = phoneNumber.value;
    } else if (currentData['phone'] != null) {
      request.fields['phone'] = currentData['phone'].toString();
    }

    // ============================================
    // LOCATION - Must be valid JSON
    // ============================================
    if (profile.value.location != null && profile.value.location!.isNotEmpty) {
      final locationStr = profile.value.location!;
      
      // Check if it's already a JSON string
      if (locationStr.startsWith('{') && locationStr.contains('"type"')) {
        // Already JSON, use as is
        request.fields['location'] = locationStr;
        print('📍 Location (JSON): $locationStr');
      } else {
        // Try to parse as coordinates (lat,lng)
        final locationParts = locationStr.split(',').map((e) => e.trim()).toList();
        
        if (locationParts.length == 2) {
          final lat = double.tryParse(locationParts[0]);
          final lng = double.tryParse(locationParts[1]);
          
          if (lat != null && lng != null) {
            final locationJson = {
              'type': 'Point',
              'coordinates': [lng, lat]
            };
            request.fields['location'] = jsonEncode(locationJson);
            print('📍 Location (GeoJSON): ${request.fields['location']}');
          } else {
            // Use default if parse fails
            final locationJson = {
              'type': 'Point',
              'coordinates': [73.9494118, 18.5527841]
            };
            request.fields['location'] = jsonEncode(locationJson);
            print('📍 Location (Default): ${request.fields['location']}');
          }
        } else {
          // Not in lat,lng format, use default
          final locationJson = {
            'type': 'Point',
            'coordinates': [73.9494118, 18.5527841]
          };
          request.fields['location'] = jsonEncode(locationJson);
          print('📍 Location (Default): ${request.fields['location']}');
        }
      }
    } else if (currentData['location'] != null && currentData['location'] is String) {
      // Use existing location if available
      final existingLocation = currentData['location'];
      if (existingLocation.startsWith('{') && existingLocation.contains('"type"')) {
        request.fields['location'] = existingLocation;
      } else {
        final locationJson = {
          'type': 'Point',
          'coordinates': [73.9494118, 18.5527841]
        };
        request.fields['location'] = jsonEncode(locationJson);
      }
      print('📍 Using existing location: ${request.fields['location']}');
    } else {
      // Default location
      final locationJson = {
        'type': 'Point',
        'coordinates': [73.9494118, 18.5527841]
      };
      request.fields['location'] = jsonEncode(locationJson);
      print('📍 Using default location: ${request.fields['location']}');
    }

    // ============================================
    // ENUM FIELDS - Only send if valid
    // ============================================
    
    // Gender - Only send if it's a valid ObjectId-like string
    if (profile.value.gender != null && 
        profile.value.gender!.isNotEmpty && 
        profile.value.gender!.length >= 24) { // ObjectId is 24 characters
      request.fields['gender'] = profile.value.gender!;
      print('✅ Gender: ${profile.value.gender}');
    } else if (currentData['gender'] != null && 
               currentData['gender'] is String && 
               currentData['gender'].length >= 24) {
      request.fields['gender'] = currentData['gender'];
      print('✅ Using existing gender: ${currentData['gender']}');
    } else {
      // Fetch valid gender ID
      final genders = await fetchGenders();
      if (genders.isNotEmpty) {
        final man = genders.firstWhere(
          (g) => g.gender == 'Man',
          orElse: () => genders.first
        );
        if (man.id.isNotEmpty) {
          request.fields['gender'] = man.id;
          print('✅ Using fetched gender: ${man.id} (${man.gender})');
        }
      }
    }
    
    // Position
    if (profile.value.position != null && 
        profile.value.position!.isNotEmpty && 
        profile.value.position!.length >= 24) {
      request.fields['position'] = profile.value.position!;
      print('✅ Position: ${profile.value.position}');
    } else if (currentData['position'] != null && 
               currentData['position'] is String && 
               currentData['position'].length >= 24) {
      request.fields['position'] = currentData['position'];
      print('✅ Using existing position: ${currentData['position']}');
    } else {
      final positions = await fetchPositions();
      if (positions.isNotEmpty) {
        final pos = positions.firstWhere(
          (p) => p.title == 'Versatile',
          orElse: () => positions.first
        );
        if (pos.id.isNotEmpty) {
          request.fields['position'] = pos.id;
          print('✅ Using fetched position: ${pos.id} (${pos.title})');
        }
      }
    }
    
    // Sexual Orientation
    if (profile.value.sexualOrientation != null && 
        profile.value.sexualOrientation!.isNotEmpty && 
        profile.value.sexualOrientation!.length >= 24) {
      request.fields['sexOrientation'] = profile.value.sexualOrientation!;
      print('✅ SexOrientation: ${profile.value.sexualOrientation}');
    } else if (currentData['sexOrientation'] != null && 
               currentData['sexOrientation'] is String && 
               currentData['sexOrientation'].length >= 24) {
      request.fields['sexOrientation'] = currentData['sexOrientation'];
      print('✅ Using existing sexOrientation: ${currentData['sexOrientation']}');
    } else {
      final orientations = await fetchSexualOrientations();
      if (orientations.isNotEmpty) {
        final ori = orientations.firstWhere(
          (o) => o.title == 'Straight',
          orElse: () => orientations.first
        );
        if (ori.id.isNotEmpty) {
          request.fields['sexOrientation'] = ori.id;
          print('✅ Using fetched sexOrientation: ${ori.id} (${ori.title})');
        }
      }
    }
    
    // Looking For
    if (profile.value.lookingFor != null && 
        profile.value.lookingFor!.isNotEmpty && 
        profile.value.lookingFor!.length >= 24) {
      request.fields['looking'] = profile.value.lookingFor!;
      print('✅ Looking: ${profile.value.lookingFor}');
    } else if (currentData['looking'] != null && 
               currentData['looking'] is String && 
               currentData['looking'].length >= 24) {
      request.fields['looking'] = currentData['looking'];
      print('✅ Using existing looking: ${currentData['looking']}');
    } else if (currentData['lookingFor'] != null && 
               currentData['lookingFor'] is String && 
               currentData['lookingFor'].length >= 24) {
      request.fields['looking'] = currentData['lookingFor'];
      print('✅ Using existing lookingFor: ${currentData['lookingFor']}');
    } else {
      final lookingOptions = await fetchLookingFor();
      if (lookingOptions.isNotEmpty) {
        final look = lookingOptions.firstWhere(
          (l) => l.title == 'New Friends',
          orElse: () => lookingOptions.first
        );
        if (look.id.isNotEmpty) {
          request.fields['looking'] = look.id;
          print('✅ Using fetched looking: ${look.id} (${look.title})');
        }
      }
    }

    // ============================================
    // OTHER FIELDS
    // ============================================
    
    // Bio
    if (profile.value.bio != null && profile.value.bio!.isNotEmpty) {
      request.fields['bio'] = profile.value.bio!;
    } else if (currentData['bio'] != null) {
      request.fields['bio'] = currentData['bio'];
    }
    
    // Interest
    if (profile.value.interestedIn != null && profile.value.interestedIn!.isNotEmpty) {
      request.fields['interest'] = profile.value.interestedIn!;
    } else if (currentData['interest'] != null) {
      request.fields['interest'] = currentData['interest'];
    }
    
    // Place to Meet
    if (profile.value.meetPlace != null && profile.value.meetPlace!.isNotEmpty) {
      request.fields['placeToMeet'] = profile.value.meetPlace!;
    } else if (currentData['placeToMeet'] != null) {
      request.fields['placeToMeet'] = currentData['placeToMeet'].toString();
    }
    
    // Show Gender
    if (profile.value.showGender != null) {
      request.fields['showGender'] = profile.value.showGender.toString();
    } else if (currentData['showGender'] != null) {
      request.fields['showGender'] = currentData['showGender'].toString();
    }
    
    // Show Orientation
    if (profile.value.showOrientation != null) {
      request.fields['showOrientation'] = profile.value.showOrientation.toString();
    } else if (currentData['showOrientation'] != null) {
      request.fields['showOrientation'] = currentData['showOrientation'].toString();
    }
   
  
    // Height
    if (profile.value.height != null && profile.value.height!.isNotEmpty) {
      request.fields['height'] = profile.value.height!;
    } else if (currentData['height'] != null) {
      request.fields['height'] = currentData['height'].toString();
    }
    
    // Weight
    if (profile.value.weight != null && profile.value.weight!.isNotEmpty) {
      request.fields['weight'] = profile.value.weight!;
    } else if (currentData['weight'] != null) {
      request.fields['weight'] = currentData['weight'].toString();
    }

    // ============================================
    // PHOTOS - Only add new ones
    // ============================================
    if (photoPaths.isNotEmpty) {
      for (final path in photoPaths) {
        if (File(path).existsSync()) {
          final extension = path.split('.').last.toLowerCase();
          String mainType = 'image';
          String subType = 'jpeg';

          switch (extension) {
            case 'jpg':
            case 'jpeg':
              mainType = 'image';
              subType = 'jpeg';
              break;
            case 'png':
              mainType = 'image';
              subType = 'png';
              break;
            default:
              mainType = 'image';
              subType = 'jpeg';
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              'photos',
              path,
              contentType: MediaType(mainType, subType),
            ),
          );
          print('📸 Adding photo: $path');
        }
      }
    }

    // ============================================
    // DEBUG LOGGING
    // ============================================
    print('========== REQUEST DETAILS ==========');
    print('📤 URL: ${ApiUrls.baseUrl}${ApiUrls.updateProfile(currentProfileId)}');
    print('📤 Fields sent:');
    request.fields.forEach((key, value) {
      // Truncate long values for logging
      final displayValue = value.length > 100 ? '${value.substring(0, 100)}...' : value;
      print('   $key: $displayValue');
    });
    print('📤 Files: ${request.files.length}');

    // ============================================
    // SEND REQUEST
    // ============================================
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(responseBody);
      final profileData = data['data'] ?? data;
      
      // Update local profile
      profile.value = ProfileModel.fromJson(profileData);
      
      if (profileData['phone'] != null) {
        phoneNumber.value = profileData['phone'].toString();
      }
      
      await _storage.saveProfileData(profileData);
      
      // Clear photo paths after successful update
      photoPaths.clear();
      
      print('✅ Profile updated successfully');
      return true;
    } else {
      try {
        final data = jsonDecode(responseBody);
        errorMessage.value = data['message'] ?? 'Failed to update profile';
      } catch (e) {
        errorMessage.value = 'Server error: $responseBody';
      }
      print('❌ ${errorMessage.value}');
      return false;
    }
  } catch (e) {
    errorMessage.value = _handleError(e);
    print('❌ Error updating profile: $e');
    return false;
  } finally {
    isSaving.value = false;
  }
}
 
  Future<bool> deleteProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!await checkInternet()) {
        errorMessage.value = 'No internet connection.';
        return false;
      }
      final firebaseToken = await _getFirebaseAuthToken();

      final currentProfileId = _storage.getProfileId();
      if (currentProfileId == null || currentProfileId.isEmpty) {
        errorMessage.value = 'Profile ID not found.';
        return false;
      }

      final response = await _client
          .delete(
            Uri.parse('${ApiUrls.baseUrl}${ApiUrls.deleteProfile(currentProfileId)}'),
            headers: {
              'Accept': 'application/json',
              if (firebaseToken != null)
                'Authorization': 'Bearer $firebaseToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        resetProfile();
        await _storage.clearAll();
        print('✅ Profile deleted successfully');
        return true;
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to delete profile';
        return false;
      }
    } catch (e) {
      errorMessage.value = _handleError(e);
      print('❌ Error deleting profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // PROFILE UPDATE FUNCTIONS (LOCAL)
  // ============================================================

  void updateFirstName(String? firstName) {
    if (firstName != null && firstName.isNotEmpty) {
      profile.update((val) {
        val?.firstName = firstName;
      });
      _autoSave();
    }
  }

  void updateLastName(String? lastName) {
    if (lastName != null && lastName.isNotEmpty) {
      profile.update((val) {
        val?.lastName = lastName;
      });
      _autoSave();
    }
  }

  void updateNickName(String? nickName) {
    if (nickName != null && nickName.isNotEmpty) {
      profile.update((val) {
        val?.nickName = nickName;
      });
      _autoSave();
    }
  }

  void updateBirthday(String? birthday) {
    if (birthday != null) {
      profile.update((val) {
        val?.birthday = birthday;
      });
      _autoSave();
    }
  }

  void updateGender(String? gender) {
    if (gender != null) {
      profile.update((val) {
        val?.gender = gender;
      });
      _autoSave();
    }
  }
  void updateHeight(String? height) {
  if (height != null && height.isNotEmpty) {
    profile.update((val) {
      val?.height = height;
    });
    _autoSave();
    print('✅ Height updated: $height');
  }
}
void updateWeight(String? weight) {
  if (weight != null && weight.isNotEmpty) {
    profile.update((val) {
      val?.weight = weight;
    });
    _autoSave();
    print('✅ Weight updated: $weight');
  }
}
  void toggleShowGender(bool show) {
    profile.update((val) {
      val?.showGender = show;
    });
    _autoSave();
  }

  void updatePosition(String? position) {
    if (position != null) {
      profile.update((val) {
        val?.position = position;
      });
      _autoSave();
    }
  }

  void updateSexualOrientation(String? orientation) {
    if (orientation != null) {
      profile.update((val) {
        val?.sexualOrientation = orientation;
      });
      _autoSave();
    }
  }

  void toggleShowOrientation(bool show) {
    profile.update((val) {
      val?.showOrientation = show;
    });
    _autoSave();
  }

  void updateInterestedIn(String? interested) {
    if (interested != null) {
      profile.update((val) {
        val?.interestedIn = interested;
      });
      _autoSave();
    }
  }

  void updateLookingFor(String? looking) {
    if (looking != null) {
      profile.update((val) {
        val?.lookingFor = looking;
      });
      _autoSave();
    }
  }

  void updateMeetPlace(String? meetPlace) {
    if (meetPlace != null) {
      profile.update((val) {
        val?.meetPlace = meetPlace;
      });
      _autoSave();
    }
  }

  void updateLookingForId(String? id) {
    if (id != null && id.isNotEmpty) {
      profile.update((val) {
        val?.lookingFor = id;
      });
      _autoSave();
      print('✅ Looking For ID updated: $id');
    }
  }

  void updateBio(String? bio) {
    if (bio != null) {
      profile.update((val) {
        val?.bio = bio;
      });
      _autoSave();
    }
  }

  void updatePhone(String? phone) {
    if (phone != null && phone.isNotEmpty) {
      profile.update((val) {
        val?.phone = phone;
      });
      phoneNumber.value = phone;
      _autoSave();
      print('✅ Phone updated: $phone');
    }
  }

  // ============================================================
  // BULK UPDATES
  // ============================================================

  void updateProfileFields(Map<String, dynamic> fields) {
    profile.update((val) {
      fields.forEach((key, value) {
        switch (key) {
          case 'firstName':
            val?.firstName = value;
            break;
          case 'lastName':
            val?.lastName = value;
            break;
          case 'nickName':
            val?.nickName = value;
            break;
          case 'photos':
            val?.photos = value;
            break;
          case 'birthday':
            val?.birthday = value;
            break;
          case 'gender':
            val?.gender = value;
            break;
          case 'position':
            val?.position = value;
            break;
          case 'sexualOrientation':
            val?.sexualOrientation = value;
            break;
          case 'lookingFor':
            val?.lookingFor = value;
            break;
          case 'bio':
            val?.bio = value;
            break;
          case 'phone':
            val?.phone = value;
            phoneNumber.value = value;
            break;
          case 'location':
            val?.location = value;
            break;
        }
      });
    });
    _autoSave();
  }

  // ============================================================
  // VALIDATION FUNCTIONS
  // ============================================================

  bool _validateProfile() {
    final data = profile.value;

    if (data.firstName == null || data.firstName!.isEmpty) {
      errorMessage.value = 'First name is required';
      return false;
    }

    if (data.lastName == null || data.lastName!.isEmpty) {
      errorMessage.value = 'Last name is required';
      return false;
    }

    if (photoPaths.isEmpty && (data.photos == null || data.photos!.isEmpty)) {
      errorMessage.value = 'At least one photo is required';
      return false;
    }

    if (data.birthday == null) {
      errorMessage.value = 'Birthday is required';
      return false;
    }

    if (data.gender == null) {
      errorMessage.value = 'Gender is required';
      return false;
    }

    if (data.position == null) {
      errorMessage.value = 'Position is required';
      return false;
    }

    if (data.bio == null || data.bio!.isEmpty || data.bio!.length < 10) {
      errorMessage.value = 'Bio must be at least 10 characters';
      return false;
    }

    return true;
  }

  String getFullName() {
    final data = profile.value;
    if (data.firstName != null && data.lastName != null) {
      return '${data.firstName} ${data.lastName}';
    }
    return data.firstName ?? data.nickName ?? 'User';
  }

  bool get isProfileComplete {
    final data = profile.value;
    return data.firstName != null &&
        data.lastName != null &&
        data.photos != null &&
        data.photos!.isNotEmpty &&
        data.birthday != null &&
        data.gender != null &&
        data.position != null &&
        data.bio != null &&
        data.bio!.isNotEmpty;
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _handleError(dynamic error) {
    if (error is http.ClientException) {
      return 'Network error: ${error.message}';
    } else if (error is FormatException) {
      return 'Invalid response format';
    } else {
      return error.toString();
    }
  }

  // ============================================================
  // AUTO SAVE
  // ============================================================

  void _autoSave() {
    if (isProfileCreated.value) {
      // Auto-save logic
    }
  }

  // ============================================================
  // LOAD FROM STORAGE
  // ============================================================

  Future<void> loadSavedProfile() async {
    try {
      final token = _storage.getToken();
      final profileId = _storage.getProfileId();
      final phoneNumber = _storage.getPhoneNumber();
      final profileData = _storage.getProfileData();
      final isCreated = _storage.isProfileCreated();

      print('========== LOADING SAVED PROFILE ==========');
      print('Token: ${token != null ? 'Present' : 'Not present'}');
      print('Profile ID: $profileId');
      print('Phone: $phoneNumber');
      print('Profile Created: $isCreated');

      if (isCreated && token != null && profileId != null) {
        this.profileId = profileId;
        
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          this.phoneNumber.value = phoneNumber;
        }
        
        isProfileCreated.value = true;
        
        if (profileData != null) {
          profile.value = ProfileModel.fromJson(profileData);
          print('✅ Loaded profile from storage: ${profile.value.firstName} ${profile.value.lastName}');
        }
        
        print('✅ Loaded saved profile data successfully');
      } else {
        print('ℹ️ No saved profile found or incomplete data');
      }
    } catch (e) {
      print('❌ Error loading saved profile: $e');
    }
  }

  // ============================================================
  // RESET FUNCTIONS
  // ============================================================

  void resetProfile() {
    profile.value = ProfileModel();
    isProfileCreated.value = false;
    profileId = null;
    photoPaths.clear();
    errorMessage.value = '';
    phoneNumber.value = '';
    likedProfilesList.clear();
    profilesList.clear();
    print('🔄 Profile reset');
  }

  void clearError() {
    errorMessage.value = '';
  }

  // ============================================================
  // DEBUG FUNCTIONS
  // ============================================================

  void debugPrintProfile() {
    final data = profile.value;
    print('========== PROFILE DATA ==========');
    print('ID: $profileId');
    print('First Name: ${data.firstName}');
    print('Last Name: ${data.lastName}');
    print('Nick Name: ${data.nickName}');
    print('Photos: ${data.photos}');
    print('Photo Paths: $photoPaths');
    print('Birthday: ${data.birthday}');
    print('Gender: ${data.gender}');
    print('Show Gender: ${data.showGender}');
    print('Position: ${data.position}');
    print('Sexual Orientation: ${data.sexualOrientation}');
    print('Show Orientation: ${data.showOrientation}');
    print('Interested In: ${data.interestedIn}');
    print('Looking For: ${data.lookingFor}');
    print('Meet Place: ${data.meetPlace}');
    print('Bio: ${data.bio}');
    print('Phone: ${phoneNumber.value}');
    print('Location: ${data.location}');
    print('Is Complete: ${isProfileComplete}');
    print('====================================');
  }

  void debugPrintLikedProfiles() {
    print('========== LIKED PROFILES ==========');
    print('Total liked profiles: ${likedProfilesList.length}');
    for (var profile in likedProfilesList) {
      print('  - ${profile.firstName} ${profile.lastName} (${profile.id})');
    }
    print('====================================');
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}