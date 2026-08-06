// lib/app/models/enum_models.dart

// ============================================================
// GENDER MODEL
// ============================================================
class GenderModel {
  final String id;
  final String gender;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final int v;

  GenderModel({
    required this.id,
    required this.gender,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory GenderModel.fromJson(Map<String, dynamic> json) {
    return GenderModel(
      id: json['_id'] ?? '',
      gender: json['gender'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

// ============================================================
// SEXUAL ORIENTATION MODEL
// ============================================================
class SexualOrientationModel {
  final String id;
  final String title;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final int v;

  SexualOrientationModel({
    required this.id,
    required this.title,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SexualOrientationModel.fromJson(Map<String, dynamic> json) {
    return SexualOrientationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

// ============================================================
// POSITION MODEL
// ============================================================
class PositionModel {
  final String id;
  final String title;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final int v;

  PositionModel({
    required this.id,
    required this.title,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

// ============================================================
// LOOKING FOR MODEL
// ============================================================
class LookingForModel {
  final String id;
  final String title;
  final String icon;  // ← ADD THIS LINE
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  LookingForModel({
    required this.id,
    required this.title,
    required this.icon,  // ← ADD THIS LINE
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LookingForModel.fromJson(Map<String, dynamic> json) {
    return LookingForModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',  // ← ADD THIS LINE
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

}