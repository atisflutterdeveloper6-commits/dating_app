// lib/app/models/splash_model.dart

class SplashResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<SplashData> data;

  SplashResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory SplashResponse.fromJson(Map<String, dynamic> json) {
    return SplashResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((item) => SplashData.fromJson(item))
          .toList(),
    );
  }
}

class SplashData {
  final String id;
  final String splashImg;
  final String createdAt;
  final String updatedAt;

  SplashData({
    required this.id,
    required this.splashImg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SplashData.fromJson(Map<String, dynamic> json) {
    return SplashData(
      id: json['_id'] ?? '',
      splashImg: json['splashImg'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}