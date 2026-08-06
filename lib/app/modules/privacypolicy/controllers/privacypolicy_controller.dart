import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrivacypolicyController extends GetxController {
  var isLoading = true.obs;
  var privacyPolicyData = <PrivacyPolicyItem>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrivacyPolicy();
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.privacyPolicy}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> items = data['data'];
          privacyPolicyData.value = items
              .map((item) => PrivacyPolicyItem.fromJson(item))
              .toList();
        } else {
          errorMessage.value = data['message'] ?? 'Failed to load privacy policy';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      print('Error fetching privacy policy: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    fetchPrivacyPolicy();
  }
}

class PrivacyPolicyItem {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  PrivacyPolicyItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrivacyPolicyItem.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}