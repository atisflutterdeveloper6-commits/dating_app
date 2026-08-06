import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SafetyandpolicyController extends GetxController {
  var isLoading = true.obs;
  var safetyPolicyData = <SafetyPolicyItem>[].obs; // Changed to List
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSafetyPolicy();
  }

  Future<void> fetchSafetyPolicy() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.childPolicy}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final dynamic dataField = data['data'];
          
          // Handle both List and single object responses
          if (dataField is List) {
            // If it's a list, map all items
            safetyPolicyData.value = dataField
                .map((item) => SafetyPolicyItem.fromJson(item))
                .toList();
          } else if (dataField is Map<String, dynamic>) {
            // If it's a single object, add it to the list
            safetyPolicyData.value = [SafetyPolicyItem.fromJson(dataField)];
          } else {
            errorMessage.value = 'Unexpected data format';
          }
        } else {
          errorMessage.value = data['message'] ?? 'Failed to load safety policy';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      print('Error fetching safety policy: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    fetchSafetyPolicy();
  }
}

class SafetyPolicyItem {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  SafetyPolicyItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafetyPolicyItem.fromJson(Map<String, dynamic> json) {
    return SafetyPolicyItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}