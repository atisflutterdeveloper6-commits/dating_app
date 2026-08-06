// lib/app/services/upload_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // ✅ Add this import for MediaType
import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:get/get.dart';

class UploadService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  // ✅ Upload any file type (video, pdf, document) — reuses same endpoint as images
  Future<String> uploadFile(File file) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      print('📤 Uploading file via API...');
      print('📤 File: ${file.path}');
      print('📤 Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.uploadMultiple}'),
      );

      request.headers.addAll({
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      final mimeType = _getContentType(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'images', // ✅ backend field name — same as image upload
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final fileUrl = _extractImageUrl(data);
        if (fileUrl != null && fileUrl.isNotEmpty) {
          print('✅ File uploaded successfully: $fileUrl');
          return fileUrl;
        } else {
          throw Exception('No file URL in response');
        }
      } else {
        final errorMsg = data['message'] ?? data['error'] ?? 'Upload failed';
        throw Exception('Upload failed: $errorMsg');
      }
    } catch (e) {
      print('❌ File upload error: $e');
      rethrow;
    }
  }
  
  // ✅ Upload single image using backend API
  Future<String> uploadImage(File imageFile) async {
    try {
      // Get auth token
      final token = _storageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }
      
      // Validate file
      if (!await imageFile.exists()) {
        throw Exception('File does not exist');
      }
      
      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }
      
      print('📤 Uploading image via API...');
      print('📤 File: ${imageFile.path}');
      print('📤 Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      
      // ✅ Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.uploadMultiple}'),
      );
      
      // ✅ Add headers
      request.headers.addAll({
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });
      
      // ✅ Add image file with correct MediaType
      final mimeType = _getContentType(imageFile.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          imageFile.path,
          contentType: MediaType.parse(mimeType), // ✅ Parse String to MediaType
        ),
      );
      
      // ✅ Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: $responseData');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final imageUrl = _extractImageUrl(data);
        if (imageUrl != null && imageUrl.isNotEmpty) {
          print('✅ Image uploaded successfully: $imageUrl');
          return imageUrl;
        } else {
          throw Exception('No image URL in response');
        }
      } else {
        final errorMsg = data['message'] ?? data['error'] ?? 'Upload failed';
        throw Exception('Upload failed: $errorMsg');
      }
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }
  
  // ✅ Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    try {
      if (imageFiles.isEmpty) {
        return [];
      }
      
      final token = _storageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }
      
      // Validate all files
      for (var file in imageFiles) {
        if (!await file.exists()) {
          throw Exception('File does not exist: ${file.path}');
        }
      }
      
      print('📤 Uploading ${imageFiles.length} images via API...');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.uploadMultiple}'),
      );
      
      request.headers.addAll({
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });
      
      // ✅ Add all images with correct MediaType
      for (var file in imageFiles) {
        final mimeType = _getContentType(file.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            file.path,
            contentType: MediaType.parse(mimeType), // ✅ Parse String to MediaType
          ),
        );
      }
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      
      print('📥 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final urls = _extractImageUrls(data);
        print('✅ ${urls.length} images uploaded successfully');
        return urls;
      } else {
        final errorMsg = data['message'] ?? data['error'] ?? 'Upload failed';
        throw Exception('Upload failed: $errorMsg');
      }
    } catch (e) {
      print('❌ Multiple upload error: $e');
      rethrow;
    }
  }
  
  // ✅ Extract single image URL from response
  String? _extractImageUrl(Map<String, dynamic> data) {
    try {
      if (data['success'] == true && data['data'] != null) {
        final dataList = data['data'] as List;
        if (dataList.isNotEmpty) {
          final firstItem = dataList[0] as Map<String, dynamic>;
          return firstItem['url']?.toString();
        }
      }
      
      // Fallback
      return data['url'] ?? data['imageUrl'] ?? data['secure_url'] ?? data['data']?['url']?.toString();
    } catch (e) {
      print('Error extracting URL: $e');
      return null;
    }
  }
  
  // ✅ Extract multiple image URLs from response
  List<String> _extractImageUrls(Map<String, dynamic> data) {
    final List<String> urls = [];
    
    try {
      if (data['success'] == true && data['data'] != null) {
        final dataList = data['data'] as List;
        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            final url = item['url']?.toString();
            if (url != null && url.isNotEmpty) {
              urls.add(url);
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting URLs: $e');
    }
    
    return urls;
  }
  
  // ✅ Get content type as String (will be parsed to MediaType)
  String _getContentType(String filePath) {
    final ext = filePath.toLowerCase();
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) return 'image/jpeg';
    if (ext.endsWith('.png')) return 'image/png';
    if (ext.endsWith('.gif')) return 'image/gif';
    if (ext.endsWith('.webp')) return 'image/webp';
    if (ext.endsWith('.pdf')) return 'application/pdf';
    if (ext.endsWith('.mp4')) return 'video/mp4';
    if (ext.endsWith('.mov')) return 'video/quicktime';
    if (ext.endsWith('.mp3')) return 'audio/mpeg';
    if (ext.endsWith('.aac')) return 'audio/aac';
    if (ext.endsWith('.wav')) return 'audio/wav';
    return 'image/jpeg'; // Default
  }
}