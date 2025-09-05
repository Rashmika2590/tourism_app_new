import 'package:flutter/material.dart';
import 'package:tourism_app_new/Models/room_model.dart';
import 'package:tourism_app_new/Screens/testing/Booking/booking_page.dart';
import 'package:tourism_app_new/Services/Api%20Services/Authentication/room_api_service.dart';

class RoomsListScreen extends StatefulWidget {
  final int hotelId;
  final DateTime? checkInDate;
  final String? checkInTime;
  final DateTime? checkOutDate;
  final String? checkOutTime;
  final int? adultCount;
  final int? childrenCount;

  const RoomsListScreen({
    Key? key,
    required this.hotelId,
    this.checkInDate,
    this.checkInTime,
    this.checkOutDate,
    this.checkOutTime,
    this.adultCount,
    this.childrenCount,
  }) : super(key: key);

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen>
    with TickerProviderStateMixin {
  late Future<List<Room>> _roomsFuture;
  TabController? _tabController;
  Map<int, Room> _roomDetailsCache = {};
  Room? _selectedRoom;
  bool _loadingRoomDetails = false;
  int _currentImageIndex = 0;
  Set<String> _selectedAddOns = {};

  // Dummy data for each room type (will be replaced by actual room data)
  final Map<String, List<String>> _roomImages = {
    "Standard": [
      "https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=400",
      "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400",
      "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400",
    ],
    "Deluxe": [
      "https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400",
      "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400",
      "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=400",
      "https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=400",
      "https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400",
    ],
    "Superior": [
      "https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=400",
      "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400",
      "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400",
    ],
    "Suite": [
      "https://images.unsplash.com/photo-1591088398332-8a7791972843?w=400",
      "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400",
      "https://images.unsplash.com/photo-1567767292278-a4f21aa2d36e?w=400",
      "https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=400",
    ],
  };

  final List<Map<String, dynamic>> _defaultAmenities = [
    {"icon": Icons.bed, "text": "Sleeps 2-3 guests"},
    {"icon": Icons.king_bed, "text": "1 King Bed"},
    {"icon": Icons.bathroom, "text": "1 Private Bathroom"},
    {"icon": Icons.hot_tub, "text": "Hot Water"},
    {"icon": Icons.checkroom, "text": "Wardrobe"},
    {"icon": Icons.tv, "text": "Smart TV"},
  ];

  final List<Map<String, dynamic>> _addOns = [
    {"icon": Icons.directions_bike, "title": "Cycling"},
    {"icon": Icons.flight, "title": "Airport Pickup"},
    {"icon": Icons.local_bar, "title": "Minibar"},
    {"icon": Icons.surfing, "title": "Surfing"},
    {"icon": Icons.kitchen, "title": "Kitchen"},
  ];

  final List<Map<String, dynamic>> _selections = [
    {
      "type": "Room (D)",
      "time": "8am - 12pm",
      "pax": "2 pax",
      "price": "LKR 2,400",
    },
    {
      "type": "Fishing",
      "time": "5am - 10pm",
      "pax": "3 pax",
      "price": "LKR 5,400",
    },
    {
      "type": "Picnic",
      "time": "8am - 12pm",
      "pax": "6 pax",
      "price": "LKR 8,200",
    },
  ];

  @override
  void initState() {
    super.initState();
    _roomsFuture = RoomApiService.getRoomsByHotelId(widget.hotelId);
    _roomsFuture.then((rooms) {
      if (rooms.isNotEmpty) {
        _tabController = TabController(length: rooms.length, vsync: this);
        _tabController!.addListener(_onTabChanged);
        _fetchRoomDetails(rooms[0].id);
      }
    });
  }

  void _onTabChanged() {
    if (_tabController!.indexIsChanging) return;
    final index = _tabController!.index;
    _roomsFuture.then((rooms) {
      _fetchRoomDetails(rooms[index].id);
    });
    // Reset image index when switching tabs
    setState(() {
      _currentImageIndex = 0;
    });
  }

  Future<void> _fetchRoomDetails(int roomId) async {
    if (_roomDetailsCache.containsKey(roomId)) {
      setState(() => _selectedRoom = _roomDetailsCache[roomId]);
      return;
    }

    setState(() => _loadingRoomDetails = true);
    try {
      final room = await RoomApiService.getRoomById(roomId);
      _roomDetailsCache[roomId] = room;
      setState(() => _selectedRoom = room);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => _loadingRoomDetails = false);
  }

  bool _canBookRoom() {
    return widget.checkInDate != null &&
        widget.checkInTime != null &&
        widget.checkOutDate != null &&
        widget.checkOutTime != null &&
        widget.adultCount != null &&
        widget.childrenCount != null;
  }

  void _navigateToBooking() {
    if (_selectedRoom == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingScreen(
              room: _selectedRoom!,
              checkInDate: widget.checkInDate!,
              checkInTime: widget.checkInTime!,
              checkOutDate: widget.checkOutDate!,
              checkOutTime: widget.checkOutTime!,
              adultCount: widget.adultCount!,
              childrenCount: widget.childrenCount!,
            ),
      ),
    );
  }

  List<String> _getCurrentRoomImages() {
    if (_selectedRoom == null) return _roomImages["Deluxe"] ?? [];

    // Try to match room type/name to get appropriate images
    String roomType = "Deluxe"; // default
    if (_selectedRoom!.type.toLowerCase().contains("standard")) {
      roomType = "Standard";
    } else if (_selectedRoom!.type.toLowerCase().contains("superior")) {
      roomType = "Superior";
    } else if (_selectedRoom!.type.toLowerCase().contains("suite")) {
      roomType = "Suite";
    }

    return _roomImages[roomType] ?? _roomImages["Deluxe"]!;
  }

  List<Map<String, dynamic>> _getCurrentAmenities() {
    if (_selectedRoom == null || _selectedRoom!.amenities.isEmpty) {
      return _defaultAmenities;
    }

    // Convert room amenities to format with icons
    return _selectedRoom!.amenities.map((amenity) {
      IconData icon = Icons.check_circle;
      if (amenity.toLowerCase().contains("bed"))
        icon = Icons.bed;
      else if (amenity.toLowerCase().contains("bathroom"))
        icon = Icons.bathroom;
      else if (amenity.toLowerCase().contains("tv"))
        icon = Icons.tv;
      else if (amenity.toLowerCase().contains("wifi"))
        icon = Icons.wifi;
      else if (amenity.toLowerCase().contains("ac") ||
          amenity.toLowerCase().contains("air"))
        icon = Icons.ac_unit;

      return {"icon": icon, "text": amenity};
    }).toList();
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Calculates total price of the room based on the difference between
  /// [widget.checkInDate] and [widget.checkOutDate].
  ///
  /// The total price is calculated by multiplying the room price by the
  /// number of days in the stay duration and adding the service fee.
  ///
  /// If the stay duration is 0 days, the total price is set to the room price
  /// plus the service fee.
  /*******  d3f7ee51-90e1-4010-8571-8d6431d16d1f  *******/
  double _calculateTotal() {
    if (!_canBookRoom() || _selectedRoom == null) return 0.0;

    int days = widget.checkOutDate!.difference(widget.checkInDate!).inDays;

    // Ensure at least 1 day
    if (days <= 0) days = 1;

    return _selectedRoom!.price * days + 5;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select My Options"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Room>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No rooms available"));
          }

          final rooms = snapshot.data!;

          return Column(
            children: [
              // Room Types Tabs
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    const Text(
                      "Room Types",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                      indicator: const BoxDecoration(),
                      dividerColor: Colors.transparent,
                      tabs:
                          rooms.asMap().entries.map((entry) {
                            final index = entry.key;
                            final room = entry.value;
                            final isSelected = _tabController?.index == index;

                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40, // increased width
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.teal
                                            : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    room.type,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "≈ ${room.price.toInt()} LKR",
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.teal
                                            : Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Room Details Area
              Expanded(
                child:
                    _loadingRoomDetails
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedRoom == null
                        ? const Center(child: Text("Select a room"))
                        : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Room Image Carousel
                              SizedBox(
                                height: 250,
                                child: PageView.builder(
                                  onPageChanged:
                                      (index) => setState(
                                        () => _currentImageIndex = index,
                                      ),
                                  itemCount: _getCurrentRoomImages().length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            _getCurrentRoomImages()[index],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.3),
                                            ],
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            margin: const EdgeInsets.all(16),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "${_currentImageIndex + 1} / ${_getCurrentRoomImages().length}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Room Description
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "- ${_selectedRoom!.name} - Extra comfort, and premium touches for a relaxed stay.",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // Included Amenities
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Included Amenities",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 6,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 4,
                                          ),
                                      itemCount: _getCurrentAmenities().length,
                                      itemBuilder: (context, index) {
                                        final amenity =
                                            _getCurrentAmenities()[index];
                                        return Row(
                                          children: [
                                            Icon(
                                              amenity["icon"],
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                amenity["text"],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    Text(
                                      "Max Occupancy: ${_selectedRoom!.maxOccupancy} guests",
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        // Show more amenities
                                      },
                                      child: const Text(
                                        "see more....",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {
                                        // Extend stay functionality
                                      },
                                      child: const Text(
                                        "Want to extend your stay? Just tap here.",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Exclusive Add-ons
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Exclusive Add-ons",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children:
                                            _addOns.map((addon) {
                                              final isSelected = _selectedAddOns
                                                  .contains(addon["title"]);
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 12.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (isSelected) {
                                                        _selectedAddOns.remove(
                                                          addon["title"],
                                                        );
                                                      } else {
                                                        _selectedAddOns.add(
                                                          addon["title"],
                                                        );
                                                      }
                                                    });
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              isSelected
                                                                  ? Colors.teal
                                                                  : Colors
                                                                      .grey[300],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          addon["icon"],
                                                          color:
                                                              isSelected
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .grey[600],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        addon["title"],
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // My selections
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "My selections",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children:
                                            _selections.map((selection) {
                                              final isLast =
                                                  _selections.last == selection;
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border:
                                                      isLast
                                                          ? null
                                                          : Border(
                                                            bottom: BorderSide(
                                                              color:
                                                                  Colors
                                                                      .grey[300]!,
                                                            ),
                                                          ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        selection["type"],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        selection["time"],
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        selection["pax"],
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        selection["price"],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 16,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                        color: Colors.teal,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              2,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Show booking details if available
                              if (_canBookRoom()) ...[
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Card(
                                    color: Colors.blue.shade50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current Booking Details',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Check-in: ${widget.checkInDate!.day}/${widget.checkInDate!.month}/${widget.checkInDate!.year} at ${widget.checkInTime!.substring(0, 5)}',
                                          ),
                                          Text(
                                            'Check-out: ${widget.checkOutDate!.day}/${widget.checkOutDate!.month}/${widget.checkOutDate!.year} at ${widget.checkOutTime!.substring(0, 5)}',
                                          ),
                                          Text(
                                            'Guests: ${widget.adultCount!} adults, ${widget.childrenCount!} children',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(
                                height: 100,
                              ), // Space for bottom bar
                            ],
                          ),
                        ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LKR${_calculateTotal().toStringAsFixed(0)} / all inclusive",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Show terms and conditions
                      },
                      child: Text(
                        "Terms & Conditions Apply",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _navigateToBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Proceed",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
