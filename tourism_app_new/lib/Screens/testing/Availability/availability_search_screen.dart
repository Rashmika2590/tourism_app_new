// Screens/room_availability_screen.dart
import 'package:flutter/material.dart';
import 'package:tourism_app_new/Screens/testing/Rooms/room_list.dart';
import 'package:tourism_app_new/Services/Api%20Services/Authentication/availablility_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/Authentication/hotel_api_service.dart';
import 'package:tourism_app_new/models/availability_model.dart';
import 'package:tourism_app_new/Models/hotel_model.dart';

class RoomAvailabilityScreen extends StatefulWidget {
  const RoomAvailabilityScreen({super.key});

  @override
  State<RoomAvailabilityScreen> createState() => _RoomAvailabilityScreenState();
}

class _RoomAvailabilityScreenState extends State<RoomAvailabilityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Required fields
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String _checkInTime = '10:00:00';
  String _checkOutTime = '12:00:00';

  // Optional fields
  final _stateController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _maxDistanceController = TextEditingController();
  final _adultCountController = TextEditingController(text: '1');
  final _childrenCountController = TextEditingController(text: '0');

  bool _isLoading = false;
  RoomAvailability? _availability;
  Map<int, Hotel> _hotelDetails = {}; // hotelId -> Hotel
  String? _errorMessage;

  @override
  void dispose() {
    _stateController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _maxDistanceController.dispose();
    _adultCountController.dispose();
    _childrenCountController.dispose();
    super.dispose();
  }

  Future<void> _searchAvailability() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkInDate == null || _checkOutDate == null) {
      setState(() {
        _errorMessage = 'Please select both check-in and check-out dates';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _availability = null;
      _hotelDetails = {};
    });

    try {
      final availability = await RoomAvailabilityService.searchAvailability(
        checkInDate: _checkInDate!,
        checkInTime: _checkInTime,
        checkOutDate: _checkOutDate!,
        checkOutTime: _checkOutTime,
        state: _stateController.text.isEmpty ? null : _stateController.text,
        latitude:
            _latitudeController.text.isEmpty
                ? null
                : double.tryParse(_latitudeController.text),
        longitude:
            _longitudeController.text.isEmpty
                ? null
                : double.tryParse(_longitudeController.text),
        maxDistanceKm:
            _maxDistanceController.text.isEmpty
                ? null
                : double.tryParse(_maxDistanceController.text),
        adultCount:
            _adultCountController.text.isEmpty
                ? null
                : int.tryParse(_adultCountController.text),
        childrenCount:
            _childrenCountController.text.isEmpty
                ? null
                : int.tryParse(_childrenCountController.text),
      );

      setState(() {
        _availability = availability;
        _isLoading = false;
      });

      await _fetchHotelDetails();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHotelDetails() async {
    if (_availability == null) return;

    for (int hotelId in _availability!.hotelIds) {
      if (!_hotelDetails.containsKey(hotelId)) {
        try {
          final hotel = await HotelApiService.getHotelById(hotelId);
          _hotelDetails[hotelId] = hotel;
          setState(() {}); // update UI after each hotel is fetched
        } catch (e) {
          debugPrint('Failed to fetch hotel $hotelId: $e');
        }
      }
    }
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _navigateToRoomList(int hotelId) {
    if (_checkInDate == null || _checkOutDate == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RoomsListScreen(
              hotelId: hotelId,
              checkInDate: _checkInDate,
              checkInTime: _checkInTime,
              checkOutDate: _checkOutDate,
              checkOutTime: _checkOutTime,
              adultCount: int.tryParse(_adultCountController.text) ?? 1,
              childrenCount: int.tryParse(_childrenCountController.text) ?? 0,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Room Availability'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRequiredInfoCard(),
              const SizedBox(height: 16),
              _buildOptionalFiltersCard(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _searchAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Search Available Rooms',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) _buildErrorCard(),
              if (_availability != null) _buildResultsCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== Helper Widgets =====================

  Card _buildRequiredInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Check-in Date *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _checkInDate != null
                            ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _checkInTime,
                    decoration: const InputDecoration(
                      labelText: 'Time *',
                      border: OutlineInputBorder(),
                    ),
                    items: _getTimeOptions(),
                    onChanged: (value) => setState(() => _checkInTime = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Check-out Date *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _checkOutDate != null
                            ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _checkOutTime,
                    decoration: const InputDecoration(
                      labelText: 'Time *',
                      border: OutlineInputBorder(),
                    ),
                    items: _getTimeOptions(),
                    onChanged:
                        (value) => setState(() => _checkOutTime = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card _buildOptionalFiltersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Filters (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: 'State/Location',
                border: OutlineInputBorder(),
                hintText: 'e.g., Colombo',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _maxDistanceController,
              decoration: const InputDecoration(
                labelText: 'Max Distance (km)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _adultCountController,
                    decoration: const InputDecoration(
                      labelText: 'Adults',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _childrenCountController,
                    decoration: const InputDecoration(
                      labelText: 'Children',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Results Card & Time Options =====================

  Card _buildResultsCard() {
    if (_availability == null) return Card();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hotel, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Search Results',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_availability!.hasAvailableRooms()) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Found ${_availability!.getTotalAvailableRooms()} available rooms in ${_availability!.hotelIds.length} hotels',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...(_availability!.hotelIds.map((hotelId) {
                final roomIds = _availability!.getRoomIdsForHotel(hotelId);
                final hotel = _hotelDetails[hotelId];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading:
                        hotel != null && hotel.images.isNotEmpty
                            ? Image.network(
                              hotel.images[0],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                            : CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                hotelId.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                    title: Text(hotel?.name ?? 'Hotel ID: $hotelId'),
                    subtitle: Text(
                      'Available rooms: ${roomIds.join(', ')}',
                      style: const TextStyle(color: Colors.green),
                    ),
                    trailing: Chip(
                      label: Text('${roomIds.length} rooms'),
                      backgroundColor: Colors.blue.shade100,
                    ),
                    onTap:
                        roomIds.isNotEmpty
                            ? () => _navigateToRoomList(hotelId)
                            : null,
                  ),
                );
              }).toList()),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'No rooms available for the selected criteria',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getTimeOptions() {
    final times = <String>[];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        times.add(
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00',
        );
      }
    }
    return times.map((time) {
      final displayTime = time.substring(0, 5);
      return DropdownMenuItem(value: time, child: Text(displayTime));
    }).toList();
  }
}
