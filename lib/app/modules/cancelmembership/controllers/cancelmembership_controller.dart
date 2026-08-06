import 'dart:convert';
import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// TODO: Update this import to your actual ApiUrls file path

/// Model for a single subscription plan item from API
class SubscriptionPlanModel {
  final String id;
  final String backgroundVideo;
  final String mainTitle;
  final String highlightText;
  final String planName;
  final String trialPrice;
  final String trialText;
  final String trialDuration;
  final String priceAfterTrial;
  final String afterTrialText;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.backgroundVideo,
    required this.mainTitle,
    required this.highlightText,
    required this.planName,
    required this.trialPrice,
    required this.trialText,
    required this.trialDuration,
    required this.priceAfterTrial,
    required this.afterTrialText,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['_id']?.toString() ?? '',
      backgroundVideo: json['backgroundVideo']?.toString() ?? '',
      mainTitle: json['mainTitle']?.toString() ?? '',
      highlightText: json['highlightText']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      trialPrice: json['trialPrice']?.toString() ?? '0',
      trialText: json['trialText']?.toString() ?? '',
      trialDuration: json['trialDuration']?.toString() ?? '0',
      priceAfterTrial: json['priceAfterTrial']?.toString() ?? '0',
      afterTrialText: json['afterTrialText']?.toString() ?? '',
      isDeleted: json['isDeleted'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

/// Wrapper for the full API response
class SubscriptionResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<SubscriptionPlanModel> data;

  SubscriptionResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] == true,
      statusCode: json['statusCode'] ?? 0,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CancelmembershipController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// Currently active plan (used to show details on Cancel Membership screen)
  Rx<SubscriptionPlanModel?> subscription = Rx<SubscriptionPlanModel?>(null);

  // Fallback default data in case API fails
  final SubscriptionPlanModel defaultData = SubscriptionPlanModel(
    id: '',
    backgroundVideo: '',
    mainTitle: 'Unlock Premium',
    highlightText: 'Most Popular',
    planName: 'Premium Plus',
    trialPrice: '0',
    trialText: '',
    trialDuration: '0',
    priceAfterTrial: '299',
    afterTrialText: 'then ₹299/month',
    isDeleted: false,
    createdAt: '',
    updatedAt: '',
  );

  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
  }

  Future<void> fetchSubscription() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Update endpoint constant name to match your ApiUrls class
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.subscriptionScreen}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Subscription Response Status: ${response.statusCode}');
      print('Subscription Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final responseData = SubscriptionResponse.fromJson(jsonData);

        if (responseData.success && responseData.data.isNotEmpty) {
          // Pick the most relevant (non-deleted, latest) plan.
          final activePlans =
              responseData.data.where((e) => !e.isDeleted).toList();
          subscription.value =
              activePlans.isNotEmpty ? activePlans.first : responseData.data.first;
        } else {
          errorMessage.value = 'No subscription data available';
          subscription.value = defaultData;
        }
      } else {
        errorMessage.value = 'Failed to load data (${response.statusCode})';
        subscription.value = defaultData;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error fetching subscription: $e');
      subscription.value = defaultData;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancel membership API call (mock — replace with real endpoint when ready)
  var isCancelling = false.obs;

  Future<bool> cancelMembership({
    required String? reason,
    required String feedback,
  }) async {
    try {
      isCancelling.value = true;

      // TODO: Replace with real cancel-membership API call, e.g.:
      // final response = await http.post(
      //   Uri.parse('${ApiUrls.baseUrl}${ApiUrls.cancelMembership}'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'reason': reason, 'feedback': feedback}),
      // );
      // return response.statusCode == 200;

      await Future.delayed(const Duration(seconds: 2)); // simulate call
      return true;
    } catch (e) {
      print('Error cancelling membership: $e');
      return false;
    } finally {
      isCancelling.value = false;
    }
  }
}