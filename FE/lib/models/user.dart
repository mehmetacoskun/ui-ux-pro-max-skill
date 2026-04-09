import 'dart:convert';

class User {
  final int id;
  final String email;
  final String? adiSoyadi;
  final String? telefonNumarasi;
  final Map<String, dynamic>? userMeta;
  final bool isActive;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    this.adiSoyadi,
    this.telefonNumarasi,
    this.userMeta,
    this.isActive = true,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    dynamic meta = json['user_meta'];
    Map<String, dynamic>? parsedMeta;
    if (meta != null) {
      if (meta is Map) {
        parsedMeta = Map<String, dynamic>.from(meta);
      } else if (meta is String && meta.isNotEmpty) {
        try {
          parsedMeta = Map<String, dynamic>.from(
            jsonDecode(meta) as Map,
          );
        } catch (_) {
          parsedMeta = null;
        }
      }
    }

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      adiSoyadi: json['full_name'] as String?,
      telefonNumarasi: json['phone'] as String?,
      userMeta: parsedMeta,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': adiSoyadi,
      'phone': telefonNumarasi,
      'user_meta': userMeta,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String? get avatarUrl {
    if (userMeta != null && userMeta!.containsKey('avatar_url')) {
      return userMeta!['avatar_url'] as String?;
    }
    return null;
  }
}
