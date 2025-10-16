import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/availability_model.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/Screens/testing/Booking/booking_page.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/availablility_api_service.dart';
import 'package:tourism_app_new/widgets/terms_condition_widget.dart';

class RoomsListScreen extends StatefulWidget {
  final Hotel hotel;
  final DateTime? checkInDate;
  final String? checkInTime;
  final DateTime? checkOutDate;
  final String? checkOutTime;
  final int? adultCount;
  final int? childrenCount;

  const RoomsListScreen({
    Key? key,
    required this.hotel,
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
  late Future<List<dynamic>> _dataFuture;
  TabController? _tabController;
  Map<int, Room> _roomDetailsCache = {};
  Room? _selectedRoom;
  bool _loadingRoomDetails = false;
  int _currentImageIndex = 0;
  Set<String> _selectedAddOns = {};
  List<Room> _filteredRooms = [];
  Set<int> _availableRoomIds = {};

  // Add-ons without showing prices
  final List<Map<String, dynamic>> _addOns = [
    {"icon": Icons.directions_bike, "title": "Cycling", "price": 1500.0},
    {"icon": Icons.flight, "title": "Airport Pickup", "price": 3000.0},
    {"icon": Icons.local_bar, "title": "Minibar", "price": 2500.0},
    {"icon": Icons.surfing, "title": "Surfing", "price": 4000.0},
    {"icon": Icons.kitchen, "title": "Kitchen", "price": 1000.0},
  ];

  @override
  void initState() {
    super.initState();

    print("=== HOTEL DATA IN ROOMS LIST ===");
    print("Hotel ID: ${widget.hotel.id}");
    print("Hotel Name: ${widget.hotel.name}");
    print(
      "Hotel Cancellation Percentage: ${widget.hotel.cancellationPercentage}",
    );
    print(
      "Hotel cancellationPercentage is NULL: ${widget.hotel.cancellationPercentage == null}",
    );
    print("================================");
    _dataFuture = _fetchRoomsAndAvailability();
    _dataFuture.then((data) {
      final allRooms = data[0] as List<Room>;
      final availability = data[1] as RoomAvailability;
      _availableRoomIds =
          availability
              .getRoomIdsForHotel(widget.hotel.id)
              .map((id) => id.toInt())
              .toSet();

      // Filter rooms properly
      final availableRooms =
          allRooms
              .where((room) => _availableRoomIds.contains(room.id))
              .toList();
      final unavailableRooms =
          allRooms
              .where((room) => !_availableRoomIds.contains(room.id))
              .toList();
      _filteredRooms = availableRooms + unavailableRooms;

      if (_filteredRooms.isNotEmpty) {
        _tabController = TabController(
          length: _filteredRooms.length,
          vsync: this,
        );
        _tabController!.addListener(_onTabChanged);
        // Fetch details for the first room
        _fetchRoomDetails(_filteredRooms[0].id);
      }
    });
  }

  Future<List<dynamic>> _fetchRoomsAndAvailability() async {
    final roomsFuture = RoomApiService.getRoomsByHotelId(widget.hotel.id);
    final availabilityFuture = RoomAvailabilityService.searchAvailability(
      checkInDate: widget.checkInDate!,
      checkInTime: widget.checkInTime!,
      checkOutDate: widget.checkOutDate!,
      checkOutTime: widget.checkOutTime!,
      adultCount: widget.adultCount!,
      childrenCount: widget.childrenCount!,
      state: '', // Not needed for room list screen
    );

    final results = await Future.wait([roomsFuture, availabilityFuture]);
    final List<Room> rooms = results[0] as List<Room>;
    final RoomAvailability availability = results[1] as RoomAvailability;

    // Debug prints
    print("=== HOTEL CANCELLATION DEBUG ===");
    print("Hotel ID: ${widget.hotel.id}");
    print(
      "Hotel cancellation percentage from widget: ${widget.hotel.cancellationPercentage}",
    );
    print("Number of rooms: ${rooms.length}");

    // Ensure rooms have the cancellation percentage
    final updatedRooms =
        rooms.map((room) {
          print(
            "Before - Room ${room.id}: freeCancellation=${room.freeCancellation}, cancellationPercentage=${room.hotelCancellationPercentage}",
          );

          // Use the hotel's cancellation percentage from the widget
          final updatedRoom = room.copyWith(
            hotelCancellationPercentage: widget.hotel.cancellationPercentage,
          );

          print(
            "After - Room ${updatedRoom.id}: freeCancellation=${updatedRoom.freeCancellation}, cancellationPercentage=${updatedRoom.hotelCancellationPercentage}",
          );
          print(
            "Effective price for room ${updatedRoom.id}: ${updatedRoom.effectivePrice}",
          );

          return updatedRoom;
        }).toList();

    print("================================");

    return [updatedRooms, availability];
  }

  void _onTabChanged() {
    if (_tabController!.indexIsChanging) return;
    final index = _tabController!.index;

    // Fetch room details for the currently selected tab
    if (index < _filteredRooms.length) {
      _fetchRoomDetails(_filteredRooms[index].id);
    }

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

  // Helper method to check if selected room is available
  bool _isSelectedRoomAvailable() {
    return _selectedRoom != null &&
        _availableRoomIds.contains(_selectedRoom!.id);
  }

  void _navigateToBooking() {
    if (_selectedRoom == null || !_isSelectedRoomAvailable()) return;

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
              hotel: widget.hotel,
              totalprice: _calculateTotal(),
            ),
      ),
    );
  }

  List<String> _getCurrentRoomImages() {
    if (_selectedRoom == null) return [];

    // Use actual room images from backend
    return _selectedRoom!.images.isNotEmpty
        ? _selectedRoom!.images
        : [
          // Fallback placeholder if no images from backend
          "https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=400",
        ];
  }

  List<Map<String, dynamic>> _getCurrentAmenities() {
    if (_selectedRoom == null || _selectedRoom!.amenities.isEmpty) {
      return [
        {
          "icon": Icons.bed,
          "text": "Sleeps ${_selectedRoom?.maxOccupancy ?? 2} guests",
        },
        {"icon": Icons.bathroom, "text": "Private Bathroom"},
        {"icon": Icons.wifi, "text": "WiFi"},
        {"icon": Icons.ac_unit, "text": "Air Conditioning"},
      ];
    }

    // Convert actual room amenities to format with icons
    return _selectedRoom!.amenities.map((amenity) {
      IconData icon = Icons.check_circle;
      if (amenity.toLowerCase().contains("bed") ||
          amenity.toLowerCase().contains("sleep"))
        icon = Icons.bed;
      else if (amenity.toLowerCase().contains("bathroom") ||
          amenity.toLowerCase().contains("bath"))
        icon = Icons.bathroom;
      else if (amenity.toLowerCase().contains("tv") ||
          amenity.toLowerCase().contains("television"))
        icon = Icons.tv;
      else if (amenity.toLowerCase().contains("wifi") ||
          amenity.toLowerCase().contains("internet"))
        icon = Icons.wifi;
      else if (amenity.toLowerCase().contains("ac") ||
          amenity.toLowerCase().contains("air conditioning"))
        icon = Icons.ac_unit;
      else if (amenity.toLowerCase().contains("kitchen") ||
          amenity.toLowerCase().contains("cooking"))
        icon = Icons.kitchen;
      else if (amenity.toLowerCase().contains("parking"))
        icon = Icons.local_parking;
      else if (amenity.toLowerCase().contains("pool") ||
          amenity.toLowerCase().contains("swim"))
        icon = Icons.pool;
      else if (amenity.toLowerCase().contains("breakfast"))
        icon = Icons.restaurant;
      else if (amenity.toLowerCase().contains("gym") ||
          amenity.toLowerCase().contains("fitness"))
        icon = Icons.fitness_center;

      return {"icon": icon, "text": amenity};
    }).toList();
  }

  double _getAddOnPrice(String addOnTitle) {
    final addOn = _addOns.firstWhere(
      (addon) => addon["title"] == addOnTitle,
      orElse: () => {"price": 0.0},
    );
    return addOn["price"] ?? 0.0;
  }

  double _calculateTotal() {
    if (!_canBookRoom() || _selectedRoom == null) return 0.0;

    Duration duration = widget.checkOutDate!.difference(widget.checkInDate!);
    int hours = duration.inHours;
    if (hours <= 0) hours = 1;

    // Debug prints
    print("=== PRICE CALCULATION DEBUG ===");
    print("Base price: ${_selectedRoom!.price}");
    print("Free cancellation: ${_selectedRoom!.freeCancellation}");
    print(
      "Cancellation percentage: ${_selectedRoom!.hotelCancellationPercentage}",
    );
    print("Effective price: ${_selectedRoom!.effectivePrice}");
    print("Hours: $hours");

    double roomTotal = _selectedRoom!.effectivePrice * hours;
    double serviceCharge = roomTotal * 0.0;

    print("Room total: $roomTotal");
    print("Service charge: $serviceCharge");

    double addOnsTotal = 0.0;
    for (String addOnTitle in _selectedAddOns) {
      double addOnPrice = _getAddOnPrice(addOnTitle);
      addOnsTotal += addOnPrice;
      print("Add-on '$addOnTitle': $addOnPrice");
    }

    double total = roomTotal + serviceCharge + addOnsTotal;
    print("Final total: $total");
    print("===============================");

    return total;
  }

  List<Map<String, dynamic>> _buildMySelections() {
    List<Map<String, dynamic>> selections = [];

    // Add room selection if booking details are available
    if (_canBookRoom() && _selectedRoom != null) {
      Duration duration = widget.checkOutDate!.difference(widget.checkInDate!);
      int hours = duration.inHours;
      if (hours <= 0) hours = 1;

      double roomTotal = _selectedRoom!.effectivePrice * hours;

      selections.add({
        "type": "${_selectedRoom!.type} Room",
        "checkIn":
            "${widget.checkInDate!.day}/${widget.checkInDate!.month}/${widget.checkInDate!.year} ${widget.checkInTime!.substring(0, 5)}",
        "checkOut":
            "${widget.checkOutDate!.day}/${widget.checkOutDate!.month}/${widget.checkOutDate!.year} ${widget.checkOutTime!.substring(0, 5)}",
        "guests": "    ${widget.adultCount! + widget.childrenCount!}",
        "price": "LKR ${roomTotal.toStringAsFixed(0)}",
        "isRoom": true,
      });
    }

    // Add selected add-ons
    for (String addOnTitle in _selectedAddOns) {
      double addOnPrice = _getAddOnPrice(addOnTitle);
      selections.add({
        "type": addOnTitle,
        "checkIn":
            _canBookRoom()
                ? "${widget.checkInDate!.day}/${widget.checkInDate!.month}/${widget.checkInDate!.year} ${widget.checkInTime!.substring(0, 5)}"
                : "TBD",
        "checkOut":
            _canBookRoom()
                ? "${widget.checkOutDate!.day}/${widget.checkOutDate!.month}/${widget.checkOutDate!.year} ${widget.checkOutTime!.substring(0, 5)}"
                : "TBD",
        "guests":
            _canBookRoom()
                ? "     ${widget.adultCount! + widget.childrenCount!}"
                : "TBD",
        "price": "LKR ${addOnPrice.toStringAsFixed(0)}",
        "isRoom": false,
      });
    }

    return selections;
  }

  bool _showAllAmenities = false;

  // Safe function to get displayed amenities
  List<Map<String, dynamic>> get _displayedAmenities {
    final amenities = _getCurrentAmenities();
    if (_showAllAmenities) {
      return amenities;
    } else {
      return amenities.take(4).toList(); // Show only first 4
    }
  }

  Widget _buildAmenitiesGrid() {
    final displayedItems = _displayedAmenities;
    if (displayedItems.isEmpty) return const SizedBox.shrink();

    // Calculate number of rows needed (2 columns)
    int rowCount = (displayedItems.length / 2).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        int firstIndex = rowIndex * 2;
        int secondIndex = firstIndex + 1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              // First column item
              Expanded(child: _buildAmenityItem(displayedItems[firstIndex])),
              const SizedBox(width: 40), // Spacing between columns
              // Second column item (if exists)
              if (secondIndex < displayedItems.length)
                Expanded(child: _buildAmenityItem(displayedItems[secondIndex]))
              else
                const Expanded(child: SizedBox()), // Empty space for alignment
            ],
          ),
        );
      }),
    );
  }

  // Helper function to build individual amenity item
  Widget _buildAmenityItem(Map<String, dynamic> amenity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(amenity["icon"], size: 18, color: AppColors.mainGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            amenity["text"] ?? "Unknown amenity",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amenities = _getCurrentAmenities();
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
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No rooms available"));
          }

          final allRooms = snapshot.data![0] as List<Room>;
          final availability = snapshot.data![1] as RoomAvailability;
          final availableRoomIds = availability.getRoomIdsForHotel(
            widget.hotel.id,
          );

          final availableRooms =
              allRooms
                  .where((room) => availableRoomIds.contains(room.id))
                  .toList();
          final unavailableRooms =
              allRooms
                  .where((room) => !availableRoomIds.contains(room.id))
                  .toList();
          final rooms = availableRooms + unavailableRooms;

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
                            final isAvailable = availableRoomIds.contains(
                              room.id,
                            );

                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? (isAvailable
                                                ? AppColors.mainGreen
                                                : Colors.grey)
                                            : (isAvailable
                                                ? Colors.grey[300]
                                                : Colors.grey[200]),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    room.type,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : (isAvailable
                                                  ? Colors.black
                                                  : Colors.grey[500]),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  () {
                                    if (!isAvailable) return "Unavailable";

                                    if (_selectedRoom == null) {
                                      return "≈ ${room.effectivePrice.toInt()} LKR";
                                    }

                                    final priceDiff =
                                        room.price - _selectedRoom!.price;
                                    if (priceDiff == 0) {
                                      return "≈ ${room.price.toInt()} LKR";
                                    } else if (priceDiff > 0) {
                                      return "+${priceDiff.toInt()} LKR";
                                    } else {
                                      return "${priceDiff.toInt()} LKR";
                                    }
                                  }(),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? (isAvailable
                                                ? Colors.teal
                                                : Colors.red)
                                            : Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedRoom!.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedRoom!.description,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Max Occupancy: ${_selectedRoom!.maxOccupancy} guests",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),

                              // Included Amenities
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: const Text(
                                  "Included Amenities",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    child: Column(
                                      children: [
                                        // Handle empty amenities
                                        if (amenities.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16.0,
                                            ),
                                            child: Text(
                                              "No amenities available",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          )
                                        else
                                          _buildAmenitiesGrid(),

                                        // Show "see more" button only if there are more than 4 amenities
                                        if (amenities.length > 4 &&
                                            !_showAllAmenities)
                                          GestureDetector(
                                            onTap:
                                                () => setState(
                                                  () =>
                                                      _showAllAmenities = true,
                                                ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                "See more...",
                                                style: TextStyle(
                                                  color: AppColors.mainGreen,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),

                                        // Show "see less" button only when expanded and there are more than 4
                                        if (_showAllAmenities &&
                                            amenities.length > 4)
                                          GestureDetector(
                                            onTap:
                                                () => setState(
                                                  () =>
                                                      _showAllAmenities = false,
                                                ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                "See less",
                                                style: TextStyle(
                                                  color: AppColors.mainGreen,
                                                  fontSize: 14,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

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
                                                                  ? AppColors
                                                                      .mainGreen
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
                                child: const Text(
                                  "My selections",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child:
                                            _buildMySelections().isEmpty
                                                ? Padding(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "No selections made yet",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                : Column(
                                                  children:
                                                      _buildMySelections().asMap().entries.map((
                                                        entry,
                                                      ) {
                                                        final index = entry.key;
                                                        final selection =
                                                            entry.value;
                                                        final isLast =
                                                            index ==
                                                            _buildMySelections()
                                                                    .length -
                                                                1;

                                                        return Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 12,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            border:
                                                                isLast
                                                                    ? null
                                                                    : Border(
                                                                      bottom: BorderSide(
                                                                        color:
                                                                            Colors.grey[300]!,
                                                                      ),
                                                                    ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Top Row: Type + Remove button
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      selection["type"],
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  if (!selection["isRoom"])
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        setState(() {
                                                                          _selectedAddOns.remove(
                                                                            selection["type"],
                                                                          );
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                        width:
                                                                            20,
                                                                        height:
                                                                            20,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              AppColors.mainGreen,
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                4,
                                                                              ),
                                                                        ),
                                                                        child: const Icon(
                                                                          Icons
                                                                              .remove,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              // Info Row: Check-in / Check-out / Guests / Price
                                                              Row(
                                                                children: [
                                                                  _buildInfoColumn(
                                                                    "Check-in",
                                                                    selection["checkIn"],
                                                                    flex: 2,
                                                                  ),
                                                                  _buildInfoColumn(
                                                                    "Check-out",
                                                                    selection["checkOut"],
                                                                    flex: 2,
                                                                  ),
                                                                  _buildInfoColumn(
                                                                    "Guests",
                                                                    selection["guests"],
                                                                    flex: 1,
                                                                  ),
                                                                  _buildInfoColumn(
                                                                    "Price",
                                                                    selection["price"],
                                                                    flex: 1,
                                                                    alignEnd:
                                                                        true,
                                                                    color:
                                                                        Colors
                                                                            .teal,
                                                                  ),
                                                                ],
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
                              ),

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
                      "LKR ${_calculateTotal().toStringAsFixed(0)} / all inclusive",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // ignore: unnecessary_null_comparison
                    widget.hotel != null
                        ? TermsConditionsWidget.buildTermsButton(
                          context: context,
                          terms: widget.hotel.terms,
                          text: "Terms & Conditions Apply",
                        )
                        : GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Terms not available'),
                              ),
                            );
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
                onPressed:
                    _selectedRoom != null && _isSelectedRoomAvailable()
                        ? _navigateToBooking
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedRoom != null && _isSelectedRoomAvailable()
                          ? AppColors.mainGreen
                          : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  _selectedRoom != null && !_isSelectedRoomAvailable()
                      ? "Unavailable"
                      : "Proceed",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for info columns
  Widget _buildInfoColumn(
    String title,
    String value, {
    int flex = 1,
    bool alignEnd = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
