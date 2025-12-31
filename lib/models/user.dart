import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profileImageUrl;
  final String membershipTier; // 'free', 'basic', 'standard', 'premium'
  final bool isDiaspora;
  final DateTime? membershipExpiresAt;
  final DateTime createdAt;
  final List<String> favoriteRestaurants;
  final List<String> favoriteEvents;

  const User({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profileImageUrl,
    this.membershipTier = 'free',
    this.isDiaspora = false,
    this.membershipExpiresAt,
    required this.createdAt,
    this.favoriteRestaurants = const [],
    this.favoriteEvents = const [],
  });

  bool get isPremiumMember => membershipTier != 'free';
  bool get isMembershipActive => 
      membershipExpiresAt != null && DateTime.now().isBefore(membershipExpiresAt!);

  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? profileImageUrl,
    String? membershipTier,
    bool? isDiaspora,
    DateTime? membershipExpiresAt,
    DateTime? createdAt,
    List<String>? favoriteRestaurants,
    List<String>? favoriteEvents,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      membershipTier: membershipTier ?? this.membershipTier,
      isDiaspora: isDiaspora ?? this.isDiaspora,
      membershipExpiresAt: membershipExpiresAt ?? this.membershipExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
      favoriteEvents: favoriteEvents ?? this.favoriteEvents,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'],
      profileImageUrl: json['profileImageUrl'],
      membershipTier: json['membershipTier'] ?? 'free',
      isDiaspora: json['isDiaspora'] ?? false,
      membershipExpiresAt: json['membershipExpiresAt'] != null
          ? DateTime.parse(json['membershipExpiresAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      favoriteRestaurants: (json['favoriteRestaurants'] as List?)?.cast<String>() ?? [],
      favoriteEvents: (json['favoriteEvents'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phoneNumber': phoneNumber,
    'fullName': fullName,
    'profileImageUrl': profileImageUrl,
    'membershipTier': membershipTier,
    'isDiaspora': isDiaspora,
    'membershipExpiresAt': membershipExpiresAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'favoriteRestaurants': favoriteRestaurants,
    'favoriteEvents': favoriteEvents,
  };
}
