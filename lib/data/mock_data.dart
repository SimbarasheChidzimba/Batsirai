import '../models/restaurant.dart';
import '../models/event.dart';

class MockData {
  static final restaurants = _createRestaurants();
  static final events = _createEvents();

  static List<Restaurant> _createRestaurants() {
    final now = DateTime.now();
    return [
      // Zimbabwe restaurants with real data from document
      _restaurant('r1', 'Victoria 22', 'Fine Dining', ['\$\$\$\$'], 4.7, 245, -17.7845, 31.0769),
      _restaurant('r2', 'Amanzi Restaurant', 'Fine Dining', ['\$\$\$'], 4.6, 189, -17.7912, 31.0654),
      _restaurant('r3', 'The Fishmonger', 'Seafood', ['\$\$\$'], 4.5, 156, -17.7856, 31.0738),
      _restaurant('r4', 'Shangri-La', 'Asian Cuisine', ['\$\$'], 4.4, 312, -17.8012, 31.0892),
      _restaurant('r5', 'Paula\'s Choice', 'Cafe', ['\$\$'], 4.5, 178, -17.8123, 31.0445),
      _restaurant('r6', 'Organikks', 'Vegetarian', ['\$\$'], 4.3, 134, -17.8234, 31.0567),
      _restaurant('r7', 'La Parada', 'Italian', ['\$\$\$'], 4.6, 201, -17.7989, 31.0789),
      _restaurant('r8', 'Mozambik', 'African Cuisine', ['\$\$'], 4.4, 267, -17.8045, 31.0823),
      _restaurant('r9', 'Denga', 'Traditional', ['\$'], 4.2, 145, -17.8312, 31.0456),
      _restaurant('r10', 'Bishops Mistress', 'Cafe', ['\$\$'], 4.5, 189, -17.7923, 31.0678),
      _restaurant('r11', 'RocoMama', 'Fast Food', ['\$\$'], 4.3, 234, -17.8156, 31.0534),
      _restaurant('r12', 'Ocean Basket', 'Seafood', ['\$\$'], 4.4, 198, -17.7834, 31.0712),
      _restaurant('r13', 'Moongate', 'Asian Cuisine', ['\$\$\$'], 4.5, 167, -17.8089, 31.0845),
      _restaurant('r14', 'Bistro 41', 'Fine Dining', ['\$\$\$\$'], 4.7, 156, -17.7956, 31.0723),
      _restaurant('r15', 'Cobblestone', 'Casual Dining', ['\$\$'], 4.2, 123, -17.8223, 31.0589),
      _restaurant('r16', 'Mara Restaurant', 'African Cuisine', ['\$\$'], 4.6, 189, -17.8045, 31.0634),
      _restaurant('r17', 'Pluto', 'Casual Dining', ['\$\$'], 4.3, 145, -17.8178, 31.0478),
      _restaurant('r18', 'Garwe Fairy Cafe', 'Cafe', ['\$'], 4.4, 167, -17.8267, 31.0512),
      _restaurant('r19', 'Cafe Nush', 'Cafe', ['\$'], 4.5, 234, -17.8134, 31.0423),
      _restaurant('r20', 'Three Monkeys', 'Casual Dining', ['\$\$'], 4.2, 178, -17.8089, 31.0556),
      _restaurant('r21', 'Hyatt Regency', 'Fine Dining', ['\$\$\$\$'], 4.8, 289, -17.8292, 31.0522),
      _restaurant('r22', 'Fig and Olive', 'Mediterranean', ['\$\$\$'], 4.6, 156, -17.7912, 31.0689),
      _restaurant('r23', 'Luna Restaurant', 'Italian', ['\$\$\$'], 4.5, 134, -17.8045, 31.0745),
      _restaurant('r24', 'Kelly Kuttings', 'Casual Dining', ['\$\$'], 4.3, 145, -17.8156, 31.0612),
      _restaurant('r25', 'Oak Tree Inn', 'BBQ & Grill', ['\$\$'], 4.4, 189, -17.7834, 31.0678),
      _restaurant('r26', 'Tongfu', 'Chinese', ['\$\$'], 4.3, 167, -17.8223, 31.0534),
      _restaurant('r27', 'Jam Tree', 'Cafe', ['\$'], 4.5, 212, -17.8089, 31.0456),
      _restaurant('r28', 'Oh So Scrumptious', 'Bakery', ['\$'], 4.6, 245, -17.8178, 31.0523),
      _restaurant('r29', 'Salt', 'Contemporary', ['\$\$\$'], 4.7, 178, -17.7923, 31.0712),
      _restaurant('r30', 'The Smokehouse', 'BBQ & Grill', ['\$\$'], 4.5, 201, -17.8045, 31.0589),
    ];
  }

  static Restaurant _restaurant(String id, String name, String category, List<String> cuisines, 
      double rating, int reviews, double lat, double lng) {
    final now = DateTime.now();
    return Restaurant(
      id: id,
      name: name,
      description: 'Discover the finest $category experience in Harare. Book your table today!',
      category: category,
      cuisineTypes: cuisines,
      priceLevel: cuisines.first,
      rating: rating,
      reviewCount: reviews,
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      gallery: ['https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800'],
      address: '$name, Harare, Zimbabwe',
      latitude: lat,
      longitude: lng,
      phone: '+263 4 ${(id.hashCode % 900000 + 100000)}',
      openingHours: {
        'Monday': '10:00 AM - 10:00 PM',
        'Tuesday': '10:00 AM - 10:00 PM',
        'Wednesday': '10:00 AM - 10:00 PM',
        'Thursday': '10:00 AM - 10:00 PM',
        'Friday': '10:00 AM - 11:00 PM',
        'Saturday': '10:00 AM - 11:00 PM',
        'Sunday': '10:00 AM - 9:00 PM',
      },
      amenities: ['WiFi', 'Parking', 'Card Payment'],
      isOpenNow: true,
      acceptsReservations: true,
      isPremium: rating > 4.5,
      isFeatured: rating > 4.6,
      discount: rating > 4.5 ? 15.0 : null,
      isVerified: true,
      createdAt: now.subtract(Duration(days: 180)),
      updatedAt: now,
    );
  }

  static List<Event> _createEvents() {
    final now = DateTime.now();
    return [
      _event('e1', 'Jah Prayzah Live Concert', 'Concerts', now.add(Duration(days: 14)), 
          'Harare International Conference Centre', -17.8171, 31.0473, 4500, 25.0, 50.0),
      _event('e2', 'HIFA Festival 2026', 'Festivals', DateTime(2026, 4, 29), 
          'Harare Gardens', -17.8292, 31.0522, 5000, 0.0, 0.0),
      _event('e3', 'Victoria Falls Carnival', 'Festivals', DateTime(2026, 12, 30), 
          'Victoria Falls', -17.9243, 25.8567, 8000, 50.0, 150.0),
      _event('e4', 'Afro Comedy Night', 'Comedy', now.add(Duration(days: 7)), 
          'The Venue Avondale', -17.8156, 31.0234, 300, 15.0, 30.0),
      _event('e5', 'Zimbabwe Fashion Week', 'Art & Culture', now.add(Duration(days: 21)), 
          'Rainbow Towers', -17.8210, 31.0497, 500, 20.0, 75.0),
      _event('e6', 'Shoko Festival', 'Festivals', DateTime(2026, 9, 24), 
          'Various Venues', -17.8292, 31.0522, 3000, 10.0, 25.0),
      _event('e7', 'Business Networking Event', 'Networking', now.add(Duration(days: 5)), 
          'Meikles Hotel', -17.8254, 31.0521, 200, 20.0, 20.0),
      _event('e8', 'Weekend Food Festival', 'Food & Drink', now.add(Duration(days: 3)), 
          'Borrowdale Race Course', -17.7834, 31.0678, 1000, 5.0, 5.0),
      _event('e9', 'Kids Fun Day', 'Family', now.add(Duration(days: 10)), 
          'Harare Hippodrome', -17.8123, 31.0445, 2000, 0.0, 0.0),
      _event('e10', 'Art Exhibition Opening', 'Art & Culture', now.add(Duration(days: 12)), 
          'National Gallery', -17.8289, 31.0494, 150, 10.0, 10.0),
    ];
  }

  static Event _event(String id, String title, String category, DateTime date, 
      String venue, double lat, double lng, int capacity, double minPrice, double maxPrice) {
    final endDate = date.add(Duration(hours: 6));
    final isFree = minPrice == 0.0;
    
    return Event(
      id: id,
      title: title,
      description: 'Join us for an unforgettable $category experience in Harare!',
      category: category,
      tags: [category, 'Harare', 'Zimbabwe'],
      startDate: date,
      endDate: endDate,
      imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800',
      gallery: ['https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800'],
      venueName: venue,
      venueAddress: '$venue, Harare, Zimbabwe',
      latitude: lat,
      longitude: lng,
      organizer: 'Batsirai Events',
      organizerContact: '+263 4 123456',
      ticketTiers: isFree ? [] : [
        TicketTier(
          id: '${id}_general',
          name: 'General Admission',
          description: 'Standard entry',
          price: minPrice,
          totalAvailable: capacity ~/ 2,
          remaining: capacity ~/ 3,
          isAvailable: true,
        ),
        if (maxPrice > minPrice) TicketTier(
          id: '${id}_vip',
          name: 'VIP',
          description: 'Premium experience with exclusive benefits',
          price: maxPrice,
          totalAvailable: capacity ~/ 4,
          remaining: capacity ~/ 6,
          isAvailable: true,
        ),
      ],
      isFree: isFree,
      isFeatured: date.difference(DateTime.now()).inDays < 15,
      isPremium: maxPrice > 50,
      capacity: capacity,
      ticketsSold: capacity ~/ 3,
      performers: ['Various Artists'],
      amenities: ['Parking', 'Food Available', 'Security'],
      isVerified: true,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }
}
