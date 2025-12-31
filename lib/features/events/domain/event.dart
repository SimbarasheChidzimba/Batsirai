import 'package:equatable/equatable.dart';

enum EventCategory {
  music,
  sports,
  festival,
  nightlife,
  arts,
  food,
  workshop,
  conference,
  theater,
  exhibition,
  comedy,
  family,
}

enum EventStatus {
  upcoming,
  ongoing,
  soldOut,
  cancelled,
  postponed,
}

class TicketTier {
  final String id;
  final String name;
  final String description;
  final double price;
  final int availableQuantity;
  final int totalQuantity;
  final List<String> benefits;

  const TicketTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.availableQuantity,
    required this.totalQuantity,
    this.benefits = const [],
  });

  bool get isAvailable => availableQuantity > 0;
  bool get isAlmostSoldOut => availableQuantity < totalQuantity * 0.1;
}

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final EventCategory category;
  final EventStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String venueName;
  final String venueAddress;
  final double latitude;
  final double longitude;
  final List<TicketTier> ticketTiers;
  final List<String> performers;
  final List<String> tags;
  final String? dressCode;
  final int? ageRestriction;
  final bool isFeatured;
  final bool isPremiumOnly;
  final String? organizerName;
  final String? organizerContact;
  final double? rating;
  final int? attendeeCount;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.category,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.venueName,
    required this.venueAddress,
    required this.latitude,
    required this.longitude,
    required this.ticketTiers,
    this.performers = const [],
    this.tags = const [],
    this.dressCode,
    this.ageRestriction,
    this.isFeatured = false,
    this.isPremiumOnly = false,
    this.organizerName,
    this.organizerContact,
    this.rating,
    this.attendeeCount,
  });

  String get categoryName {
    switch (category) {
      case EventCategory.music:
        return 'Music';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.festival:
        return 'Festival';
      case EventCategory.nightlife:
        return 'Nightlife';
      case EventCategory.arts:
        return 'Arts';
      case EventCategory.food:
        return 'Food & Drink';
      case EventCategory.workshop:
        return 'Workshop';
      case EventCategory.conference:
        return 'Conference';
      case EventCategory.theater:
        return 'Theater';
      case EventCategory.exhibition:
        return 'Exhibition';
      case EventCategory.comedy:
        return 'Comedy';
      case EventCategory.family:
        return 'Family';
    }
  }

  String get statusText {
    switch (status) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.ongoing:
        return 'Happening Now';
      case EventStatus.soldOut:
        return 'Sold Out';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.postponed:
        return 'Postponed';
    }
  }

  double? get lowestPrice {
    if (ticketTiers.isEmpty) return null;
    return ticketTiers
        .where((tier) => tier.isAvailable)
        .map((tier) => tier.price)
        .reduce((a, b) => a < b ? a : b);
  }

  bool get hasAvailableTickets {
    return ticketTiers.any((tier) => tier.isAvailable);
  }

  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startDate.year == tomorrow.year &&
        startDate.month == tomorrow.month &&
        startDate.day == tomorrow.day;
  }

  bool get isThisWeekend {
    final now = DateTime.now();
    final daysUntilWeekend = DateTime.saturday - now.weekday;
    final nextSaturday = now.add(Duration(days: daysUntilWeekend));
    final nextSunday = nextSaturday.add(const Duration(days: 1));

    return (startDate.isAfter(nextSaturday) || 
            startDate.isAtSameMomentAs(nextSaturday)) &&
           startDate.isBefore(nextSunday.add(const Duration(days: 1)));
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        images,
        category,
        status,
        startDate,
        endDate,
        venueName,
        venueAddress,
        latitude,
        longitude,
        ticketTiers,
        performers,
        tags,
        dressCode,
        ageRestriction,
        isFeatured,
        isPremiumOnly,
        organizerName,
        organizerContact,
        rating,
        attendeeCount,
      ];

  Event copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? images,
    EventCategory? category,
    EventStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? venueName,
    String? venueAddress,
    double? latitude,
    double? longitude,
    List<TicketTier>? ticketTiers,
    List<String>? performers,
    List<String>? tags,
    String? dressCode,
    int? ageRestriction,
    bool? isFeatured,
    bool? isPremiumOnly,
    String? organizerName,
    String? organizerContact,
    double? rating,
    int? attendeeCount,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ticketTiers: ticketTiers ?? this.ticketTiers,
      performers: performers ?? this.performers,
      tags: tags ?? this.tags,
      dressCode: dressCode ?? this.dressCode,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      isFeatured: isFeatured ?? this.isFeatured,
      isPremiumOnly: isPremiumOnly ?? this.isPremiumOnly,
      organizerName: organizerName ?? this.organizerName,
      organizerContact: organizerContact ?? this.organizerContact,
      rating: rating ?? this.rating,
      attendeeCount: attendeeCount ?? this.attendeeCount,
    );
  }
}
