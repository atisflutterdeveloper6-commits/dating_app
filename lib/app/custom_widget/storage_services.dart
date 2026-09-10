// lib/app/services/storage_service.dart
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final GetStorage _storage = GetStorage();

  // ============================================================
  // STORAGE KEYS
  // ============================================================
  
  // Auth/LocalStorage Keys
  static const String keyToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token'; // ✅ ADDED
  static const String keyTokenExpiry = 'token_expiry'; // ✅ ADDED
  static const String keyProfileId = 'profile_id';
  static const String keyPhoneNumber = 'phone_number';
  static const String keyProfileData = 'profile_data';
  static const String keyIsProfileCreated = 'is_profile_created';
  static const String keyUserId = 'user_id';
 static const String keyRazorpayKeyId = 'razorpay_key_id'; 
  // Login specific keys
  static const String keyLoginToken = 'login_token';
  static const String keyLoginData = 'login_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyLoginTime = 'login_time';
  static const String keyAppName = 'app_name';
  // User preferences
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  // Onboarding key
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';

  // ============================================================
  // TOKEN METHODS (Legacy/Backward Compatibility)
  // ============================================================

  Future<void> saveToken(String token) async {
    await _storage.write(keyToken, token);
    print('✅ Token saved to storage');
  }
  Future<void> saveAppName(String name) async {
    await _storage.write(keyAppName, name);
    print('✅ App name saved to storage: $name');
  }
  String getAppName() {
    return _storage.read<String>(keyAppName) ?? 'Vibely';
  }
  String? getToken() {
    return _storage.read<String>(keyToken);
  }

  bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> removeToken() async {
    await _storage.remove(keyToken);
    print('🔄 Token removed from storage');
  }
  
  Future<void> saveRazorpayKeyId(String keyId) async {
    await _storage.write(keyRazorpayKeyId, keyId);
    print('✅ Razorpay keyId saved to storage');
  }

  String? getRazorpayKeyId() {
    return _storage.read<String>(keyRazorpayKeyId);
  }

  Future<void> removeRazorpayKeyId() async {
    await _storage.remove(keyRazorpayKeyId);
  }
  // ============================================================
  // ✅ REFRESH TOKEN METHODS (NEW)
  // ============================================================

  /// Save refresh token
  Future<void> setRefreshToken(String token) async {
    await _storage.write(keyRefreshToken, token);
    print('✅ Refresh token saved to storage');
  }

  /// Get refresh token
  String? getRefreshToken() {
    return _storage.read<String>(keyRefreshToken);
  }

  /// Check if refresh token exists
  bool hasRefreshToken() {
    final token = getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  /// Remove refresh token
  Future<void> clearRefreshToken() async {
    await _storage.remove(keyRefreshToken);
    print('🔄 Refresh token removed from storage');
  }

  // ============================================================
  // ✅ TOKEN EXPIRY METHODS (NEW)
  // ============================================================

  /// Save token expiry time
  Future<void> setTokenExpiry(DateTime expiryTime) async {
    await _storage.write(keyTokenExpiry, expiryTime.toIso8601String());
    print('✅ Token expiry saved: $expiryTime');
  }

  /// Get token expiry time
  DateTime? getTokenExpiry() {
    final expiryStr = _storage.read<String>(keyTokenExpiry);
    if (expiryStr != null) {
      return DateTime.tryParse(expiryStr);
    }
    return null;
  }

  /// Check if token is expired
  bool isTokenExpired() {
    final expiry = getTokenExpiry();
    if (expiry == null) return true;
    // Consider expired if less than 5 minutes remaining
    return expiry.difference(DateTime.now()).inMinutes < 5;
  }

  /// Remove token expiry
  Future<void> clearTokenExpiry() async {
    await _storage.remove(keyTokenExpiry);
    print('🔄 Token expiry removed from storage');
  }

  // ============================================================
  // ✅ AUTH TOKEN METHODS (Primary - Unified)
  // ============================================================

  /// Set auth token (saves to both legacy and new storage)
  Future<void> setAuthToken(String token) async {
    await saveToken(token);
    await saveLoginToken(token);
    print('✅ Auth token saved');
  }

  /// Get auth token (tries all sources)
  String? getAuthToken() {
    // Try login token first
    String? token = getLoginToken();
    if (token != null && token.isNotEmpty) {
      return token;
    }
    // Fallback to legacy token
    return getToken();
  }

  /// Check if auth token exists and is valid
  bool hasValidAuthToken() {
    final token = getAuthToken();
    return token != null && token.isNotEmpty && !isTokenExpired();
  }

  /// Clear all auth tokens
  Future<void> clearAuthTokens() async {
    await removeToken();
    await removeLoginToken();
    await clearRefreshToken();
    await clearTokenExpiry();
    print('🔄 All auth tokens cleared');
  }

  // ============================================================
  // LOGIN TOKEN METHODS
  // ============================================================

  Future<void> saveLoginToken(String token) async {
    await _storage.write(keyLoginToken, token);
    await _storage.write(keyLoginTime, DateTime.now().toIso8601String());
    print('✅ Login token saved to storage');
  }

  String? getLoginToken() {
    return _storage.read<String>(keyLoginToken);
  }

  bool hasLoginToken() {
    final token = getLoginToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> removeLoginToken() async {
    await _storage.remove(keyLoginToken);
    await _storage.remove(keyLoginTime);
    print('🔄 Login token removed from storage');
  }

  // ============================================================
  // LOGIN DATA METHODS
  // ============================================================

  Future<void> saveLoginData(Map<String, dynamic> loginData) async {
    await _storage.write(keyLoginData, loginData);
    print('✅ Login data saved to storage');
  }

  Map<String, dynamic>? getLoginData() {
    return _storage.read<Map<String, dynamic>>(keyLoginData);
  }

  Future<void> removeLoginData() async {
    await _storage.remove(keyLoginData);
    print('🔄 Login data removed from storage');
  }

  // ============================================================
  // LOGIN STATUS METHODS
  // ============================================================

  Future<void> setLoggedIn(bool status) async {
    await _storage.write(keyIsLoggedIn, status);
    if (status) {
      await _storage.write(keyLoginTime, DateTime.now().toIso8601String());
    }
    print('✅ Login status saved: $status');
  }

  bool isLoggedIn() {
    return _storage.read<bool>(keyIsLoggedIn) ?? false;
  }

  DateTime? getLoginTime() {
    final timeStr = _storage.read<String>(keyLoginTime);
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  // ============================================================
  // PROFILE ID METHODS
  // ============================================================

  Future<void> saveProfileId(String profileId) async {
    await _storage.write(keyProfileId, profileId);
    print('✅ Profile ID saved to storage: $profileId');
  }

  String? getProfileId() {
    return _storage.read<String>(keyProfileId);
  }

  String getProfileIdOrThrow() {
    final id = getProfileId();
    if (id == null || id.isEmpty) {
      throw Exception('Profile ID not found in storage');
    }
    return id;
  }

  bool hasProfileId() {
    final id = getProfileId();
    return id != null && id.isNotEmpty;
  }

  Future<void> removeProfileId() async {
    await _storage.remove(keyProfileId);
    print('🔄 Profile ID removed from storage');
  }

  // ============================================================
  // PHONE NUMBER METHODS
  // ============================================================

  Future<void> savePhoneNumber(String phone) async {
    await _storage.write(keyPhoneNumber, phone);
    print('✅ Phone number saved to storage: $phone');
  }

  String? getPhoneNumber() {
    return _storage.read<String>(keyPhoneNumber);
  }

  bool hasPhoneNumber() {
    final phone = getPhoneNumber();
    return phone != null && phone.isNotEmpty;
  }

  Future<void> removePhoneNumber() async {
    await _storage.remove(keyPhoneNumber);
    print('🔄 Phone number removed from storage');
  }

  // ============================================================
  // PROFILE DATA METHODS
  // ============================================================

  Future<void> saveProfileData(Map<String, dynamic> profileData) async {
    await _storage.write(keyProfileData, profileData);
    print('✅ Profile data saved to storage');
  }

  Map<String, dynamic>? getProfileData() {
    return _storage.read<Map<String, dynamic>>(keyProfileData);
  }

  Future<void> removeProfileData() async {
    await _storage.remove(keyProfileData);
    print('🔄 Profile data removed from storage');
  }

  // ============================================================
  // PROFILE CREATION STATUS METHODS
  // ============================================================

  Future<void> setProfileCreated(bool status) async {
    await _storage.write(keyIsProfileCreated, status);
    print('✅ Profile creation status saved: $status');
  }

  bool isProfileCreated() {
    return _storage.read<bool>(keyIsProfileCreated) ?? false;
  }

  Future<void> removeProfileCreated() async {
    await _storage.remove(keyIsProfileCreated);
    print('🔄 Profile creation status removed');
  }

  // ============================================================
  // USER ID METHODS
  // ============================================================

  Future<void> saveUserId(String userId) async {
    await _storage.write(keyUserId, userId);
    print('✅ User ID saved to storage: $userId');
  }

  String? getUserId() {
    return _storage.read<String>(keyUserId);
  }

  Future<void> removeUserId() async {
    await _storage.remove(keyUserId);
    print('🔄 User ID removed from storage');
  }

  // ============================================================
  // USER PREFERENCES
  // ============================================================

  Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(keyThemeMode, themeMode);
    print('✅ Theme mode saved: $themeMode');
  }

  String? getThemeMode() {
    return _storage.read<String>(keyThemeMode);
  }

  Future<void> saveLanguage(String language) async {
    await _storage.write(keyLanguage, language);
    print('✅ Language saved: $language');
  }

  String? getLanguage() {
    return _storage.read<String>(keyLanguage);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.write(keyNotificationsEnabled, enabled);
    print('✅ Notifications enabled: $enabled');
  }

  bool getNotificationsEnabled() {
    return _storage.read<bool>(keyNotificationsEnabled) ?? true;
  }

  // ============================================================
  // ONBOARDING METHODS
  // ============================================================

  /// Check if user has seen onboarding
  bool hasSeenOnboarding() {
    return _storage.read<bool>(keyHasSeenOnboarding) ?? false;
  }

  /// Mark onboarding as seen
  Future<void> setOnboardingSeen() async {
    await _storage.write(keyHasSeenOnboarding, true);
    print('✅ Onboarding marked as seen');
  }

  /// Reset onboarding status
  Future<void> resetOnboardingStatus() async {
    await _storage.remove(keyHasSeenOnboarding);
    print('🔄 Onboarding status reset');
  }

  // ============================================================
  // GENERIC DATA METHODS (For any custom key)
  // ============================================================

  /// Save any data with custom key
  Future<void> saveData(String key, dynamic value) async {
    await _storage.write(key, value);
    print('✅ Data saved for key: $key');
  }

  /// Get any data with custom key
  dynamic getData(String key) {
    return _storage.read(key);
  }

  /// Check if key exists
  bool hasKey(String key) {
    return _storage.hasData(key);
  }

  /// Remove specific key
  Future<void> removeKey(String key) async {
    await _storage.remove(key);
    print('🔄 Key removed: $key');
  }

  /// Get all keys
  List<String> getKeys() {
    return _storage.getKeys().toList();
  }

  /// Save boolean value
  Future<void> saveBool(String key, bool value) async {
    await _storage.write(key, value);
  }

  /// Get boolean value
  bool getBool(String key, {bool defaultValue = false}) {
    return _storage.read<bool>(key) ?? defaultValue;
  }

  /// Save string value
  Future<void> saveString(String key, String value) async {
    await _storage.write(key, value);
  }

  /// Get string value
  String getString(String key, {String defaultValue = ''}) {
    return _storage.read<String>(key) ?? defaultValue;
  }

  /// Save int value
  Future<void> saveInt(String key, int value) async {
    await _storage.write(key, value);
  }

  /// Get int value
  int getInt(String key, {int defaultValue = 0}) {
    return _storage.read<int>(key) ?? defaultValue;
  }

  /// Save map data
  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await _storage.write(key, value);
  }

  /// Get map data
  Map<String, dynamic>? getMap(String key) {
    return _storage.read<Map<String, dynamic>>(key);
  }

  /// Save list data
  Future<void> saveList(String key, List<dynamic> value) async {
    await _storage.write(key, value);
  }

  /// Get list data
  List<dynamic>? getList(String key) {
    return _storage.read<List<dynamic>>(key);
  }

  // ============================================================
  // AUTH CHECK METHODS
  // ============================================================

  /// Check if user is authenticated (has login token)
  bool isAuthenticated() {
    return hasLoginToken() && isLoggedIn();
  }

  /// Check if user has complete profile
  bool hasCompleteProfile() {
    return isAuthenticated() && isProfileCreated() && hasProfileId();
  }

  /// Check if user is logged in (has token and profile)
  bool isLoggedInWithProfile() {
    return isAuthenticated() && hasProfileId();
  }

  /// Check if session is expired (e.g., after 7 days)
  bool isSessionExpired({int maxAgeInDays = 7}) {
    if (!isLoggedIn()) return true;
    
    final loginTime = getLoginTime();
    if (loginTime == null) return true;
    
    final difference = DateTime.now().difference(loginTime);
    return difference.inDays > maxAgeInDays;
  }

  /// Get user status for navigation
  String getUserStatus() {
    if (!hasSeenOnboarding()) {
      return 'onboarding';
    } else if (isLoggedIn() && isProfileCreated() && hasLoginToken()) {
      return 'dashboard';
    } else if (isLoggedIn() && !isProfileCreated()) {
      return 'create_profile';
    } else {
      return 'login';
    }
  }
  bool isSessionUsable() {
    if (!isLoggedIn()) return false;
    if (!hasLoginToken()) return false;
    if (!hasProfileId()) return false;
    // ✅ Access token expired hone se session invalid nahi hota — refresh se recover ho sakta hai
    return true;
  }
  /// Check if session is valid
  bool isValidSession() {
    // Check if user is logged in
    if (!isLoggedIn()) return false;
    
    // Check if has login token
    if (!hasLoginToken()) return false;
    
    // Check if has profile ID
    if (!hasProfileId()) return false;
    
    // Check if token is not expired
    if (isTokenExpired()) return false;
    
    // Check if auth token exists
    final token = getAuthToken();
    if (token == null || token.isEmpty) return false;
    
    return true;
  }

  // ============================================================
  // GET ALL DATA (Debugging)
  // ============================================================

  Map<String, dynamic> getAllData() {
    return {
      'loginToken': getLoginToken(),
      'refreshToken': getRefreshToken(),
      'tokenExpiry': getTokenExpiry()?.toString(),
      'loginData': getLoginData(),
      'isLoggedIn': isLoggedIn(),
      'loginTime': getLoginTime()?.toString(),
      'token': getToken(),
      'profileId': getProfileId(),
      'phoneNumber': getPhoneNumber(),
      'profileData': getProfileData(),
      'isProfileCreated': isProfileCreated(),
      'userId': getUserId(),
      'themeMode': getThemeMode(),
      'language': getLanguage(),
      'notificationsEnabled': getNotificationsEnabled(),
      'hasSeenOnboarding': hasSeenOnboarding(),
      'isTokenExpired': isTokenExpired(),
      'hasValidAuthToken': hasValidAuthToken(),
    };
  }

  // ============================================================
  // CLEAR METHODS
  // ============================================================

  /// Clear all storage data (logout)
  Future<void> clearAll() async {
    await _storage.remove(keyLoginToken);
    await _storage.remove(keyLoginData);
    await _storage.remove(keyIsLoggedIn);
    await _storage.remove(keyLoginTime);
    await _storage.remove(keyToken);
    await _storage.remove(keyRefreshToken);
    await _storage.remove(keyTokenExpiry);
    await _storage.remove(keyProfileId);
    await _storage.remove(keyPhoneNumber);
    await _storage.remove(keyProfileData);
    await _storage.remove(keyIsProfileCreated);
    await _storage.remove(keyUserId);
    // Keep preferences and onboarding status
    // await _storage.remove(keyThemeMode);
    // await _storage.remove(keyLanguage);
    // await _storage.remove(keyNotificationsEnabled);
    // await _storage.remove(keyHasSeenOnboarding);
    print('🔄 All storage cleared (preferences kept)');
  }

  /// Clear all storage data including preferences (full logout)
  Future<void> clearAllIncludingPreferences() async {
    await _storage.remove(keyLoginToken);
    await _storage.remove(keyLoginData);
    await _storage.remove(keyIsLoggedIn);
    await _storage.remove(keyLoginTime);
    await _storage.remove(keyToken);
    await _storage.remove(keyRefreshToken);
    await _storage.remove(keyTokenExpiry);
    await _storage.remove(keyProfileId);
    await _storage.remove(keyPhoneNumber);
    await _storage.remove(keyProfileData);
    await _storage.remove(keyIsProfileCreated);
    await _storage.remove(keyUserId);
    await _storage.remove(keyThemeMode);
    await _storage.remove(keyLanguage);
    await _storage.remove(keyNotificationsEnabled);
    // await _storage.remove(keyHasSeenOnboarding);
    print('🔄 All storage cleared including preferences');
  }

  /// Clear only authentication data (keep profile data if needed)
  Future<void> clearAuthData() async {
    await _storage.remove(keyLoginToken);
    await _storage.remove(keyLoginData);
    await _storage.remove(keyIsLoggedIn);
    await _storage.remove(keyLoginTime);
    await _storage.remove(keyToken);
    await _storage.remove(keyRefreshToken);
    await _storage.remove(keyTokenExpiry);
    await _storage.remove(keyUserId);
    print('🔄 Auth data cleared');
  }

  /// Clear only login data
  Future<void> clearLoginData() async {
    await _storage.remove(keyLoginToken);
    await _storage.remove(keyLoginData);
    await _storage.remove(keyIsLoggedIn);
    await _storage.remove(keyLoginTime);
    await _storage.remove(keyRefreshToken);
    await _storage.remove(keyTokenExpiry);
    print('🔄 Login data cleared');
  }

  /// Clear only profile data
  Future<void> clearProfileData() async {
    await _storage.remove(keyProfileId);
    await _storage.remove(keyPhoneNumber);
    await _storage.remove(keyProfileData);
    await _storage.remove(keyIsProfileCreated);
    print('🔄 Profile data cleared');
  }

  /// Clear specific storage key
  Future<void> clearSpecificKey(String key) async {
    await _storage.remove(key);
    print('🔄 Key "$key" cleared from storage');
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get profile ID with default value
  String getProfileIdOrDefault({String defaultValue = ''}) {
    return getProfileId() ?? defaultValue;
  }

  /// Check if current profile ID matches given ID
  bool isCurrentProfile(String profileId) {
    final currentId = getProfileId();
    return currentId != null && currentId == profileId;
  }

  /// Get profile data as map
  Map<String, dynamic>? getProfileDataMap() {
    return getProfileData();
  }

  /// Get specific field from profile data
  dynamic getProfileField(String fieldName) {
    final data = getProfileData();
    if (data != null && data.containsKey(fieldName)) {
      return data[fieldName];
    }
    return null;
  }

  /// Update specific field in profile data
  Future<void> updateProfileField(String fieldName, dynamic value) async {
    final data = getProfileData() ?? {};
    data[fieldName] = value;
    await saveProfileData(data);
    print('✅ Profile field "$fieldName" updated in storage');
  }

  /// Get stored profile ID as int (if needed)
  int? getProfileIdAsInt() {
    final id = getProfileId();
    if (id != null && id.isNotEmpty) {
      return int.tryParse(id);
    }
    return null;
  }

  // ============================================================
  // BATCH OPERATIONS
  // ============================================================

  /// Save complete user session (login + profile)
  Future<void> saveUserSession({
    required String token,
    required Map<String, dynamic> userData,
    String? refreshToken,
    DateTime? tokenExpiry,
    String? profileId,
    String? phoneNumber,
    Map<String, dynamic>? profileData,
  }) async {
    try {
      // Save login data
      await setAuthToken(token);
      await saveLoginData(userData);
      await setLoggedIn(true);
      
      // Save refresh token if provided
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await setRefreshToken(refreshToken);
      }
      
      // Save token expiry if provided
      if (tokenExpiry != null) {
        await setTokenExpiry(tokenExpiry);
      } else {
        // Default expiry 1 hour from now
        await setTokenExpiry(DateTime.now().add(const Duration(hours: 1)));
      }
      
      // Save profile data if provided
      if (profileId != null) {
        await saveProfileId(profileId);
      }
      if (phoneNumber != null) {
        await savePhoneNumber(phoneNumber);
      }
      if (profileData != null) {
        await saveProfileData(profileData);
        await setProfileCreated(true);
      }
      
      print('✅ User session saved successfully');
    } catch (e) {
      print('❌ Error saving user session: $e');
      rethrow;
    }
  }

  /// Save login session only (when user logs in)
  Future<void> saveLoginSession({
    required String token,
    required Map<String, dynamic> userData,
    String? refreshToken,
    DateTime? tokenExpiry,
  }) async {
    try {
      await setAuthToken(token);
      await saveLoginData(userData);
      await setLoggedIn(true);
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await setRefreshToken(refreshToken);
      }
      
      if (tokenExpiry != null) {
        await setTokenExpiry(tokenExpiry);
      } else {
        await setTokenExpiry(DateTime.now().add(const Duration(hours: 1)));
      }
      
      print('✅ Login session saved successfully');
    } catch (e) {
      print('❌ Error saving login session: $e');
      rethrow;
    }
  }

  /// Save profile session only (when profile is created)
  Future<void> saveProfileSession({
    required String profileId,
    required String phoneNumber,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      await saveProfileId(profileId);
      await savePhoneNumber(phoneNumber);
      await saveProfileData(profileData);
      await setProfileCreated(true);
      print('✅ Profile session saved successfully');
    } catch (e) {
      print('❌ Error saving profile session: $e');
      rethrow;
    }
  }

  /// Restore user session data
  Map<String, dynamic> restoreUserSession() {
    return {
      'token': getAuthToken(),
      'refreshToken': getRefreshToken(),
      'tokenExpiry': getTokenExpiry(),
      'isLoggedIn': isLoggedIn(),
      'profileId': getProfileId(),
      'phoneNumber': getPhoneNumber(),
      'profileData': getProfileData(),
      'isProfileCreated': isProfileCreated(),
      'userData': getLoginData(),
      'hasSeenOnboarding': hasSeenOnboarding(),
      'isTokenExpired': isTokenExpired(),
    };
  }

  // ============================================================
  // DEBUG METHODS
  // ============================================================

  void debugPrintAllData() {
    print('========== STORAGE DATA ==========');
    print('Auth Token: ${getAuthToken() != null ? '✅ Present' : '❌ Not found'}');
    print('Refresh Token: ${getRefreshToken() != null ? '✅ Present' : '❌ Not found'}');
    print('Token Expiry: ${getTokenExpiry()?.toString() ?? '❌ Not found'}');
    print('Is Token Expired: ${isTokenExpired()}');
    print('Login Token: ${getLoginToken() != null ? '✅ Present' : '❌ Not found'}');
    print('Is Logged In: ${isLoggedIn()}');
    print('Login Time: ${getLoginTime()?.toString() ?? '❌ Not found'}');
    print('Session Expired: ${isSessionExpired()}');
    print('Token (Legacy): ${getToken() != null ? '✅ Present' : '❌ Not found'}');
    print('Profile ID: ${getProfileId() ?? '❌ Not found'}');
    print('Phone Number: ${getPhoneNumber() ?? '❌ Not found'}');
    print('Profile Created: ${isProfileCreated()}');
    print('User ID: ${getUserId() ?? '❌ Not found'}');
    print('Profile Data: ${getProfileData() != null ? '✅ Present' : '❌ Not found'}');
    print('Login Data: ${getLoginData() != null ? '✅ Present' : '❌ Not found'}');
    print('Theme Mode: ${getThemeMode() ?? '❌ Not set'}');
    print('Language: ${getLanguage() ?? '❌ Not set'}');
    print('Notifications: ${getNotificationsEnabled()}');
    print('Has Seen Onboarding: ${hasSeenOnboarding()}');
    print('User Status: ${getUserStatus()}');
    print('Has Valid Auth: ${hasValidAuthToken()}');
    print('====================================');
  }

  /// Clear all keys except specified ones
  Future<void> clearAllExcept(List<String> keysToKeep) async {
    final allKeys = getKeys();
    for (final key in allKeys) {
      if (!keysToKeep.contains(key)) {
        await _storage.remove(key);
      }
    }
    print('🔄 All storage cleared except: $keysToKeep');
  }

  /// Check if storage is empty
  bool isEmpty() {
    return _storage.getKeys().isEmpty;
  }

  /// Get storage size (number of keys)
  int getStorageSize() {
    return _storage.getKeys().length;
  }
}