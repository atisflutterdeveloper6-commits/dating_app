import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HelpandsupportController extends GetxController {
  var isLoading = true.obs;
  var helpData = <HelpItem>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHelpData();
  }

  Future<void> fetchHelpData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.helpCenter}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final dynamic dataField = data['data'];
          
          if (dataField is List) {
            helpData.value = dataField
                .map((item) => HelpItem.fromJson(item))
                .toList();
          } else if (dataField is Map<String, dynamic>) {
            helpData.value = [HelpItem.fromJson(dataField)];
          } else {
            // If data format is unexpected, use fallback data
            _useFallbackData();
          }
        } else {
          // If API returns error, use fallback data
          _useFallbackData();
        }
      } else if (response.statusCode == 404) {
        // Endpoint not found - use fallback data
        errorMessage.value = 'Help Center content is currently being updated. Please check back later.';
        _useFallbackData();
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        _useFallbackData();
      }
    } catch (e) {
      errorMessage.value = 'Network error: Unable to connect to server';
      print('Error fetching help data: $e');
      _useFallbackData();
    } finally {
      isLoading.value = false;
    }
  }

  void _useFallbackData() {
    // Fallback data in case API fails
    helpData.value = [
      HelpItem(
        id: '1',
        title: 'Need Assistance? We\'re Here to Help!',
        content: 'Welcome to Vibely\'s Help & Support Center. If you have any questions, concerns, or need assistance with anything related to the app, you\'re in the right place. Our team is dedicated to ensuring you have a smooth and enjoyable experience on Vibely.',
      ),
      HelpItem(
        id: '2',
        title: 'Frequently Asked Questions (FAQs)',
        content: 'Browse through our comprehensive FAQs to find quick answers to common questions about using the app, profile setup, matching, chatting, and more.',
      ),
      HelpItem(
        id: '3',
        title: 'Contact Us',
        content: 'If you can\'t find the information you\'re looking for in our FAQs, feel free to reach out to us directly. We\'re here to assist you with any specific inquiries you may have.\n\nYou can contact us through the app\'s \'Contact Support\' feature or by emailing our support team at support@vibelyapp.com.',
      ),
      HelpItem(
        id: '4',
        title: 'User Safety and Privacy',
        content: 'Your safety and privacy are our top priorities. If you encounter any suspicious behavior or need assistance with privacy settings, please let us know.',
      ),
    ];
  }

  void retry() {
    fetchHelpData();
  }
}

class HelpItem {
  final String id;
  final String title;
  final String content;
  final String? createdAt;
  final String? updatedAt;

  HelpItem({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory HelpItem.fromJson(Map<String, dynamic> json) {
    return HelpItem(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}