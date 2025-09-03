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
  Map<int, Room> _roomDetailsCache = {}; // Cache room details by ID
  Room? _selectedRoom;
  bool _loadingRoomDetails = false;

  @override
  void initState() {
    super.initState();
    _roomsFuture = RoomApiService.getRoomsByHotelId(widget.hotelId);
    _roomsFuture.then((rooms) {
      _tabController = TabController(length: rooms.length, vsync: this);
      _tabController!.addListener(_onTabChanged);
      _fetchRoomDetails(rooms[0].id); // Load first room initially
    });
  }

  void _onTabChanged() {
    if (_tabController!.indexIsChanging) return; // ignore during animation
    final index = _tabController!.index;
    _roomsFuture.then((rooms) {
      _fetchRoomDetails(rooms[index].id);
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

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
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
              // Horizontal scrollable tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: rooms.map((room) => Tab(text: room.name)).toList(),
                labelColor: Colors.blue[600],
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue[600],
              ),

              const SizedBox(height: 16),

              // Room details area
              Expanded(
                child:
                    _loadingRoomDetails
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedRoom == null
                        ? const Center(child: Text("Select a room"))
                        : Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedRoom!.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text("Type: ${_selectedRoom!.type}"),
                                Text(
                                  "Price: LKR ${_selectedRoom!.price.toStringAsFixed(2)} per night",
                                ),
                                Text(
                                  "Max Occupancy: ${_selectedRoom!.maxOccupancy}",
                                ),
                                if (_selectedRoom!.amenities.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    "Amenities: ${_selectedRoom!.amenities.join(", ")}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],

                                // Show booking details if available
                                if (_canBookRoom()) ...[
                                  const SizedBox(height: 20),
                                  Card(
                                    color: Colors.blue.shade50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Booking Details',
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
                                          const SizedBox(height: 8),
                                          Text(
                                            'Total: LKR ${(_selectedRoom!.price * widget.checkOutDate!.difference(widget.checkInDate!).inDays).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _navigateToBooking,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      child: const Text('Book This Room'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
