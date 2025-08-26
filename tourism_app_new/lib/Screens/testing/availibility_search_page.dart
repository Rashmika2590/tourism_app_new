import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app_new/core/services/api_service.dart';
import 'package:tourism_app_new/models/availability_model.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/Screens/testing/hotel_detail_page.dart';

class AvailabilitySearchScreen extends StatefulWidget {
  const AvailabilitySearchScreen({Key? key}) : super(key: key);

  @override
  State<AvailabilitySearchScreen> createState() =>
      _AvailabilitySearchScreenState();
}

class _AvailabilitySearchScreenState extends State<AvailabilitySearchScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers and variables
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  TimeOfDay _checkInTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 11, minute: 0);
  int _adultCount = 1;
  int _childrenCount = 0;
  String? _selectedState;

  // Location search
  final TextEditingController _locationController = TextEditingController();
  double? _latitude;
  double? _longitude;
  double _maxDistanceKm = 10.0;

  // Search results
  List<HotelWithAvailability> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  // Keep last used searchParams so we can pass it to details page
  AvailabilitySearchParams? _lastSearchParams;

  // State options - update these based on your needs
  final List<String> _stateOptions = [
    'Western Province',
    'Central Province',
    'Southern Province',
    'Northern Province',
    'Eastern Province',
    'North Western Province',
    'North Central Province',
    'Uva Province',
    'Sabaragamuwa Province',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isCheckIn
              ? (_checkInDate ?? DateTime.now())
              : (_checkOutDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Ensure check-out is after check-in
          if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
            _checkOutDate = picked.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _checkInTime : _checkOutTime,
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _searchAvailability() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = false;
      _errorMessage = null;
    });

    try {
      final searchParams = AvailabilitySearchParams(
        checkInDate: _checkInDate!,
        checkInTime: _formatTime(_checkInTime),
        checkOutDate: _checkOutDate!,
        checkOutTime: _formatTime(_checkOutTime),
        adultCount: _adultCount,
        childrenCount: _childrenCount,
        state: _selectedState,
        latitude: _latitude,
        longitude: _longitude,
        maxDistanceKm: _maxDistanceKm,
      );

      // Save for navigation
      _lastSearchParams = searchParams;

      print('Searching with params: $searchParams');

      // Use the method that gets full hotel and room details
      final results = await ApiService.searchAvailabilityWithFullDetails(
        searchParams,
      );

      // Sort results: more available rooms first, then cheapest available room price
      results.sort((a, b) {
        final cmpRooms = b.availableRoomCount.compareTo(a.availableRoomCount);
        if (cmpRooms != 0) return cmpRooms;

        final aMin =
            (a.availableRooms != null && a.availableRooms!.isNotEmpty)
                ? _getMinPrice(a.availableRooms!)
                : double.infinity;
        final bMin =
            (b.availableRooms != null && b.availableRooms!.isNotEmpty)
                ? _getMinPrice(b.availableRooms!)
                : double.infinity;

        return aMin.compareTo(bMin);
      });

      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isLoading = false;
      });

      print('Found ${results.length} hotels with availability');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasSearched = true;
        _searchResults = [];
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _getMinPrice(List<Room> rooms) {
    if (rooms.isEmpty) return 0.0;
    final prices = rooms.map((r) => r.price).toList();
    if (prices.isEmpty) return 0.0;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hotels'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Form
          Expanded(
            flex: _hasSearched ? 1 : 2,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Search Available Hotels',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),

                        // Check-in and Check-out dates
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateTimeSelector(
                                'Check-in',
                                _checkInDate,
                                _checkInTime,
                                () => _selectDate(context, true),
                                () => _selectTime(context, true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateTimeSelector(
                                'Check-out',
                                _checkOutDate,
                                _checkOutTime,
                                () => _selectDate(context, false),
                                () => _selectTime(context, false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Guest count
                        Row(
                          children: [
                            Expanded(
                              child: _buildCounterField(
                                'Adults',
                                _adultCount,
                                (value) => setState(() => _adultCount = value),
                                1,
                                10,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCounterField(
                                'Children',
                                _childrenCount,
                                (value) =>
                                    setState(() => _childrenCount = value),
                                0,
                                10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Location filters
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'State/Province',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedState,
                          items:
                              _stateOptions.map((state) {
                                return DropdownMenuItem(
                                  value: state,
                                  child: Text(state),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(() => _selectedState = value),
                        ),
                        const SizedBox(height: 16),

                        // Search button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _searchAvailability,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Search Hotels'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Search Results
          if (_hasSearched) Expanded(flex: 2, child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector(
    String label,
    DateTime? date,
    TimeOfDay time,
    VoidCallback onDateTap,
    VoidCallback onTimeTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onDateTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('MMM dd').format(date)
                      : 'Select date',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTimeTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(_formatTime(time)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterField(
    String label,
    int value,
    Function(int) onChanged,
    int min,
    int max,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
                iconSize: 20,
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Search Error',
              style: TextStyle(fontSize: 18, color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchAvailability,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No available hotels found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final hotelWithAvailability = _searchResults[index];
        return _buildHotelCard(hotelWithAvailability);
      },
    );
  }

  Widget _buildHotelCard(HotelWithAvailability hotelWithAvailability) {
    final hotel = hotelWithAvailability.hotel;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotel.address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotel.state,
                        style: TextStyle(color: Colors.blue[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Hotel ID (debug/info)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ID: ${hotel.id}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Availability info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${hotelWithAvailability.availableRoomCount} rooms available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Show cheapest price hint if rooms loaded
                  if (hotelWithAvailability.availableRooms != null &&
                      hotelWithAvailability.availableRooms!.isNotEmpty)
                    Text(
                      'Cheapest: \$${_getMinPrice(hotelWithAvailability.availableRooms!).toStringAsFixed(0)} / night',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    )
                  else
                    Text(
                      'Tap "View Details" to see available rooms',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Available rooms details (if loaded)
            if (hotelWithAvailability.availableRooms != null) ...[
              Text(
                'Available Room Details:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...hotelWithAvailability.availableRooms!.map(
                (room) => _buildRoomCard(room),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Room details not loaded — tap View Details to load rooms.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                if (hotelWithAvailability.availableRooms != null &&
                    hotelWithAvailability.availableRooms!.isNotEmpty)
                  Text(
                    'From \$${_getMinPrice(hotelWithAvailability.availableRooms!).toStringAsFixed(0)}/night',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    _navigateToHotelDetails(hotelWithAvailability);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    _bookHotel(hotelWithAvailability);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                  ),
                  child: const Text('Book Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  room.type,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Room ID: ${room.id}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${room.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                  fontSize: 16,
                ),
              ),
              Text(
                'per night',
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToHotelDetails(HotelWithAvailability hotelWithAvailability) {
    // Pass hotel, available room ids and the last search params to details page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => HotelDetailPage(
              hotel: hotelWithAvailability.hotel,
              availableRoomIds: hotelWithAvailability.availableRoomIds,
              searchParams: _lastSearchParams,
            ),
      ),
    );
  }

  void _bookHotel(HotelWithAvailability hotelWithAvailability) {
    // Implement booking functionality
    if (hotelWithAvailability.availableRooms != null &&
        hotelWithAvailability.availableRooms!.isNotEmpty) {
      _showRoomSelectionDialog(hotelWithAvailability);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please view details to load room list')),
      );
    }
  }

  void _showRoomSelectionDialog(HotelWithAvailability hotelWithAvailability) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Room - ${hotelWithAvailability.hotel.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    hotelWithAvailability.availableRooms!
                        .map(
                          (room) => ListTile(
                            title: Text(room.name),
                            subtitle: Text(
                              '\$${room.price.toStringAsFixed(0)} per night',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).pop();
                              _proceedToBooking(
                                hotelWithAvailability.hotel,
                                room,
                              );
                            },
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _proceedToBooking(Hotel hotel, Room room) {
    // Implement actual booking flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${room.name} at ${hotel.name}'),
        action: SnackBarAction(
          label: 'Continue',
          onPressed: () {
            // Navigate to booking confirmation page
          },
        ),
      ),
    );
  }
}
