import 'dart:io';

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class EditphotoView extends StatefulWidget {
  const EditphotoView({super.key});

  @override
  State<EditphotoView> createState() => _EditPhotoViewState();
}

class _EditPhotoViewState extends State<EditphotoView> {
  final ImagePicker picker = ImagePicker();
  final ProfileServiceController profileService = Get.find<ProfileServiceController>();

  // 6 photo slots - store as dynamic (File or String URL)
  final List<dynamic> photos = List<dynamic>.filled(6, null);
  bool isLoading = false;
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPhotos();
  }

  void _loadExistingPhotos() {
    try {
      isFetching = true;
      
      // Clear existing photos
      for (int i = 0; i < photos.length; i++) {
        photos[i] = null;
      }
      
      // First try to load from photoPaths (local files)
      final existingPhotoPaths = profileService.photoPaths;
      
      if (existingPhotoPaths.isNotEmpty) {
        print('📸 Loading ${existingPhotoPaths.length} existing photos from photoPaths');
        
        for (int i = 0; i < existingPhotoPaths.length && i < 6; i++) {
          final path = existingPhotoPaths[i];
          if (path.isNotEmpty && File(path).existsSync()) {
            photos[i] = File(path);
            print('📸 Loaded local photo $i: $path');
          }
        }
      } else {
        // If no photoPaths, try to load from profile.photos
        final profilePhotos = profileService.profile.value.photos;
        if (profilePhotos != null && profilePhotos.isNotEmpty) {
          print('📸 Loading ${profilePhotos.length} photos from profile data');
          
          for (int i = 0; i < profilePhotos.length && i < 6; i++) {
            final photo = profilePhotos[i];
            
            // Check if photo is a Map with 'image' key (API response format)
            if (photo is Map<String, dynamic> && photo.containsKey('image')) {
              final imageUrl = photo['image'] as String?;
              if (imageUrl != null && imageUrl.isNotEmpty) {
                photos[i] = imageUrl; // Store as URL string
                print('📸 Loaded network photo $i: $imageUrl');
              }
            }
            // Check if photo is a String
            else if (photo is String && photo.isNotEmpty) {
              // Check if it's a URL (starts with http)
              if (photo.startsWith('http://') || photo.startsWith('https://')) {
                photos[i] = photo; // Store as URL string
                print('📸 Loaded network photo $i: $photo');
              } 
              // Check if it's a local path
              else if (File(photo).existsSync()) {
                photos[i] = File(photo);
                if (!profileService.photoPaths.contains(photo)) {
                  profileService.photoPaths.add(photo);
                }
                print('📸 Loaded local photo $i: $photo');
              }
            }
          }
        }
      }
      
      setState(() {});
      isFetching = false;
    } catch (e) {
      print('❌ Error loading photos: $e');
      isFetching = false;
    }
  }

  Future<void> pickImage(int index) async {
    if (isLoading) return;

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        photos[index] = File(image.path);
      });
      CustomToast.success('Photo added successfully');
    }
  }

  void removeImage(int index) {
    setState(() {
      photos[index] = null;
    });
    CustomToast.info('Photo removed');
  }

  // Get count of uploaded photos
  int get uploadedPhotoCount {
    return photos.where((photo) => photo != null).length;
  }

  // Check if minimum photos are uploaded
  bool get hasMinimumPhotos {
    return uploadedPhotoCount >= 1;
  }

  // Check if photo is a File (local)
  bool _isFile(dynamic photo) {
    return photo is File;
  }

  // Check if photo is a URL (network)
  bool _isUrl(dynamic photo) {
    return photo is String && (photo.startsWith('http://') || photo.startsWith('https://'));
  }

  // Update photos
  Future<void> updatePhotos() async {
    if (isLoading) return;

    if (!hasMinimumPhotos) {
      CustomToast.warning('Please add at least 1 photo');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get valid photo paths (only Files) - cast to List<String>
      final List<String> validPhotoPaths = photos
          .where((photo) => photo != null && _isFile(photo) && photo.existsSync())
          .map((photo) => photo.path as String)
          .toList();

      if (validPhotoPaths.isNotEmpty) {
        print('📸 Updating ${validPhotoPaths.length} photos');

        // Update photo paths in profile service
        profileService.setPhotoPaths(validPhotoPaths);

        // Update profile with photos
        bool success = await profileService.updateProfile();

        setState(() {
          isLoading = false;
        });

        if (success) {
          // Refresh profile data after update
          await profileService.fetchMyProfile();
          
          // Reload photos
          _loadExistingPhotos();
          
          CustomToast.success('Photos updated successfully! 🎉');

          // Navigate back after success
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.back();
          });
        } else {
          CustomToast.error(profileService.errorMessage.value);
          // Reload to show correct data
          _loadExistingPhotos();
        }
      } else {
        // No new files to upload, but keep existing photos
        CustomToast.info('No new photos to upload');
        setState(() {
          isLoading = false;
        });
        Get.back();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      CustomToast.error('Failed to update photos: $e');
      print('❌ Error updating photos: $e');
    }
  }

  Widget _buildShimmerPhoto(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera,
                size: 32.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 4.h),
              Text(
                'Photo ${index + 1}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmerPhoto(index);
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 30.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Photo ${index + 1}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoWidget(dynamic photo, int index) {
    // If photo is a Map, extract the image URL
    if (photo is Map<String, dynamic>) {
      final imageUrl = photo['image'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return _buildNetworkImage(imageUrl, index);
      }
    }
    
    // If it's a String (URL)
    if (_isUrl(photo)) {
      return _buildNetworkImage(photo as String, index);
    }
    
    // If it's a File (local image)
    if (_isFile(photo)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.file(
          photo,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            );
          },
        ),
      );
    }

    // Fallback
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 30.sp,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),

      /// APP BAR
      appBar: CustomAppBar(
        title: "Edit Photo",
        onBackPressed: () {
          Get.back();
        },
        actions: [
          GestureDetector(
            onTap: () {
              Get.find<DashboardController>().changeTab(6);
              Get.until((route) => route.settings.name == '/dashboard' || Get.currentRoute == '/dashboard');
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Icon(
                Icons.settings,
                size: 24.sp,
                color: const Color(0xff444444),
              ),
            ),
          )
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25.h),

              // Title Text
              Text(
                'Edit Profile Photos',
                style: GoogleFonts.poppins(
                  letterSpacing: 1.5.w,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff3B3B3B),
                ),
              ),

              SizedBox(height: 10.h),

              // Photo counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$uploadedPhotoCount/6 photos uploaded",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: hasMinimumPhotos ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (profileService.photoPaths.isNotEmpty)
                    Text(
                      '${profileService.photoPaths.length} saved',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20.h),

              // Photo Grid with Shimmer Loading
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final photo = photos[index];

                    // Show shimmer while fetching
                    if (isFetching) {
                      return _buildShimmerPhoto(index);
                    }

                    return GestureDetector(
                      onTap: isLoading ? null : () => pickImage(index),
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: Radius.circular(16.r),
                          color: photo != null 
                              ? const Color(0xffFF6B00) 
                              : Colors.grey.shade400,
                          strokeWidth: photo != null ? 2.w : 1.5.w,
                          dashPattern: const [6, 4],
                          padding: EdgeInsets.zero,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Stack(
                            children: [
                              // Photo display
                              if (photo != null)
                                _buildPhotoWidget(photo, index)
                              else
                                Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 32.sp,
                                    color: const Color(0xffD2D1D1),
                                  ),
                                ),

                              // Add / Remove Button
                              Positioned(
                                right: 8.w,
                                bottom: 8.h,
                                child: GestureDetector(
                                  onTap: isLoading 
                                      ? null 
                                      : () {
                                          if (photo != null) {
                                            removeImage(index);
                                          } else {
                                            pickImage(index);
                                          }
                                        },
                                  child: Container(
                                    height: 28.h,
                                    width: 28.w,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      photo == null
                                          ? Icons.add
                                          : Icons.close,
                                      size: 18.sp,
                                      color: const Color(0xffFF6B00),
                                    ),
                                  ),
                                ),
                              ),

                              // Loading overlay for update
                              if (isLoading)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      height: 30.h,
                                      width: 30.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),

              // Show saved photos count
              if (profileService.photoPaths.isNotEmpty || 
                  (profileService.profile.value.photos != null && 
                   profileService.profile.value.photos!.isNotEmpty))
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    '${profileService.photoPaths.isNotEmpty ? profileService.photoPaths.length : profileService.profile.value.photos?.length ?? 0} photos in profile',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // ─── Update Button ───
              CustomButton(
                text: "Update Photos",
                onPressed: isLoading || isFetching ? () {} : updatePhotos,
                isLoading: isLoading,
                backgroundColor: hasMinimumPhotos 
                    ? const Color(0xffFF6B00) 
                    : Colors.grey,
              ),

              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}