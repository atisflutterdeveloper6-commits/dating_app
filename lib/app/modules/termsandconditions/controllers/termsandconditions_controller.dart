import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
 // Adjust import path as needed

class TermsandconditionsController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var termsData = <TermsItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTermsAndConditions();
  }

  Future<void> fetchTermsAndConditions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.termsAndConditions}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> dataList = responseData['data'];
          termsData.value = dataList.map((item) {
            return TermsItem(
              id: item['_id'] ?? '',
              content: item['content'] ?? '',
              createdAt: item['createdAt'] ?? '',
              updatedAt: item['updatedAt'] ?? '',
            );
          }).toList();
        } else {
          errorMessage.value = responseData['message'] ?? 'Failed to load terms data';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Network error: Unable to connect to server';
      debugPrint('Error fetching terms: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    fetchTermsAndConditions();
  }
}

class TermsItem {
  final String id;
  final String content;
  final String createdAt;
  final String updatedAt;

  TermsItem({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}