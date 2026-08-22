// lib/app/modules/premium/controllers/premium_controller.dart

import 'dart:convert';
import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PremiumController extends GetxController {
  final StorageService _storage = StorageService();

  // Observable variables
  var isLoading = false.obs;
  var faqList = <FaqItem>[].obs;
  var errorMessage = ''.obs;

  // 🔥 True while the /cancel API call is in flight — use this to disable
  // the button / show a spinner so the user can't double-tap "Yes".
  var isCancelling = false.obs;

  // Auto renewal toggle — kept for UI; API response doesn't expose an
  // auto-renew flag yet, so this stays local-only for now.
  var isAutoRenewalEnabled = true.obs;

  // Premium data — now populated from /user-subscription/me
  var purchaseDate = '-'.obs;
  var nextBillingDate = '-'.obs;
  var amountPaid = '-'.obs;
  var planName = ''.obs;
  var subscriptionStatus = ''.obs;
  var hasActiveSubscription = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';
    await Future.wait([
      fetchSubscriptionData(),
      fetchFaqData(),
    ]);
    isLoading.value = false;
  }

  // 🔥 Fetch real subscription data
 Future<String?> _getFirebaseAuthToken({bool forceRefresh = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ No Firebase user found');
        return _storage.getLoginToken() ?? _storage.getToken();
      }

      bool needsForceRefresh = forceRefresh;
      if (!needsForceRefresh) {
        try {
          final tokenResult = await user.getIdTokenResult(false);
          final expiry = tokenResult.expirationTime;
          if (expiry == null ||
              DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)))) {
            needsForceRefresh = true;
          }
        } catch (_) {
          needsForceRefresh = true;
        }
      }

      final token = await user.getIdToken(needsForceRefresh);
      if (token != null && token.isNotEmpty) {
        await _storage.saveToken(token);
        await _storage.saveLoginToken(token);
      }
      return token;
    } catch (e) {
      print('❌ Error getting Firebase token: $e');
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken(true);
          if (token != null) {
            await _storage.saveToken(token);
            await _storage.saveLoginToken(token);
          }
          return token;
        }
      } catch (e2) {
        print('❌ Force refresh also failed: $e2');
      }
      return _storage.getLoginToken() ?? _storage.getToken();
    }
  }

  // 🔥 Fetch real subscription data — ab 401 pe auto force-refresh + retry karta hai
  Future<void> fetchSubscriptionData() async {
    try {
      var token = await _getFirebaseAuthToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to view your subscription';
        return;
      }

      Future<http.Response> sendRequest(String t) {
        return http.get(
          Uri.parse('${ApiUrls.baseUrl}/v1/api/user-subscription/me'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
      }

      var response = await sendRequest(token);

      // ✅ 401 aane par force refresh karke ek retry
      if (response.statusCode == 401) {
        print('⚠️ 401 on subscription fetch, force refreshing token...');
        final freshToken = await _getFirebaseAuthToken(forceRefresh: true);
        if (freshToken != null && freshToken.isNotEmpty) {
          token = freshToken;
          response = await sendRequest(token);
        }
      }

      print('Subscription Me Response Status: ${response.statusCode}');
      print('Subscription Me Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final sub = UserSubscription.fromJson(json['data']);
          hasActiveSubscription.value = sub.status.toLowerCase() == 'active';

          planName.value = sub.subscriptionPlan?.planName ?? 'Premium';
          subscriptionStatus.value = sub.status;

          purchaseDate.value = _formatDate(sub.startAt);
          nextBillingDate.value = _estimateNextBilling(sub.startAt);

          final displayAmountPaise =                                                                                             
              sub.authAmount > 0 ? sub.authAmount : sub.amount;
          amountPaid.value = '₹${(displayAmountPaise / 100).toStringAsFixed(0)}';
        } else {
          errorMessage.value = json['message'] ?? 'No active subscription found';
        }
      } else if (response.statusCode == 401) {
        // Retry ke baad bhi 401 aaya — session expire ho chuka hai
        errorMessage.value = 'Session expired. Please login again.';
      } else if (response.statusCode == 404) {
        errorMessage.value = 'No active subscription found';
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      print('Error fetching subscription: $e');
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  String _estimateNextBilling(String isoStartDate) {
    try {
      final start = DateTime.parse(isoStartDate);
      final next = DateTime(start.year, start.month + 1, start.day);
      return _formatDate(next.toIso8601String());
    } catch (e) {
      return '-';
    }
  }

  // FAQ fetch — failure here shouldn't block the subscription card
  Future<void> fetchFaqData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}/v1/api/faq'),
        headers: {'Content-Type': 'application/json'},
      );

      print('FAQ Response Status: ${response.statusCode}');
      print('FAQ Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> items = data['data'];
          faqList.value = items.map((item) => FaqItem.fromJson(item)).toList();
          print('FAQ data loaded: ${faqList.length} items');
        }
      }
    } catch (e) {
      print('Error fetching FAQ: $e');
    }
  }

  void toggleAutoRenewal() {
    isAutoRenewalEnabled.value = !isAutoRenewalEnabled.value;
  }

  void retry() {
    _loadInitialData();
  }

  // Shows the confirmation dialog. Actual API call happens in
  // confirmCancelSubscription() below, triggered by the "Yes" button.
  void cancelSubscription() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel your subscription?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          Obx(
            () => TextButton(
              onPressed: isCancelling.value ? null : confirmCancelSubscription,
              child: isCancelling.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Yes'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // 🔥 Calls POST /v1/api/user-subscription/cancel with the Firebase auth
  // token — mirrors the same 401 force-refresh-and-retry pattern used by
  // fetchSubscriptionData(). On success, updates local state and closes
  // both the dialog and (implicitly) reflects "cancelled" on screen.
  Future<void> confirmCancelSubscription() async {
    isCancelling.value = true;
    try {
      var token = await _getFirebaseAuthToken();

      if (token == null || token.isEmpty) {
        Get.back(); // close dialog
        Get.snackbar(
          'Error',
          'Please login to cancel your subscription',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Future<http.Response> sendRequest(String t) {
        return http.post(
          Uri.parse('${ApiUrls.baseUrl}/v1/api/user-subscription/cancel'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
      }

      var response = await sendRequest(token);

      // ✅ 401 aane par force refresh karke ek retry
      if (response.statusCode == 401) {
        print('⚠️ 401 on cancel subscription, force refreshing token...');
        final freshToken = await _getFirebaseAuthToken(forceRefresh: true);
        if (freshToken != null && freshToken.isNotEmpty) {
          token = freshToken;
          response = await sendRequest(token);
        }
      }

      print('Cancel Subscription Response Status: ${response.statusCode}');
      print('Cancel Subscription Response Body: ${response.body}');

      Get.back(); // close the confirmation dialog

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          subscriptionStatus.value = jsonData['data']['status'] ?? 'cancelled';
          hasActiveSubscription.value = false;

          Get.snackbar(
            'Success',
            jsonData['message'] ?? 'Subscription cancelled successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Refresh from backend so purchase/billing/amount fields reflect
          // the latest state (in case backend also clears billing info).
          await fetchSubscriptionData();
        } else {
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Could not cancel subscription',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'Error',
          'No active subscription found to cancel',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else if (response.statusCode == 401) {
        Get.snackbar(
          'Error',
          'Session expired. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error cancelling subscription: $e');
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCancelling.value = false;
    }
  }
}

// ============ MODELS ============

class UserSubscription {
  final String id;
  final String firebaseUid;
  final String phone;
  final SubscriptionPlanInfo? subscriptionPlan;
  final String razorpayPlanId;
  final String razorpaySubscriptionId;
  final int amount; // in paise
  final int authAmount; // in paise
  final String startAt;
  final String status;
  final String createdAt;
  final String updatedAt;

  UserSubscription({
    required this.id,
    required this.firebaseUid,
    required this.phone,
    required this.subscriptionPlan,
    required this.razorpayPlanId,
    required this.razorpaySubscriptionId,
    required this.amount,
    required this.authAmount,
    required this.startAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['_id'] ?? '',
      firebaseUid: json['firebaseUid'] ?? '',
      phone: json['phone'] ?? '',
      subscriptionPlan: json['subscriptionPlan'] != null
          ? SubscriptionPlanInfo.fromJson(json['subscriptionPlan'])
          : null,
      razorpayPlanId: json['razorpayPlanId'] ?? '',
      razorpaySubscriptionId: json['razorpaySubscriptionId'] ?? '',
      amount: json['amount'] ?? 0,
      authAmount: json['authAmount'] ?? 0,
      startAt: json['startAt'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class SubscriptionPlanInfo {
  final String id;
  final String planName;
  final String trialPrice;
  final String priceAfterTrial;

  SubscriptionPlanInfo({
    required this.id,
    required this.planName, 
    required this.trialPrice,
    required this.priceAfterTrial,
  });

  factory SubscriptionPlanInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanInfo(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? 'Premium',
      trialPrice: json['trialPrice'] ?? '0',
      priceAfterTrial: json['priceAfterTrial'] ?? '0',
    );
  }
}

// FAQ Item Model (unchanged)
class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String createdAt;
  final String updatedAt;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['_id'] ?? '',
      question: json['qustion'] ?? '', // API typo preserved intentionally
      answer: json['answer'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}