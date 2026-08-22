class ApiUrls {
  static const String baseUrl = 'https://dating-app-4-igom.onrender.com';
   static const String googleMapsApiKey = "AIzaSyAj1ZxP6ZkYfGXhcT0pYl_uUCX_aEFgcsI";
  // Auth endpoints
  static const String login = '/v1/api/auth/login';
  static const String register = '/v1/api/auth/register';
  static const String logout = '/v1/api/auth/logout';
  static const String me = '/v1/api/auth/me';
  static const String refreshToken = '/v1/api/auth/refresh-token';
    static const String profileFilter = '/v1/api/profiles/filter';
  static const String subscriptionScreen = '/v1/api/subscription-screen';
  static const String verifySubscription = '/v1/api/user-subscription/verify'; // 👈 add this
  // Enum endpoints
  static const String gender = '/v1/api/gender';
  static const String sexualOrientation = '/v1/api/sexual-orientation';
  static const String position = '/v1/api/position';
  static const String looking = '/v1/api/interest';
  static const String interest = '/v1/api/interest';
    static const String generateAgoraToken = '/v1/api/calls/token';
  static const String startCall = '/v1/api/calls/start';
  static const String endCall = '/v1/api/calls/end';
  static const String acceptCall = '/v1/api/calls/accept';
  static const String rejectCall = '/v1/api/calls/reject';
    static const String uploadMultiple = '/v1/api/upload/multiple';
  
  // Profile endpoints
  static const String profiles = '/v1/api/profiles';
  static String getProfile(String id) => '/v1/api/profiles/$id';
  static String updateProfile(String id) => '/v1/api/profiles/$id';
  static String deleteProfile(String id) => '/v1/api/profiles/$id';
  static const String uploadPhoto = '/v1/api/profiles/upload-photo';
  static const String bio = '/v1/api/profiles/bio';
  static const String preferences = '/v1/api/profiles/preferences';
static String fcmToken(String profileId) => '/v1/api/profiles/$profileId/fcm-token';
  static const String helpCenter = '/v1/api/help-center';
  
  // Other endpoints
  static const String matches = '/v1/api/matches';
  static const String messages = '/v1/api/messages';
  static const String notifications = '/v1/api/notifications';
  static const String termsAndConditions = '/v1/api/terms-and-conditions';
  static const String childPolicy = '/v1/api/child-policy';
  // Add alongside your other like endpoints
static String getMyLikes(String profileId) => '/v1/api/like/$profileId/me';
  
  // Splash Screen endpoints
  static const String splashScreen = '/v1/api/splash-screen';
  static const String onboarding = '/v1/api/onboarding';
  static const String privacyPolicy = '/v1/api/privacy-policy';
  
  // ✅ FIXED: Like/Unlike endpoints (matches curl format)
  static String likeProfile(String profileId, String targetProfileId) => 
      '/v1/api/profiles/$profileId/like/$targetProfileId';
  
  static String unlikeProfile(String profileId, String targetProfileId) => 
      '/v1/api/profiles/$profileId/unlike/$targetProfileId';
  
  // ✅ FIXED: Block endpoints (POST for block, DELETE for unblock)
  static String blockUser(String profileId, String targetProfileId) => 
      '/v1/api/profiles/$profileId/block/$targetProfileId';
  
  static String unblockUser(String profileId, String targetProfileId) => 
      '/v1/api/profiles/$profileId/block/$targetProfileId';
  
  // Get liked/blocked profiles
  static String getLikedProfiles(String profileId) => '/v1/api/profiles/$profileId/liked';
  static String getBlockedUsers(String profileId) => '/v1/api/profiles/$profileId/blocked';
  
  // Advertisement endpoint
  static const String advertisement = '/v1/api/advertisement';
  // ✅ Review endpoints add karo
static String addReview(String targetProfileId, String reviewerProfileId) =>
    '/v1/api/profiles/$targetProfileId/reviews/$reviewerProfileId';

static String getReviews(String targetProfileId) =>
    '/v1/api/profiles/$targetProfileId/reviews';
}