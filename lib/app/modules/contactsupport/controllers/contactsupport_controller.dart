import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsupportController extends GetxController {
  // Navigate to FAQs
  void goToFaqs() {
    Get.snackbar(
      "FAQs",
      "Opening FAQs...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xffFF6B00),
      colorText: Colors.white,
    );
    // TODO: Navigate to FAQs page
  }

  // Report a Problem
  void reportProblem() {
    Get.snackbar(
      "Report Problem",
      "Opening problem report form...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xffFF6B00),
      colorText: Colors.white,
    );
    // TODO: Open problem report form
  }

  // Give Feedback
  void giveFeedback() {
    Get.snackbar(
      "Feedback",
      "Opening feedback form...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xffFF6B00),
      colorText: Colors.white,
    );
    // TODO: Open feedback form
  }

  // Privacy & Security
  void privacySecurity() {
    Get.snackbar(
      "Privacy & Security",
      "Opening privacy settings...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xffFF6B00),
      colorText: Colors.white,
    );
    // TODO: Navigate to privacy page
  }

  // Send Email
  void sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@datingapp.com',
      query: 'subject=Support Request&body=Hello Support Team,',
    );
    
    try {
      if (await launchUrl(emailUri)) {
        print('Email launched successfully');
      } else {
        Get.snackbar(
          "Error",
          "Could not open email app",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not open email: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Make Phone Call
  void makeCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+919876543210');
    
    try {
      if (await launchUrl(phoneUri)) {
        print('Phone call initiated');
      } else {
        Get.snackbar(
          "Error",
          "Could not make phone call",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not make call: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Start Live Chat
  void startChat() {
    Get.snackbar(
      "Live Chat",
      "Connecting to support agent...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xff00A86B),
      colorText: Colors.white,
    );
    // TODO: Implement live chat functionality
  }

  // Open Contact Form
  void openContactForm() {
    Get.snackbar(
      "Contact Form",
      "Opening contact form...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xffFF6B00),
      colorText: Colors.white,
    );
    // TODO: Navigate to contact form page
  }

  @override
  void onClose() {
    super.onClose();
  }
}