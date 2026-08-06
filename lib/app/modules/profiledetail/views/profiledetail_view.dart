import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/modules/chat/views/chat_view.dart';
import 'package:dating_app/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfiledetailView extends StatefulWidget {
  final Map<String, dynamic>? profileData;

  const ProfiledetailView({super.key, this.profileData});

  @override
  State<ProfiledetailView> createState() => _ProfiledetailViewState();
}

class _ProfiledetailViewState extends State<ProfiledetailView> {
  String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ')
      .map((word) => word.isEmpty
          ? word
          : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _showAddReviewDialog() {
    _reviewController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write a Review',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final text = _reviewController.text;
                            Navigator.pop(context);
                            await _submitReview(text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6100),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Reviews ke liye state variables
  List<Map<String, dynamic>> reviews = [];
  bool isLoadingReviews = false;
  bool isSubmittingReview = false;
  final TextEditingController _reviewController = TextEditingController();
  bool isUserBlocked = false;
  bool isLoading = false;
  bool _isAboutExpanded = false;
  bool showMenu = false;

  bool isLiked = false;
  bool isLikeLoading = false;
  bool isLikeDataLoading = true; // ✅ NAYA — jab tak API se fresh like data nahi aata
  int currentLikeCount = 0;
  int _likeActionSeq = 0; // ✅ NAYA — race-guard for async like-status checks

  // Profile data
  Map<String, dynamic> profile = {
    '_id': '',
    'name': 'User',
    'age': 25,
    'location': 'Unknown',
    'distance': '0 km',
    'bio': 'Hello, I\'m using this app',
    'profession': 'Professional',
    'interests': ['Social', 'Chat'],
    'photos': ['assets/images/hprofile.png'],
    'gender': 'Not specified',
    'looking': 'Not specified',
    'isVerified': false,
    'likeCount': 0,
  };

  // Gallery images list
  List<String> galleryImages = [];

  // Main profile image
  String selectedProfileImage = "";

  // Storage service
  final StorageService _storage = StorageService();

  // Current user's profile ID (get from storage)
  String get currentProfileId => _storage.getProfileId() ?? '';

  @override
  void initState() {
    super.initState();
    _initializeProfileData();
    _checkIfUserBlocked();

    // ✅ NAYA — Homepage se aaye purane data par depend nahi karte.
    // Dono cheezein — like count AND liked/unliked status — seedha API se fetch hoti hain.
    _fetchFreshLikeAndStatus();

    _fetchReviews();
  }

  // ============================================================
  // ✅ NAYA — SINGLE RELIABLE METHOD: API se fresh like count +
  // liked/unliked status dono ek saath fetch karta hai
  // ============================================================
  Future<void> _fetchFreshLikeAndStatus() async {
    final targetProfileId = (profile['id'] ?? profile['_id'] ?? '').toString();
    if (targetProfileId.isEmpty) {
      setState(() => isLikeDataLoading = false);
      return;
    }

    final mySeqAtStart = _likeActionSeq;

    try {
      final token = await _getFirebaseAuthToken();

      // ---- 1) Target profile ka fresh 'likes' count fetch karo ----
      final targetUrl = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(targetProfileId)}');
      final targetResponse = await http.get(
        targetUrl,
        headers: {
          'accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      int? freshLikes;
      if (targetResponse.statusCode == 200) {
        final data = json.decode(targetResponse.body);
        final targetProfileData = data['data'] ?? data;
        final likesValue = targetProfileData['likes'];

        if (likesValue is int) {
          freshLikes = likesValue;
        } else if (likesValue is num) {
          freshLikes = likesValue.toInt();
        } else if (likesValue is String) {
          freshLikes = int.tryParse(likesValue);
        }
      } else {
        print('❌ Failed to fetch target profile likes: ${targetResponse.statusCode}');
      }

      // ---- 2) Apna profile fetch karke check karo ki targetProfileId
      //         'likedProfiles' array me hai ya nahi (reliable liked-status source) ----
      bool liked = false;
      if (currentProfileId.isNotEmpty) {
        final myUrl = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getProfile(currentProfileId)}');
        final myResponse = await http.get(
          myUrl,
          headers: {
            'accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        if (myResponse.statusCode == 200) {
          final myData = json.decode(myResponse.body);
          final myProfileData = myData['data'] ?? myData;
          final List<dynamic> likedIds = myProfileData['likedProfiles'] ?? [];
          liked = likedIds.map((e) => e.toString()).contains(targetProfileId);
        } else {
          print('❌ Failed to fetch own profile for like-status: ${myResponse.statusCode}');
        }
      }

      // ✅ Race-guard: agar is beech me user ne khud manually like/unlike
      // dabaa diya hai (_likeActionSeq badal gaya), to ye purana result IGNORE karo
      if (mounted && mySeqAtStart == _likeActionSeq) {
        setState(() {
          if (freshLikes != null) currentLikeCount = freshLikes!;
          isLiked = liked;
          isLikeDataLoading = false;
        });
        print('✅ Fresh like data loaded — count: $currentLikeCount, liked: $isLiked');
      } else {
        print('⚠️ Ignoring stale like-data result (user already toggled manually)');
      }
    } catch (e) {
      print('❌ Error fetching fresh like/status data: $e');
      if (mounted) setState(() => isLikeDataLoading = false);
    }
  }

  // ✅ GET /v1/api/profiles/{targetProfileId}/reviews
  Future<void> _fetchReviews() async {
    final targetProfileId = (profile['id'] ?? profile['_id'] ?? '').toString();
    if (targetProfileId.isEmpty) return;

    setState(() => isLoadingReviews = true);

    try {
      final token = await _getFirebaseAuthToken();
      final url = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getReviews(targetProfileId)}');

      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          if (mounted) {
            setState(() {
              reviews = List<Map<String, dynamic>>.from(data['data']);
            });
          }
        }
      } else {
        print('❌ Failed to fetch reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching reviews: $e');
    } finally {
      if (mounted) setState(() => isLoadingReviews = false);
    }
  }

  // ✅ POST /v1/api/profiles/{targetProfileId}/reviews/{reviewerProfileId}
  Future<void> _submitReview(String reviewText) async {
    final trimmed = reviewText.trim();
    if (trimmed.isEmpty) {
      CustomToast.error('Please write something before submitting');
      return;
    }

    final targetProfileId = (profile['id'] ?? profile['_id'] ?? '').toString();
    if (targetProfileId.isEmpty || currentProfileId.isEmpty) {
      CustomToast.error('Unable to submit review');
      return;
    }

    setState(() => isSubmittingReview = true);

    try {
      final token = await _getFirebaseAuthToken();
      final url = Uri.parse(
        '${ApiUrls.baseUrl}${ApiUrls.addReview(targetProfileId, currentProfileId)}',
      );

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'review': trimmed}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomToast.success('Review added successfully');
        _reviewController.clear();
        await _fetchReviews(); // ✅ list turant refresh karo
      } else {
        final data = json.decode(response.body);
        CustomToast.error(data['message'] ?? 'Failed to add review');
      }
    } catch (e) {
      print('❌ Error submitting review: $e');
      CustomToast.error('Something went wrong');
    } finally {
      if (mounted) setState(() => isSubmittingReview = false);
    }
  }

  Future<String?> _getFirebaseAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken(false);
      return token;
    } catch (e) {
      print('❌ Error getting Firebase token: $e');
      return _storage.getAuthToken(); // fallback
    }
  }

  // ============================================================
  // LIKE / UNLIKE TOGGLE
  // ============================================================
  void _handleLikeToggle() async {
    if (isLikeLoading || isLikeDataLoading) return;

    final targetProfileId = (profile['id'] ?? profile['_id'] ?? '').toString();
    if (targetProfileId.isEmpty) {
      CustomToast.error('Unable to like: profile not found');
      return;
    }

    // ✅ Manual toggle hote hi sequence badal do, taaki koi pending
    // _fetchFreshLikeAndStatus() ka purana result baad me aakar isse overwrite na kare
    _likeActionSeq++;

    setState(() => isLikeLoading = true);

    try {
      final profileController = ProfileServiceController.to;
      final wasLiked = isLiked; // action decide karne ke liye pre-toggle value

      bool success;
      if (wasLiked) {
        success = await profileController.unlikeProfile(targetProfileId);
      } else {
        success = await profileController.likeProfile(targetProfileId);
      }

      if (success && mounted) {
        setState(() {
          isLiked = !wasLiked;
          // ✅ Optimistic count update — koi extra "confirm from backend" call NAHI,
          // kyunki wo purana/stale count laa kar sahi update ko overwrite kar deta tha
          if (isLiked) {
            currentLikeCount++;
          } else {
            currentLikeCount = currentLikeCount > 0 ? currentLikeCount - 1 : 0;
          }
        });

        // ✅ Homepage ke card list ko bhi turant sync kar do (agar wo screen registered hai)
        _syncLikeCountToHomepage(targetProfileId, currentLikeCount);

        if (isLiked) {
          CustomToast.success('${getDisplayName()} liked ❤️');
        } else {
          CustomToast.success('${getDisplayName()} unliked');
        }
      } else if (mounted) {
        final errMsg = profileController.errorMessage.value.toLowerCase();

        // ✅ Backend ke error se pata chal raha hai ki local state galat thi —
        // usko turant sahi kar do taaki agli baar sahi action ho
        if (errMsg.contains('already liked')) {
          setState(() => isLiked = true);
          CustomToast.error('Already liked — status updated');
        } else if (errMsg.contains('not liked') || errMsg.contains("haven't liked")) {
          setState(() => isLiked = false);
          CustomToast.error('Already unliked — status updated');
        } else {
          CustomToast.error(
            profileController.errorMessage.value.isNotEmpty
                ? profileController.errorMessage.value
                : 'Something went wrong',
          );
        }
      }
    } catch (e) {
      print('❌ Error toggling like: $e');
      if (mounted) CustomToast.error('Something went wrong');
    } finally {
      if (mounted) {
        setState(() => isLikeLoading = false);
      }
    }
  }

  // ✅ Homepage ke card list me is profile ka like count turant update karo
  void _syncLikeCountToHomepage(String profileId, int newCount) {
    try {
      if (Get.isRegistered<HomepageController>()) {
        final homeController = Get.find<HomepageController>();
        homeController.likeCountOverrides[profileId] = newCount;
        print('✅ Synced like count to Homepage: $profileId -> $newCount');
      }
    } catch (e) {
      print('⚠️ Could not sync like count to Homepage: $e');
    }
  }

  void _initializeProfileData() {
    // Get profile data from widget
    if (widget.profileData != null) {
      profile = widget.profileData!;
    } else {
      // Fallback default data
      profile = {
        '_id': '6a644b4c1d0e4094935cd635',
        'name': 'User',
        'age': 25,
        'location': 'Unknown',
        'distance': '0 km',
        'bio': 'Hello, I\'m using this app',
        'profession': 'Professional',
        'interests': ['Social', 'Chat'],
        'photos': ['assets/images/hprofile.png'],
        'gender': 'Not specified',
        'looking': 'Not specified',
        'isVerified': false,
        'likeCount': 0,
      };
    }

    // ✅ NOTE: Ye sirf ek placeholder/temporary value hai jab tak
    // _fetchFreshLikeAndStatus() API se asli count nahi le aata (thodi der me overwrite ho jayega)
    currentLikeCount = profile['likeCount'] ?? profile['likes'] ?? 0;

    // Extract gallery images
    galleryImages = [];

    if (profile['photos'] != null && profile['photos'] is List) {
      final photosList = profile['photos'] as List;
      print('📸 Raw photos data: $photosList');

      for (var photo in photosList) {
        if (photo is Map<String, dynamic>) {
          String? imageUrl = photo['image']?.toString();
          if (imageUrl != null && imageUrl.isNotEmpty) {
            galleryImages.add(imageUrl);
            print('✅ Added map photo: $imageUrl');
          }
        } else if (photo is String) {
          if (photo.isNotEmpty) {
            galleryImages.add(photo);
            print('✅ Added string photo: $photo');
          }
        }
      }
    }

    if (galleryImages.isEmpty) {
      if (profile['photo'] != null && profile['photo'].toString().isNotEmpty) {
        galleryImages.add(profile['photo'].toString());
      } else {
        galleryImages = ['assets/images/hprofile.png'];
      }
      print('⚠️ No images found, using default');
    }

    selectedProfileImage = galleryImages.isNotEmpty ? galleryImages[0] : 'assets/images/hprofile.png';

    print('📸 Final gallery images: $galleryImages');
    print('📸 Selected image: $selectedProfileImage');
  }

  Future<void> _checkIfUserBlocked() async {
    if (currentProfileId.isEmpty) return;

    final token = _storage.getAuthToken();
    if (token == null || token.isEmpty) return;

    final targetProfileId = (profile['id'] ?? profile['_id'] ?? '').toString();
    if (targetProfileId.isEmpty) return;

    try {
      final url = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.getBlockedUsers(currentProfileId)}');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> blockedUsers = json.decode(response.body);
        setState(() {
          isUserBlocked = blockedUsers.any((user) => user['id'] == targetProfileId);
        });
      }
    } catch (e) {
      print('Error checking block status: $e');
    }
  }

  // Block/Unblock user
  void _handleBlockUser() async {
    if (currentProfileId.isEmpty) {
      CustomToast.error('Please login first');
      return;
    }

    setState(() {
      showMenu = false;
      isLoading = true;
    });

    final bool? confirm = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20.r,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80.h,
                width: 80.h,
                decoration: BoxDecoration(
                  color: isUserBlocked ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUserBlocked ? Icons.check_circle_outline : Icons.block_outlined,
                  color: isUserBlocked ? Colors.green : Colors.red,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                isUserBlocked ? 'Unblock User?' : 'Block User?',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                isUserBlocked
                    ? 'Are you sure you want to unblock ${getDisplayName()}?'
                    : 'Are you sure you want to block ${getDisplayName()}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isUserBlocked
                                ? [Colors.green, Colors.green.shade700]
                                : [const Color(0xffFF6B00), const Color(0xffFF6B00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isUserBlocked ? Icons.check : Icons.block,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                isUserBlocked ? 'Unblock' : 'Block',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && mounted) {
      final token = _storage.getAuthToken();
      if (token == null || token.isEmpty) {
        CustomToast.error('Please login first');
        setState(() => isLoading = false);
        return;
      }

      final targetProfileId = (profile['id'] ?? profile['_id'] ?? '').toString();
      if (targetProfileId.isEmpty) {
        CustomToast.error('Invalid profile ID');
        setState(() => isLoading = false);
        return;
      }

      try {
        CustomToast.show(
          message: isUserBlocked ? 'Unblocking user...' : 'Blocking user...',
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
          duration: 1,
        );

        bool success;

        if (isUserBlocked) {
          final url = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.unblockUser(currentProfileId, targetProfileId)}');
          final response = await http.delete(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          success = response.statusCode == 200 || response.statusCode == 204;
          print('Unblock response: ${response.statusCode}');
        } else {
          final url = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.blockUser(currentProfileId, targetProfileId)}');
          final response = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          success = response.statusCode == 200 || response.statusCode == 201;
          print('Block response: ${response.statusCode}');
        }

        if (success && mounted) {
          setState(() {
            isUserBlocked = !isUserBlocked;
            isLoading = false;
          });

          CustomToast.success(
            isUserBlocked
                ? '${getDisplayName()} blocked successfully 🚫'
                : '${getDisplayName()} unblocked successfully ✅',
          );
        } else {
          setState(() => isLoading = false);
          CustomToast.error('Action failed. Please try again.');
        }
      } catch (e) {
        setState(() => isLoading = false);
        CustomToast.error('An error occurred: $e');
        print('Block error: $e');
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  void _shareProfile() async {
    setState(() => showMenu = false);
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final name = getDisplayName();
      final age = getAge();
      final location = getLocation();
      final profession = getProfession();
      final interests = getInterests().join(', ');

      await Share.share(
        'Check out $name\'s profile on Dating App! ❤️\n'
        'Age: $age\n'
        'Location: $location\n'
        'Profession: $profession\n'
        'Looking For: $interests\n'
        'Download the app to connect!',
        subject: 'Check out this profile!',
      );
    } catch (e) {
      final name = getDisplayName();
      final age = getAge();
      final location = getLocation();
      final profession = getProfession();

      await Clipboard.setData(
        ClipboardData(
          text: 'Check out $name\'s profile on Dating App! ❤️\n'
              'Age: $age\n'
              'Location: $location\n'
              'Profession: $profession',
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile copied to clipboard! 📋'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Helper methods
  String getDisplayName() {
    String firstName = profile['firstName'] ?? '';
    String lastName = profile['lastName'] ?? '';
    String fullName = '$firstName $lastName'.trim();
    if (fullName.isEmpty) fullName = profile['nickName'] ?? profile['name'] ?? 'User';
    return fullName;
  }

  int getAge() {
    if (profile['age'] != null && profile['age'] is int) {
      return profile['age'];
    }
    if (profile['birthday'] != null) {
      try {
        final birthday = DateTime.parse(profile['birthday']);
        final now = DateTime.now();
        int age = now.year - birthday.year;
        if (now.month < birthday.month ||
            (now.month == birthday.month && now.day < birthday.day)) {
          age--;
        }
        return age;
      } catch (e) {
        return 0;
      }
    }
    return profile['age'] ?? 0;
  }

  String getLocation() {
    return profile['location'] ?? 'Unknown location';
  }

  String getDistance() {
    return profile['distance'] ?? '0 km';
  }

  String getBio() {
    return profile['bio'] ?? 'Hello, I\'m using this app';
  }

  String getProfession() {
    return profile['profession'] ?? profile['looking']?['title'] ?? 'Professional';
  }

  List<String> getInterests() {
    List<String> interests = [];
    if (profile['looking'] != null && profile['looking']['title'] != null) {
      interests.add(profile['looking']['title']);
    }
    if (profile['interest'] != null && profile['interest'].toString().isNotEmpty) {
      interests.add(profile['interest'].toString());
    }
    if (profile['interests'] != null && profile['interests'] is List) {
      interests.addAll(List<String>.from(profile['interests']));
    }
    if (profile['hobbies'] != null && profile['hobbies'] is List) {
      interests.addAll(List<String>.from(profile['hobbies']));
    }
    if (interests.isEmpty) {
      interests = ['Social', 'Chat', 'Travel'];
    }
    return interests.take(5).toList();
  }

  int getLikeCount() {
    return currentLikeCount;
  }

  bool isVerified() {
    return profile['isVerified'] ?? false;
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

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/hprofile.png', fit: BoxFit.contain);
                      },
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    final name = getDisplayName();
    final age = getAge();
    final location = getLocation();
    final distance = getDistance();
    final bio = getBio();
    final profession = getProfession();
    final interests = getInterests();
    final likeCount = getLikeCount();
    final verified = isVerified();

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: Stack(
        children: [
          /// Top Image
          GestureDetector(
            onTap: () {
              _showFullScreenImage(context, selectedProfileImage);
            },
            child: SizedBox(
              height: 0.76.sh,
              width: double.infinity,
              child: selectedProfileImage.startsWith('http')
                  ? Image.network(
                      selectedProfileImage,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/hprofile.png', fit: BoxFit.fill);
                      },
                    )
                  : Image.asset(
                      selectedProfileImage,
                      fit: BoxFit.fill,
                    ),
            ),
          ),

          /// Back Button & More Icon
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  if (!isLoading)
                    GestureDetector(
                      onTap: () => setState(() => showMenu = !showMenu),
                      child: Icon(Icons.more_horiz, color: Colors.white, size: 30.sp),
                    )
                  else
                    SizedBox(
                      height: 30.sp,
                      width: 30.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// Bottom Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.52.sh,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                children: [
                  /// Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24.w, 55.h, 24.w, 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Row(
  children: [
    Expanded(
      child: Text(
        "${_capitalize(name)}, $age",
        style: TextStyle(
          letterSpacing: 1.5,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.red, size: 15.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _formatLikeCount(likeCount),
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 5.h),
                          Text(
                            profession,
                            style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                          ),
                          SizedBox(height: 15.h),

                          Text(
                            "Location",
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.orange, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  distance,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),

                          SizedBox(height: 15.h),

                          /// About Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "About",
                                  style: TextStyle(
                                    letterSpacing: 1.5,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  bio,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.sp,
                                    height: 1.5,
                                  ),
                                  maxLines: _isAboutExpanded ? null : 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10.h),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
                                    child: Text(
                                      _isAboutExpanded ? "Read less" : "Read more",
                                      style: TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          /// Gallery
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Gallery",
                                style: TextStyle(
                                  letterSpacing: 1.5,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "See all",
                                style: TextStyle(
                                  letterSpacing: 1.5,
                                  fontSize: 14.sp,
                                  color: const Color(0xffFF6100),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: galleryImages.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: .75,
                            ),
                            itemBuilder: (context, index) {
                              final imageUrl = galleryImages[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedProfileImage = imageUrl;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: selectedProfileImage == imageUrl
                                        ? Border.all(
                                            color: const Color(0xffFF6100),
                                            width: 0.6,
                                          )
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: imageUrl.startsWith('http')
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.fill,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/hprofile.png',
                                                fit: BoxFit.fill,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            imageUrl,
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 25.h),

                          /// Review Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Review",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showAddReviewDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6100),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  elevation: 0,
                                  minimumSize: Size(0, 30.h),
                                ),
                                icon: Container(
                                  height: 18.r,
                                  width: 18.r,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 12.sp,
                                      color: const Color(0xFFFF6100),
                                    ),
                                  ),
                                ),
                                label: Text(
                                  "Add Review",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),

                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: isLoadingReviews
                                ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.h),
                                    child: const Center(child: CircularProgressIndicator()),
                                  )
                                : reviews.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20.h),
                                        child: Center(
                                          child: Text(
                                            'No reviews yet',
                                            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: List.generate(reviews.length, (index) {
                                          final reviewItem = reviews[index];
                                          final reviewerData = reviewItem['id'];

                                          String reviewerName = 'User';
                                          String reviewerImage = '';

                                          if (reviewerData is Map<String, dynamic>) {
                                            final first = reviewerData['firstName'] ?? '';
                                            final last = reviewerData['lastName'] ?? '';
                                            reviewerName = '$first $last'.trim();
                                            if (reviewerName.isEmpty) reviewerName = 'User';

                                            final photos = reviewerData['photos'];
                                            if (photos is List && photos.isNotEmpty) {
                                              final firstPhoto = photos[0];
                                              if (firstPhoto is Map<String, dynamic>) {
                                                reviewerImage = firstPhoto['image']?.toString() ?? '';
                                              }
                                            }
                                          }

                                          final reviewText = reviewItem['review']?.toString() ?? '';

                                          return Column(
                                            children: [
                                              dynamicReviewTile(
                                                name: reviewerName,
                                                image: reviewerImage,
                                                review: reviewText,
                                              ),
                                              if (index != reviews.length - 1) const Divider(height: 28),
                                            ],
                                          );
                                        }),
                                      ),
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),

                  /// Sticky Message Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 10.h),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final targetUserId = (profile['id'] ?? profile['_id'] ?? '').toString();

                            if (targetUserId.isEmpty) {
                              CustomToast.error('Unable to start chat: user not found');
                              return;
                            }

                            Get.to(
                              () => const ChatView(),
                              arguments: {
                                'userId': targetUserId,
                                'userName': getDisplayName(),
                                'userImage': selectedProfileImage.startsWith('http') ? selectedProfileImage : '',
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6100),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          icon: const Icon(Icons.send_outlined, color: Colors.white),
                          label: Text(
                            "Message",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Floating Buttons
          Positioned(
            bottom: 0.47.sh,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleButton(
                  Icons.close,
                  Colors.white,
                  Colors.black54,
                  28,
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(width: 20.w),
                _circleButton(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    isLiked ? const Color(0xFFFF6100) : Colors.white,
                    isLiked ? Colors.white : const Color(0xFFFF6100),
                    38,
                    onTap: _handleLikeToggle,
                  ),
                SizedBox(width: 20.w),
                _circleButton(
                  Icons.chat_bubble_rounded,
                  Colors.white,
                  Colors.deepPurple,
                  28,
                  onTap: () {
                    final targetUserId = (profile['id'] ?? profile['_id'] ?? '').toString();

                    if (targetUserId.isEmpty) {
                      CustomToast.error('Unable to start chat: user not found');
                      return;
                    }

                    Get.to(
                      () => const ChatView(),
                      arguments: {
                        'userId': targetUserId,
                        'userName': getDisplayName(),
                        'userImage': selectedProfileImage.startsWith('http') ? selectedProfileImage : '',
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          /// Menu
          if (showMenu && !isLoading)
            Positioned(
              top: 70.h,
              right: 12.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  menuCircle("assets/icons/share1.svg", _shareProfile),
                  SizedBox(height: 12.h),
                  menuCircle(
                    "assets/icons/share2.svg",
                    _handleBlockUser,
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Naya — real data ke sath review dikhata hai
  Widget dynamicReviewTile({
    required String name,
    required String image,
    required String review,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: image.isNotEmpty && image.startsWith('http')
              ? Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset("assets/images/hprofile.png", fit: BoxFit.cover),
                )
              : Image.asset("assets/images/hprofile.png", fit: BoxFit.cover),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                review,
                style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, Color bg, Color iconColor, double radius, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (radius * 2).r,
        width: (radius * 2).r,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 15.r,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: radius.sp),
      ),
    );
  }
}

// ==================== Helper Widgets ====================

Widget reviewTile() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 44.w,
        height: 44.w,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: Image.asset("assets/images/hprofile.png", fit: BoxFit.fill),
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jennifer Rose",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              "I love it... Awesome customer service!\nHelped me.",
              style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 13.sp),
            ),
            SizedBox(height: 6.h),
            Row(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: Icon(Icons.star, size: 16.sp, color: Colors.amber),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget interestChip(String title, bool selected) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: selected ? const Color(0xfffff3ec) : Colors.white,
      border: Border.all(
        color: selected ? const Color(0xffFF6100) : Colors.grey.shade300,
      ),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected)
          Padding(
            padding: EdgeInsets.only(right: 5.w),
            child: Icon(Icons.check, size: 16.sp, color: const Color(0xffFF6100)),
          ),
        Text(
          title,
          style: TextStyle(letterSpacing: 1.5, fontSize: 12.sp),
        ),
      ],
    ),
  );
}

Widget menuCircle(String svgPath, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 35.w,
      width: 35.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          svgPath,
          height: 18.sp,
          width: 18.sp,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
      ),
    ),
  );
}