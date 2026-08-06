import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/position/views/position_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BirthdayController extends GetxController {
  final dobController = TextEditingController();
  
  // Reactive variables
  RxInt selectedDay = 1.obs;
  RxString selectedMonth = "January".obs;
  RxInt selectedYear = 2000.obs;
  RxString meetPlace = "Yes".obs; // Default to "Yes"

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  // Get ProfileServiceController
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();

  @override
  void onInit() {
    super.onInit();
    // Load saved meet place if available
    _loadSavedMeetPlace();
  }

  void _loadSavedMeetPlace() {
    final savedProfile = profileController.profile.value;
    if (savedProfile.meetPlace != null && savedProfile.meetPlace!.isNotEmpty) {
      // If stored as string "true"/"false", convert to "Yes"/"No"
      if (savedProfile.meetPlace == "true") {
        meetPlace.value = "Yes";
      } else if (savedProfile.meetPlace == "false") {
        meetPlace.value = "No";
      } else {
        meetPlace.value = savedProfile.meetPlace!;
      }
    }
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      selectedDay.value = picked.day;
      selectedMonth.value = months[picked.month - 1];
      selectedYear.value = picked.year;
    }
  }

  void next(BuildContext context) {
    final day = selectedDay.value;
    final month = months.indexOf(selectedMonth.value) + 1;
    final year = selectedYear.value;

    final dob = DateTime(year, month, day);
    
    // Format birthday as string (YYYY-MM-DD)
    String birthday = "${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}";
    
    // Store in ProfileServiceController
    profileController.updateBirthday(birthday);
    
    // Convert "Yes"/"No" to boolean for API
    bool meetPlaceBool = meetPlace.value == "Yes";
    profileController.updateMeetPlace(meetPlaceBool.toString());
    
    // Also store as boolean in the profile model
    profileController.profile.update((val) {
      val?.meetPlace = meetPlaceBool.toString();
    });

    // Update text controller
    dobController.text = "${dob.day}/${dob.month}/${dob.year}";

    // Navigate to next screen
    Get.to(() => const PositionView());
  }

  // Method to toggle meet place
  void toggleMeetPlace(String value) {
    meetPlace.value = value;
  }

  // Get meet place as boolean
  bool get meetPlaceAsBool => meetPlace.value == "Yes";

  @override
  void onClose() {
    dobController.dispose();
    super.onClose();
  }
}