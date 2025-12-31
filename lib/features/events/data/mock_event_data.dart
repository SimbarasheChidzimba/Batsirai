import '../events/domain/event.dart';

class MockEventData {
  static final List<Event> events = [
    // Music Events
    Event(
      id: '1',
      title: 'Jah Prayzah Live in Concert',
      description: 'Join Zimbabwe\'s most celebrated musician Jah Prayzah for an unforgettable night of Afro-fusion and contemporary music. Special guest performers include Ammara Brown and Winky D.',
      images: [
        'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800',
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
      ],
      category: EventCategory.music,
      status: EventStatus.upcoming,
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 14, hours: 5)),
      venueName: 'Harare International Conference Centre',
      venueAddress: 'Samora Machel Avenue, Harare',
      latitude: -17.8340,
      longitude: 31.0525,
      ticketTiers: [
        const TicketTier(
          id: 't1_1',
          name: 'General Admission',
          description: 'Standing area access',
          price: 15.0,
          availableQuantity: 1500,
          totalQuantity: 2000,
        ),
        const TicketTier(
          id: 't1_2',
          name: 'VIP Seated',
          description: 'Reserved seating with better views',
          price: 35.0,
          availableQuantity: 200,
          totalQuantity: 300,
          benefits: ['Reserved seating', 'Fast entry', 'Access to VIP bar'],
        ),
        const TicketTier(
          id: 't1_3',
          name: 'VVIP',
          description: 'Premium experience with meet & greet',
          price: 75.0,
          availableQuantity: 45,
          totalQuantity: 50,
          benefits: [
            'Front row seating',
            'Meet & greet with artists',
            'Complimentary drinks',
            'Exclusive merchandise',
          ],
        ),
      ],
      performers: ['Jah Prayzah', 'Ammara Brown', 'Winky D'],
      tags: ['Music', 'Live Concert', 'Afro-fusion', 'Zimbabwe Music'],
      dressCode: 'Smart Casual',
      isFeatured: true,
      organizerName: 'Military Touch Movement',
      organizerContact: '+263 242 111222',
      attendeeCount: 3500,
    ),

    Event(
      id: '2',
      title: 'Harare International Festival of Arts (HIFA)',
      description: 'Zimbabwe\'s premier arts festival showcasing local and international talent across music, theater, dance, poetry, and visual arts. A week-long celebration of creativity.',
      images: [
        'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800',
        'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800',
      ],
      category: EventCategory.festival,
      status: EventStatus.upcoming,
      startDate: DateTime(2025, 4, 29),
      endDate: DateTime(2025, 5, 4),
      venueName: 'Harare Gardens',
      venueAddress: 'Harare Gardens, Central Harare',
      latitude: -17.8247,
      longitude: 31.0466,
      ticketTiers: [
        const TicketTier(
          id: 't2_1',
          name: 'Day Pass',
          description: 'Single day entry',
          price: 10.0,
          availableQuantity: 5000,
          totalQuantity: 5000,
        ),
        const TicketTier(
          id: 't2_2',
          name: 'Weekend Pass',
          description: 'Saturday & Sunday access',
          price: 18.0,
          availableQuantity: 2000,
          totalQuantity: 2000,
        ),
        const TicketTier(
          id: 't2_3',
          name: 'Full Festival Pass',
          description: 'All 6 days access',
          price: 45.0,
          availableQuantity: 800,
          totalQuantity: 1000,
          benefits: ['6 days access', 'Priority entry', 'Festival merchandise'],
        ),
      ],
      performers: ['Various Local & International Artists'],
      tags: ['Festival', 'Arts', 'Culture', 'Music', 'Theater', 'Multi-day'],
      isFeatured: true,
      organizerName: 'HIFA Trust',
      organizerContact: '+263 242 333444',
      rating: 4.8,
      attendeeCount: 45000,
    ),

    // Nightlife
    Event(
      id: '3',
      title: 'Afrobeats Night at The Book Cafe',
      description: 'Dance the night away to the hottest Afrobeats, Amapiano, and African house music. DJs spinning all night long.',
      images: [
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800',
      ],
      category: EventCategory.nightlife,
      status: EventStatus.upcoming,
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5, hours: 6)),
      venueName: 'The Book Cafe',
      venueAddress: 'Fife Avenue, Harare',
      latitude: -17.8156,
      longitude: 31.0428,
      ticketTiers: [
        const TicketTier(
          id: 't3_1',
          name: 'Early Bird',
          description: 'Entry before 10pm',
          price: 8.0,
          availableQuantity: 100,
          totalQuantity: 150,
        ),
        const TicketTier(
          id: 't3_2',
          name: 'General Entry',
          description: 'Standard entry',
          price: 12.0,
          availableQuantity: 300,
          totalQuantity: 350,
        ),
        const TicketTier(
          id: 't3_3',
          name: 'VIP Table',
          description: 'Reserved table for 6',
          price: 100.0,
          availableQuantity: 8,
          totalQuantity: 10,
          benefits: ['Table for 6', 'Bottle service', 'Priority entry'],
        ),
      ],
      tags: ['Nightlife', 'Afrobeats', 'DJ', 'Dancing'],
      dressCode: 'Smart Casual - No sneakers',
      ageRestriction: 18,
      organizerName: 'The Book Cafe',
      organizerContact: '+263 242 555666',
    ),

    // Food Event
    Event(
      id: '4',
      title: 'Harare Food Festival',
      description: 'Celebrate Zimbabwe\'s culinary diversity! Over 40 food vendors, cooking demonstrations, wine tastings, and live music.',
      images: [
        'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
        'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?w=800',
      ],
      category: EventCategory.food,
      status: EventStatus.upcoming,
      startDate: DateTime.now().add(const Duration(days: 21)),
      endDate: DateTime.now().add(const Duration(days: 21, hours: 8)),
      venueName: 'Sam Levy Village',
      venueAddress: 'Sam Levy Village, Borrowdale, Harare',
      latitude: -17.7845,
      longitude: 31.0712,
      ticketTiers: [
        const TicketTier(
          id: 't4_1',
          name: 'General Admission',
          description: 'Entry + \$10 food voucher',
          price: 12.0,
          availableQuantity: 2000,
          totalQuantity: 2500,
        ),
        const TicketTier(
          id: 't4_2',
          name: 'Foodie Pass',
          description: 'Entry + \$25 food voucher + wine tasting',
          price: 30.0,
          availableQuantity: 400,
          totalQuantity: 500,
          benefits: ['\$25 food voucher', 'Wine tasting', 'Cooking demo access'],
        ),
      ],
      tags: ['Food', 'Festival', 'Family Friendly', 'Wine'],
      isFeatured: true,
      organizerName: 'Harare Food Collective',
      organizerContact: '+263 242 777888',
      rating: 4.6,
    ),

    // Sports
    Event(
      id: '5',
      title: 'Zimbabwe vs South Africa - Cricket Match',
      description: 'International T20 cricket match. Watch the Chevrons take on the Proteas in this exciting fixture.',
      images: [
        'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800',
      ],
      category: EventCategory.sports,
      status: EventStatus.upcoming,
      startDate: DateTime.now().add(const Duration(days: 35)),
      endDate: DateTime.now().add(const Duration(days: 35, hours: 4)),
      venueName: 'Harare Sports Club',
      venueAddress: 'Harare Sports Club, Harare',
      latitude: -17.8167,
      longitude: 31.0447,
      ticketTiers: [
        const TicketTier(
          id: 't5_1',
          name: 'Grass Embankment',
          description: 'Open seating on grass',
          price: 5.0,
          availableQuantity: 5000,
          totalQuantity: 6000,
        ),
        const TicketTier(
          id: 't5_2',
          name: 'Grand Stand',
          description: 'Covered seating',
          price: 15.0,
          availableQuantity: 2000,
          totalQuantity: 2500,
        ),
        const TicketTier(
          id: 't5_3',
          name: 'VIP Hospitality',
          description: 'Premium viewing with food & drinks',
          price: 75.0,
          availableQuantity: 100,
          totalQuantity: 150,
          benefits: ['Premium seating', 'Food & beverage', 'Air conditioning'],
        ),
      ],
      tags: ['Sports', 'Cricket', 'International', 'Live'],
      organizerName: 'Zimbabwe Cricket',
      organizerContact: '+263 242 999000',
    ),

    // Workshop
    Event(
      id: '6',
      title: 'Photography Masterclass with Tamari',
      description: 'Learn professional photography techniques from award-winning photographer Tamari Nyabvure. Covers portraits, landscapes, and event photography.',
      images: [
        'https://images.unsplash.com/photo-1452587925148-ce544e77e70d?w=800',
      ],
      category: EventCategory.workshop,
      status: EventStatus.upcoming,
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7, hours: 4)),
      venueName: 'Creative Hub Harare',
      venueAddress: 'Eastgate Mall, Harare',
      latitude: -17.8278,
      longitude: 31.0522,
      ticketTiers: [
        const TicketTier(
          id: 't6_1',
          name: 'Standard',
          description: 'Workshop attendance + materials',
          price: 35.0,
          availableQuantity: 15,
          totalQuantity: 20,
        ),
        const TicketTier(
          id: 't6_2',
          name: 'Premium',
          description: 'Workshop + 1-on-1 session + certificate',
          price: 65.0,
          availableQuantity: 5,
          totalQuantity: 5,
          benefits: ['Workshop access', '30min 1-on-1 session', 'Certificate'],
        ),
      ],
      performers: ['Tamari Nyabvure'],
      tags: ['Workshop', 'Photography', 'Learning', 'Professional Development'],
      organizerName: 'Creative Hub Harare',
      organizerContact: '+263 242 111333',
    ),

    // Comedy
    Event(
      id: '7',
      title: 'Comedy Nights at Theatre in the Park',
      description: 'Featuring Zimbabwe\'s top comedians including Carl Joshua Ncube, Baba Tencen, and Marabha. A night of non-stop laughter!',
      images: [
        'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=800',
      ],
      category: EventCategory.comedy,
      status: EventStatus.upcoming,
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 10, hours: 3)),
      venueName: 'Theatre in the Park',
      venueAddress: 'Harare Gardens, Harare',
      latitude: -17.8241,
      longitude: 31.0472,
      ticketTiers: [
        const TicketTier(
          id: 't7_1',
          name: 'Standard',
          description: 'General seating',
          price: 12.0,
          availableQuantity: 150,
          totalQuantity: 200,
        ),
        const TicketTier(
          id: 't7_2',
          name: 'VIP',
          description: 'Front row seats',
          price: 25.0,
          availableQuantity: 30,
          totalQuantity: 40,
          benefits: ['Front row', 'Complimentary drink', 'Meet & greet'],
        ),
      ],
      performers: ['Carl Joshua Ncube', 'Baba Tencen', 'Marabha'],
      tags: ['Comedy', 'Stand-up', 'Entertainment'],
      ageRestriction: 16,
      isFeatured: true,
      organizerName: 'Theatre in the Park',
      organizerContact: '+263 242 444555',
      rating: 4.7,
    ),

    // Family Event
    Event(
      id: '8',
      title: 'Kids Fun Day - School Holiday Special',
      description: 'Perfect for families! Bouncy castles, face painting, magic shows, animal petting zoo, and more. Fun activities for children of all ages.',
      images: [
        'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800',
      ],
      category: EventCategory.family,
      status: EventStatus.upcoming,
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 3, hours: 6)),
      venueName: 'Borrowdale Racecourse',
      venueAddress: 'Borrowdale, Harare',
      latitude: -17.7712,
      longitude: 31.0834,
      ticketTiers: [
        const TicketTier(
          id: 't8_1',
          name: 'Child Ticket',
          description: 'Ages 2-12',
          price: 5.0,
          availableQuantity: 1000,
          totalQuantity: 1500,
        ),
        const TicketTier(
          id: 't8_2',
          name: 'Adult Ticket',
          description: 'Ages 13+',
          price: 3.0,
          availableQuantity: 500,
          totalQuantity: 800,
        ),
        const TicketTier(
          id: 't8_3',
          name: 'Family Pass',
          description: '2 adults + 3 children',
          price: 18.0,
          availableQuantity: 200,
          totalQuantity: 300,
          benefits: ['2 adults', '3 children', '\$5 food voucher'],
        ),
      ],
      tags: ['Family', 'Kids', 'Entertainment', 'School Holiday'],
      isFeatured: true,
      organizerName: 'Fun Times Events',
      organizerContact: '+263 242 666777',
      rating: 4.8,
    ),
  ];

  static List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return events
        .where((e) => e.startDate.isAfter(now) && e.status == EventStatus.upcoming)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  static List<Event> getFeaturedEvents() {
    return events.where((e) => e.isFeatured).toList();
  }

  static List<Event> getTodayEvents() {
    return events.where((e) => e.isToday).toList();
  }

  static List<Event> getThisWeekendEvents() {
    return events.where((e) => e.isThisWeekend).toList();
  }

  static List<Event> getEventsByCategory(EventCategory category) {
    return events.where((e) => e.category == category).toList();
  }

  static Event? getEventById(String id) {
    try {
      return events.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Event> getNearbyEvents(double lat, double lng, {double radiusKm = 15.0}) {
    // In production, this would calculate actual distances
    // For mock data, return upcoming events
    return getUpcomingEvents();
  }
}
