/// Membership tier model from API
class MembershipTierModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingPeriod; // 'monthly', 'yearly', etc.
  final List<String> benefits;
  final bool isPopular;
  final bool isActive;
  final String? userType; // 'local', 'diaspora', or null for both
  final int? discountPercentage;
  final Map<String, dynamic>? metadata;

  const MembershipTierModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'USD',
    this.billingPeriod = 'monthly',
    this.benefits = const [],
    this.isPopular = false,
    this.isActive = true,
    this.userType,
    this.discountPercentage,
    this.metadata,
  });

  factory MembershipTierModel.fromJson(Map<String, dynamic> json) {
    return MembershipTierModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      billingPeriod: json['billingPeriod']?.toString() ?? 
                     json['billing_period']?.toString() ?? 
                     'monthly',
      benefits: json['benefits'] != null && json['benefits'] is List
          ? (json['benefits'] as List).map((b) => b.toString()).toList()
          : json['features'] != null && json['features'] is List
              ? (json['features'] as List).map((f) => f.toString()).toList()
              : [],
      isPopular: json['isPopular'] == true || json['is_popular'] == true,
      isActive: json['isActive'] != false && json['is_active'] != false,
      userType: json['userType']?.toString() ?? json['user_type']?.toString(),
      discountPercentage: json['discountPercentage'] != null
          ? int.tryParse(json['discountPercentage'].toString())
          : json['discount_percentage'] != null
              ? int.tryParse(json['discount_percentage'].toString())
              : null,
      metadata: json['metadata'] != null && json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'billingPeriod': billingPeriod,
      'benefits': benefits,
      'isPopular': isPopular,
      'isActive': isActive,
      'userType': userType,
      'discountPercentage': discountPercentage,
      'metadata': metadata,
    };
  }
}
