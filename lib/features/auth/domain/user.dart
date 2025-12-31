import 'package:equatable/equatable.dart';

enum MembershipTier {
  free,
  localBasic,
  localPlus,
  localPremium,
  diasporaBasic,
  diasporaPlus,
  diasporaVip,
}

enum UserType {
  local,
  diaspora,
}

class User extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final UserType userType;
  final MembershipTier membershipTier;
  final DateTime? membershipExpiryDate;
  final DateTime createdAt;
  final List<String> favoriteRestaurantIds;
  final List<String> favoriteEventIds;
  final double totalSavings; // Total savings from discounts

  const User({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    required this.userType,
    required this.membershipTier,
    this.membershipExpiryDate,
    required this.createdAt,
    this.favoriteRestaurantIds = const [],
    this.favoriteEventIds = const [],
    this.totalSavings = 0.0,
  });

  bool get isPremiumMember =>
      membershipTier != MembershipTier.free &&
      (membershipExpiryDate?.isAfter(DateTime.now()) ?? false);

  bool get isMembershipExpired =>
      membershipExpiryDate != null &&
      membershipExpiryDate!.isBefore(DateTime.now());

  String get membershipTierName {
    switch (membershipTier) {
      case MembershipTier.free:
        return 'Free';
      case MembershipTier.localBasic:
        return 'Local Basic';
      case MembershipTier.localPlus:
        return 'Local Plus';
      case MembershipTier.localPremium:
        return 'Local Premium';
      case MembershipTier.diasporaBasic:
        return 'Diaspora Basic';
      case MembershipTier.diasporaPlus:
        return 'Diaspora Plus';
      case MembershipTier.diasporaVip:
        return 'Diaspora VIP';
    }
  }

  double get membershipPrice {
    switch (membershipTier) {
      case MembershipTier.free:
        return 0.0;
      case MembershipTier.localBasic:
        return 5.0;
      case MembershipTier.localPlus:
        return 7.0;
      case MembershipTier.localPremium:
        return 10.0;
      case MembershipTier.diasporaBasic:
        return 5.0;
      case MembershipTier.diasporaPlus:
        return 10.0;
      case MembershipTier.diasporaVip:
        return 19.0;
    }
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        displayName,
        photoUrl,
        userType,
        membershipTier,
        membershipExpiryDate,
        createdAt,
        favoriteRestaurantIds,
        favoriteEventIds,
        totalSavings,
      ];

  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    UserType? userType,
    MembershipTier? membershipTier,
    DateTime? membershipExpiryDate,
    DateTime? createdAt,
    List<String>? favoriteRestaurantIds,
    List<String>? favoriteEventIds,
    double? totalSavings,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      membershipTier: membershipTier ?? this.membershipTier,
      membershipExpiryDate: membershipExpiryDate ?? this.membershipExpiryDate,
      createdAt: createdAt ?? this.createdAt,
      favoriteRestaurantIds: favoriteRestaurantIds ?? this.favoriteRestaurantIds,
      favoriteEventIds: favoriteEventIds ?? this.favoriteEventIds,
      totalSavings: totalSavings ?? this.totalSavings,
    );
  }
}
