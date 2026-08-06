class ProfileModel {
  String? id;
  String? firstName;
  String? lastName;
  String? nickName;
  List<dynamic>? photos;
  String? birthday;
  String? gender;
  bool? showGender;
  String? position;
  String? sexualOrientation;
  bool? showOrientation;
  String? interestedIn;
  String? lookingFor;
  String? meetPlace;
  String? bio;
  String? phone;
  String? height;
  String? weight;
  String? createdAt;
  String? updatedAt;
  bool? isVerified;
  List<String>? likedProfiles;
  List<String>? savedProfiles;
  List<String>? blockedProfiles;
  String? selfie;
  String? document;
  String? location;
  
  // ✅ ADD THIS: Like count field
  int? likeCount;

  ProfileModel({
    this.id,
    this.firstName,
    this.lastName,
    this.nickName,
    this.photos,
    this.birthday,
    this.gender,
    this.showGender,
    this.position,
    this.sexualOrientation,
    this.showOrientation,
    this.interestedIn,
    this.lookingFor,
    this.meetPlace,
    this.bio,
    this.phone,
    this.height,
    this.weight,
    this.createdAt,
    this.updatedAt,
    this.isVerified,
    this.likedProfiles,
    this.savedProfiles,
    this.blockedProfiles,
    this.selfie,
    this.document,
    this.location,
    this.likeCount, // ✅ ADD THIS
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (nickName != null) data['nickName'] = nickName;
    if (photos != null && photos!.isNotEmpty) {
      data['photos'] = photos;
    } else {
      data['photos'] = [];
    }
    if (birthday != null) data['birthday'] = birthday;
    if (gender != null) data['gender'] = gender;
    if (showGender != null) data['showGender'] = showGender;
    if (position != null) data['position'] = position;
    if (sexualOrientation != null) data['sexOrientation'] = sexualOrientation;
    if (showOrientation != null) data['showOrientation'] = showOrientation;
    if (interestedIn != null) data['interest'] = interestedIn;
    if (lookingFor != null) data['looking'] = lookingFor;
    if (meetPlace != null) data['placeToMeet'] = meetPlace;
    if (bio != null) data['bio'] = bio;
    if (phone != null) data['phone'] = phone;
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (location != null) data['location'] = location;
    if (likeCount != null) data['likes'] = likeCount; // ✅ ADD THIS

    return data;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String? phoneValue;
    if (json['phone'] != null) {
      if (json['phone'] is int) {
        phoneValue = json['phone'].toString();
      } else if (json['phone'] is String) {
        phoneValue = json['phone'];
      } else {
        phoneValue = json['phone'].toString();
      }
    }

    List<dynamic>? photoList;
    if (json['photos'] != null && json['photos'] is List) {
      photoList = [];
      for (var item in json['photos']) {
        if (item is String) {
          photoList.add(item);
        } else if (item is Map) {
          photoList.add(item);
        } else {
          photoList.add(item.toString());
        }
      }
    }

    String? getNestedId(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map) {
        return value['_id']?.toString() ?? value['id']?.toString();
      }
      return value.toString();
    }

    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    // ✅ Extract like count
    int? likeCount;
    if (json['likes'] != null) {
      if (json['likes'] is int) {
        likeCount = json['likes'] as int;
      } else if (json['likes'] is String) {
        likeCount = int.tryParse(json['likes'] as String);
      } else if (json['likes'] is num) {
        likeCount = (json['likes'] as num).toInt();
      }
    }

    // If likes is 0 but likedBy has items, use likedBy length
    if ((likeCount == null || likeCount == 0) && json['likedBy'] != null && json['likedBy'] is List) {
      final likedBy = json['likedBy'] as List;
      if (likedBy.isNotEmpty) {
        likeCount = likedBy.length;
      }
    }

    return ProfileModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      nickName: json['nickName']?.toString(),
      photos: photoList,
      birthday: json['birthday']?.toString(),
      gender: getNestedId(json['gender']),
      showGender: json['showGender'] as bool?,
      position: getNestedId(json['position']),
      sexualOrientation: getNestedId(json['sexOrientation']),
      showOrientation: json['showOrientation'] as bool?,
      interestedIn: json['interest']?.toString(),
      lookingFor: getNestedId(json['looking']),
      meetPlace: json['placeToMeet']?.toString(),
      bio: json['bio']?.toString(),
      phone: phoneValue,
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      isVerified: json['isVerified'] as bool?,
      likedProfiles: parseStringList(json['likedProfiles']),
      savedProfiles: parseStringList(json['savedProfiles']),
      blockedProfiles: parseStringList(json['blockedProfiles']),
      selfie: json['selfie']?.toString(),
      document: json['document']?.toString(),
      location: json['location']?.toString(),
      likeCount: likeCount ?? 0, // ✅ ADD THIS
    );
  }

  // Helper methods
  String? getProfileImage() {
    try {
      if (photos != null && photos!.isNotEmpty) {
        final firstPhoto = photos!.first;
        
        if (firstPhoto is String) {
          return firstPhoto.isNotEmpty ? firstPhoto : null;
        } else if (firstPhoto is Map) {
          if (firstPhoto['image'] != null) {
            return firstPhoto['image'].toString();
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<String> getAllProfileImages() {
    List<String> imageUrls = [];
    try {
      if (photos != null && photos!.isNotEmpty) {
        for (var photo in photos!) {
          if (photo is String && photo.isNotEmpty) {
            imageUrls.add(photo);
          } else if (photo is Map && photo['image'] != null) {
            imageUrls.add(photo['image'].toString());
          }
        }
      }
    } catch (e) {
      print('❌ Error getting all profile images: $e');
    }
    return imageUrls;
  }

  String getFullName() {
    String name = '';
    if (firstName != null && firstName!.isNotEmpty) {
      name += firstName!;
    }
    if (lastName != null && lastName!.isNotEmpty) {
      if (name.isNotEmpty) name += ' ';
      name += lastName!;
    }
    return name.trim().isNotEmpty ? name.trim() : nickName ?? 'User';
  }

  int? getAge() {
    if (birthday != null && birthday!.isNotEmpty) {
      try {
        final birthdayDate = DateTime.parse(birthday!);
        final today = DateTime.now();
        int age = today.year - birthdayDate.year;
        if (today.month < birthdayDate.month || 
            (today.month == birthdayDate.month && today.day < birthdayDate.day)) {
          age--;
        }
        return age;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  bool get hasPhotos => photos != null && photos!.isNotEmpty;

  bool get isProfileComplete {
    return firstName != null &&
        firstName!.isNotEmpty &&
        lastName != null &&
        lastName!.isNotEmpty &&
        hasPhotos &&
        birthday != null &&
        birthday!.isNotEmpty &&
        gender != null &&
        gender!.isNotEmpty &&
        position != null &&
        position!.isNotEmpty &&
        bio != null &&
        bio!.isNotEmpty;
  }

  ProfileModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? nickName,
    List<dynamic>? photos,
    String? birthday,
    String? gender,
    bool? showGender,
    String? position,
    String? sexualOrientation,
    bool? showOrientation,
    String? interestedIn,
    String? lookingFor,
    String? meetPlace,
    String? bio,
    String? phone,
    String? height,
    String? weight,
    String? createdAt,
    String? updatedAt,
    bool? isVerified,
    List<String>? likedProfiles,
    List<String>? savedProfiles,
    List<String>? blockedProfiles,
    String? selfie,
    String? document,
    String? location,
    int? likeCount, // ✅ ADD THIS
  }) {
    return ProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickName: nickName ?? this.nickName,
      photos: photos ?? this.photos,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      showGender: showGender ?? this.showGender,
      position: position ?? this.position,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      showOrientation: showOrientation ?? this.showOrientation,
      interestedIn: interestedIn ?? this.interestedIn,
      lookingFor: lookingFor ?? this.lookingFor,
      meetPlace: meetPlace ?? this.meetPlace,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      likedProfiles: likedProfiles ?? this.likedProfiles,
      savedProfiles: savedProfiles ?? this.savedProfiles,
      blockedProfiles: blockedProfiles ?? this.blockedProfiles,
      selfie: selfie ?? this.selfie,
      document: document ?? this.document,
      location: location ?? this.location,
      likeCount: likeCount ?? this.likeCount, // ✅ ADD THIS
    );
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, location: $location, likeCount: $likeCount, photos: ${photos?.length ?? 0})';
  }
}