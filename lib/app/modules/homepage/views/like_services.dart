import 'package:get/get.dart';
import 'package:dating_app/app/models/profile_all_model.dart';

class LikeStateService extends GetxService {
  final RxList<String> likedProfileIds = <String>[].obs;
  final RxList<ProfileModel> likedProfiles = <ProfileModel>[].obs;
  final RxInt likeCount = 0.obs;
  
  // Store like counts for each profile
  final Map<String, int> _likeCounts = {};
  
  // Get like count for a specific profile
  int getLikeCount(String profileId) {
    return _likeCounts[profileId] ?? 0;
  }
  
  // ✅ Get merged like count (API + stored)
  int getMergedLikeCount(String profileId, int apiLikeCount) {
    // If we have a stored count for this profile, use it
    if (_likeCounts.containsKey(profileId)) {
      final storedCount = _likeCounts[profileId]!;
      
      // If the profile is in the liked list, ensure count is at least 1
      if (likedProfileIds.contains(profileId) && storedCount == 0) {
        return 1;
      }
      
      // Use the stored count if it's higher than API count
      return storedCount > apiLikeCount ? storedCount : apiLikeCount;
    }
    
    // If profile is liked but no stored count, use API count or at least 1
    if (likedProfileIds.contains(profileId)) {
      return apiLikeCount > 0 ? apiLikeCount : 1;
    }
    
    return apiLikeCount;
  }
  
  // Increment like count for a profile
  void incrementLikeCount(String profileId) {
    final currentCount = _likeCounts[profileId] ?? 0;
    _likeCounts[profileId] = currentCount + 1;
    print('📊 Incremented like count for $profileId: ${_likeCounts[profileId]}');
  }
  
  // Decrement like count for a profile
  void decrementLikeCount(String profileId) {
    final currentCount = _likeCounts[profileId] ?? 0;
    if (currentCount > 0) {
      _likeCounts[profileId] = currentCount - 1;
      print('📊 Decremented like count for $profileId: ${_likeCounts[profileId]}');
    }
    if ((_likeCounts[profileId] ?? 0) <= 0) {
      _likeCounts[profileId] = 0;
    }
  }
  
  // Add a profile to liked list
  void addLikedProfile(ProfileModel profile) {
    final id = profile.id;
    if (id != null && id.isNotEmpty && !likedProfileIds.contains(id)) {
      likedProfileIds.add(id);
      likedProfiles.add(profile);
      likeCount.value = likedProfiles.length;
      
      // ✅ Store the like count
      final count = profile.likeCount ?? 1;
      _likeCounts[id] = count;
      
      print('✅ Profile added to liked state: $id, Count: $count');
    }
  }
  
  // Add only profile ID
  void addLikedProfileId(String profileId) {
    if (profileId.isNotEmpty && !likedProfileIds.contains(profileId)) {
      likedProfileIds.add(profileId);
      likeCount.value = likedProfiles.length;
      
      final currentCount = _likeCounts[profileId] ?? 0;
      _likeCounts[profileId] = currentCount + 1;
      
      print('✅ Profile ID added to liked state: $profileId, Count: ${_likeCounts[profileId]}');
    }
  }
  
  // Remove a profile from liked list
  void removeLikedProfile(String profileId) {
    likedProfileIds.remove(profileId);
    likedProfiles.removeWhere((p) => p.id == profileId);
    likeCount.value = likedProfiles.length;
    // Keep the count but mark it as 0
    _likeCounts[profileId] = 0;
    print('✅ Profile removed from liked state: $profileId');
  }
  
  // Check if profile is liked
  bool isProfileLiked(String profileId) {
    return likedProfileIds.contains(profileId);
  }
  
  // Clear all liked data
  void clearLikedData() {
    likedProfileIds.clear();
    likedProfiles.clear();
    likeCount.value = 0;
    _likeCounts.clear();
    print('✅ Cleared all liked data');
  }
}
  final RxList<String> likedProfileIds = <String>[].obs;
  final RxList<ProfileModel> likedProfiles = <ProfileModel>[].obs;
  final RxInt likeCount = 0.obs;
  
  // Store like counts for each profile
  final Map<String, int> _likeCounts = {};
  
  // Get like count for a specific profile
  int getLikeCount(String profileId) {
    return _likeCounts[profileId] ?? 0;
  }
  
  // Update like count for a profile
  void updateLikeCount(String profileId, int count) {
    _likeCounts[profileId] = count;
    print('📊 Updated like count for $profileId: $count');
  }
  
  // Increment like count for a profile
  void incrementLikeCount(String profileId) {
    final currentCount = _likeCounts[profileId] ?? 0;
    _likeCounts[profileId] = currentCount + 1;
    print('📊 Incremented like count for $profileId: ${_likeCounts[profileId]}');
  }
  
  // Decrement like count for a profile
  void decrementLikeCount(String profileId) {
    final currentCount = _likeCounts[profileId] ?? 0;
    if (currentCount > 0) {
      _likeCounts[profileId] = currentCount - 1;
      print('📊 Decremented like count for $profileId: ${_likeCounts[profileId]}');
    }
    if ((_likeCounts[profileId] ?? 0) <= 0) {
      _likeCounts[profileId] = 0;
    }
  }
  
  // Get merged like count (API + stored)
  int getMergedLikeCount(String profileId, int apiLikeCount) {
    if (_likeCounts.containsKey(profileId)) {
      final storedCount = _likeCounts[profileId]!;
      final mergedCount = storedCount > apiLikeCount ? storedCount : apiLikeCount;
      
      if (likedProfileIds.contains(profileId) && mergedCount == 0) {
        return 1;
      }
      
      return mergedCount;
    }
    
    if (likedProfileIds.contains(profileId) && apiLikeCount == 0) {
      return 1;
    }
    
    return apiLikeCount;
  }
  
  // Add a profile to liked list
  void addLikedProfile(ProfileModel profile) {
    final id = profile.id;
    if (id != null && id.isNotEmpty && !likedProfileIds.contains(id)) {
      likedProfileIds.add(id);
      likedProfiles.add(profile);
      likeCount.value = likedProfiles.length;
      
      // ✅ Use the likeCount from the profile model
      final count = profile.likeCount ?? 1;
      _likeCounts[id] = count;
      
      print('✅ Profile added to liked state: $id, Count: $count');
    }
  }
  
  // Add only profile ID (when profile data not available)
  void addLikedProfileId(String profileId) {
    if (profileId.isNotEmpty && !likedProfileIds.contains(profileId)) {
      likedProfileIds.add(profileId);
      likeCount.value = likedProfiles.length;
      
      final currentCount = _likeCounts[profileId] ?? 0;
      _likeCounts[profileId] = currentCount + 1;
      
      print('✅ Profile ID added to liked state: $profileId, Count: ${_likeCounts[profileId]}');
    }
  }
  
  // Remove a profile from liked list
  void removeLikedProfile(String profileId) {
    likedProfileIds.remove(profileId);
    likedProfiles.removeWhere((p) => p.id == profileId);
    likeCount.value = likedProfiles.length;
    _likeCounts.remove(profileId);
    print('✅ Profile removed from liked state: $profileId');
  }
  
  // Check if profile is liked
  bool isProfileLiked(String profileId) {
    return likedProfileIds.contains(profileId);
  }
  
  // Clear all liked data
  void clearLikedData() {
    likedProfileIds.clear();
    likedProfiles.clear();
    likeCount.value = 0;
    _likeCounts.clear();
    print('✅ Cleared all liked data');
  }
  
  // Set liked profiles from API
  void setLikedProfiles(List<ProfileModel> profiles) {
    likedProfiles.value = profiles;
    likedProfileIds.value = profiles
        .map((p) => p.id)
        .where((id) => id != null)
        .cast<String>()
        .toList();
    likeCount.value = likedProfiles.length;
    
    // ✅ Store like counts from each profile
    for (var profile in profiles) {
      if (profile.id != null) {
        _likeCounts[profile.id!] = profile.likeCount ?? 1;
      }
    }
    
    print('✅ Set ${profiles.length} liked profiles in state service');
  }
  
  // Get liked profiles count
  int getLikedProfilesCount() {
    return likedProfiles.length;
  }
