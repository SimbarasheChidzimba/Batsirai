import 'package:flutter/foundation.dart';

@immutable
class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String restaurantId;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final int helpfulCount;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.restaurantId,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    this.helpfulCount = 0,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    userImage: json['userImage'],
    restaurantId: json['restaurantId'],
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'],
    images: (json['images'] as List?)?.cast<String>() ?? [],
    createdAt: DateTime.parse(json['createdAt']),
    helpfulCount: json['helpfulCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userImage': userImage,
    'restaurantId': restaurantId,
    'rating': rating,
    'comment': comment,
    'images': images,
    'createdAt': createdAt.toIso8601String(),
    'helpfulCount': helpfulCount,
  };
}
