// Enhanced room_availability_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:tourism_app_new/Screens/testing/Availability/availability_result_page.dart';
import 'package:tourism_app_new/Services/Api%20Services/availablility_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/availability_model.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/routs.dart';
import 'package:tourism_app_new/widgets/property_card.dart';

// Remove the duplicate HotelWithRoomDetails class from this file

class RoomAvailabilityScreen extends StatefulWidget {
  const RoomAvailabilityScreen({super.key});

  @override
  State<RoomAvailabilityScreen> createState() => _RoomAvailabilityScreenState();
}

class _RoomAvailabilityScreenState extends State<RoomAvailabilityScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _stateController = TextEditingController();
  late TabController _tabController;
  int selectedTabIndex = 0;

  // Date and time variables
  DateTime? selectedDateTime;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String _checkInTime = '10:00:00';
  String _checkOutTime = '12:00:00';

  // Guest count variables
  bool isGuestDropdownOpen = false;
  int childrenCount = 0;
  int adultsCount = 1;
  int roomsCount = 1;

  // Loading and data states
  bool _isLoading = false;
  RoomAvailability? _availability;
  List<HotelWithRoomDetails> _hotelWithRoomDetails = [];
  String? _errorMessage;

  //variables for hotels
  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  bool _isLoadingHotels = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _loadAllHotels();
    super.initState();
  }

  @override
  void dispose() {
    _stateController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Extract city/state name from Google Places API response
  String _extractCityName(String fullAddress) {
    String cityName = fullAddress;
    List<String> parts = fullAddress.split(',');
    if (parts.isNotEmpty) {
      cityName = parts[0].trim();
    }

    final prefixesToRemove = ['City of ', 'Greater ', 'Metro '];
    for (String prefix in prefixesToRemove) {
      if (cityName.startsWith(prefix)) {
        cityName = cityName.substring(prefix.length);
        break;
      }
    }
    return cityName;
  }

  Future<List<Map<String, String>>> _getSuggestions(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=AIzaSyC3d7coKXELrnxFCwCJ2ku2bhqnNpEo7-s&types=(cities)',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List<dynamic>;
          return predictions.map((prediction) {
            return {
              'description': prediction['description'] as String,
              'place_id': prediction['place_id'] as String,
            };
          }).toList();
        } else {
          print('Error from API: ${data['status']}');
          return [];
        }
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      print('Error getting suggestions: $e');
      return [];
    }
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00B3A6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF00B3A6)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF00B3A6),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          selectedTabIndex = 1;
          selectedDateTime = combined;
        });
      }
    }
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00B3A6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF00B3A6)),
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _searchAvailability() async {
    final state = _stateController.text.trim();

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
      _hotelWithRoomDetails = [];
    });

    try {
      final availability = await RoomAvailabilityService.searchAvailability(
        checkInDate: _checkInDate!,
        checkInTime: _checkInTime,
        checkOutDate: _checkOutDate!,
        checkOutTime: _checkOutTime,
        state: state,
        adultCount: adultsCount,
        childrenCount: childrenCount,
      );

      setState(() {
        _availability = availability;
        _isLoading = false;
      });

      if (availability.hotelIds.isNotEmpty) {
        await _fetchHotelAndRoomDetails();

        // Navigate to results page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RoomAvailabilityResultsScreen(
                  state: state,
                  checkInDate: _checkInDate!,
                  checkOutDate: _checkOutDate!,
                  checkInTime: _checkInTime,
                  checkOutTime: _checkOutTime,
                  adultsCount: adultsCount,
                  childrenCount: childrenCount,
                  roomsCount: roomsCount,
                  availability: availability,
                  hotelWithRoomDetails: _hotelWithRoomDetails,
                ),
          ),
        );
      } else {
        // Show no results message on current page
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHotelAndRoomDetails() async {
    if (_availability == null || _availability!.hotelIds.isEmpty) return;

    setState(() {});

    try {
      final List<HotelWithRoomDetails> hotelWithRoomDetailsList = [];

      for (int hotelId in _availability!.hotelIds) {
        final availableRoomIds = _availability!.getRoomIdsForHotel(hotelId);

        if (availableRoomIds.isEmpty) continue;

        final hotelFuture = HotelApiService.getHotelById(hotelId);
        final roomFutures = availableRoomIds.map(
          (roomId) => RoomApiService.getRoomById(roomId),
        );

        final results = await Future.wait([hotelFuture, ...roomFutures]);

        final hotel = results[0] as Hotel;
        final rooms = results.skip(1).cast<Room>().toList();

        if (rooms.isNotEmpty) {
          final cheapestRoom = rooms.reduce(
            (current, next) => current.price < next.price ? current : next,
          );

          hotelWithRoomDetailsList.add(
            HotelWithRoomDetails(
              hotel: hotel,
              availableRooms: rooms,
              cheapestRoom: cheapestRoom,
            ),
          );
        }
      }

      setState(() {
        _hotelWithRoomDetails = hotelWithRoomDetailsList;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load hotel and room details: $e';
        print(_errorMessage);
      });
    }
  }

  //get hotel details
  Future<void> _loadAllHotels() async {
    setState(() => _isLoadingHotels = true);

    try {
      final hotels = await HotelApiService.getAllHotels();
      setState(() {
        _hotels = hotels;
        _filteredHotels = hotels;
        _isLoadingHotels = false;
      });
    } catch (e) {
      print("Error loading hotels: $e");
      setState(() => _isLoadingHotels = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load hotels: $e')));
    }
  }

  Widget _buildCounterRow(
    String label,
    int value,
    Function(int) onChanged, {
    int min = 0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (value > min) onChanged(value - 1);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.remove, size: 18),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                onChanged(value + 1);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return const EdgeInsets.all(8);
    } else if (screenWidth < 480) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSize - 2;
    } else if (screenWidth > 480) {
      return baseSize + 1;
    }
    return baseSize;
  }

  Widget _buildDropdownField(
    BuildContext context,
    IconData icon,
    String text,
    bool isOpen,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 360 ? 10 : 12,
          vertical: screenWidth < 360 ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: screenWidth < 360 ? 18 : 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.black,
              size: screenWidth < 360 ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              isGuestDropdownOpen = false;
            });
          },
          child: ListView(
            padding: _getResponsivePadding(context),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Image.asset(
                      'assets/logo/crabigo_logo.png',
                      height: screenWidth < 360 ? 32 : 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  CircleAvatar(
                    radius: screenWidth < 360 ? 14 : 16,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: Colors.black,
                        size: screenWidth < 360 ? 21 : 25,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.notification);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
              //SizedBox(height: screenHeight * 0.015),

              // TabBar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                  indicatorWeight: 2.5,
                  labelStyle: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bed),
                          SizedBox(width: 6),
                          Text("Quick Stay"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 6),
                          Text("Extended Stay"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Search for available rooms in hotels — Extended Stay lets you book for multiple days.",
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 10),
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Location Input
              Container(
                height: screenHeight * 0.05,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 360 ? 8 : 12,
                ),
                child: TypeAheadField<Map<String, String>>(
                  textFieldConfiguration: TextFieldConfiguration(
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 15.0),
                    ),
                    controller: _stateController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintText: '   Where do you want to stay?',
                      labelStyle: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 14.0),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return [];
                    return await _getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion['description']!),
                      subtitle: Text(
                        'State: ${_extractCityName(suggestion['description']!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    String stateName = _extractCityName(
                      suggestion['description']!,
                    );
                    _stateController.text = stateName;
                    print('🏛️ Selected: ${suggestion['description']}');
                    print('🎯 Extracted State: $stateName');
                  },
                  noItemsFoundBuilder:
                      (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No locations found'),
                      ),
                ),
              ),
              const SizedBox(height: 10),

              // Booking Container
              Container(
                padding: EdgeInsets.all(screenWidth < 360 ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Book Now/Later Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTabIndex = 0;
                                selectedDateTime = null;
                                _checkInDate = DateTime.now();
                                _checkOutDate = DateTime.now().add(
                                  Duration(days: 1),
                                );
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: screenWidth < 360 ? 8 : 10,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    selectedTabIndex == 0
                                        ? AppGradients.buttonGradient
                                        : null,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Book Now",
                                style: TextStyle(
                                  color:
                                      selectedTabIndex == 0
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: _getResponsiveFontSize(context, 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await _selectDateTime();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: screenWidth < 360 ? 8 : 10,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    selectedTabIndex == 1 &&
                                            selectedDateTime != null
                                        ? AppGradients.buttonGradient
                                        : null,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color:
                                      selectedTabIndex == 1
                                          ? const Color(0xFF00B3A6)
                                          : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  selectedDateTime != null
                                      ? DateFormat(
                                        'dd MMM, h:mm a',
                                      ).format(selectedDateTime!)
                                      : "Book Later",
                                  style: TextStyle(
                                    color:
                                        selectedTabIndex == 1 &&
                                                selectedDateTime != null
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: _getResponsiveFontSize(
                                      context,
                                      14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Date Selection Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        screenWidth < 360
                            ? Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _selectDate(true),
                                  child: _buildDropdownField(
                                    context,
                                    Icons.calendar_today,
                                    _checkInDate != null
                                        ? 'Check-in: ${DateFormat('dd MMM yyyy').format(_checkInDate!)}'
                                        : 'Select check-in date',
                                    false,
                                    () => _selectDate(true),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _selectDate(false),
                                  child: _buildDropdownField(
                                    context,
                                    Icons.calendar_today,
                                    _checkOutDate != null
                                        ? 'Check-out: ${DateFormat('dd MMM yyyy').format(_checkOutDate!)}'
                                        : 'Select check-out date',
                                    false,
                                    () => _selectDate(false),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildDropdownField(
                                  context,
                                  Icons.person_outline,
                                  '${adultsCount + childrenCount} guests',
                                  isGuestDropdownOpen,
                                  () {
                                    setState(() {
                                      isGuestDropdownOpen =
                                          !isGuestDropdownOpen;
                                    });
                                  },
                                ),
                              ],
                            )
                            : Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDate(true),
                                    child: _buildDropdownField(
                                      context,
                                      Icons.calendar_today,
                                      _checkInDate != null
                                          ? 'Check-in: ${DateFormat('dd MMM').format(_checkInDate!)}'
                                          : 'Check-in date',
                                      false,
                                      () => _selectDate(true),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDate(false),
                                    child: _buildDropdownField(
                                      context,
                                      Icons.calendar_today,
                                      _checkOutDate != null
                                          ? 'Check-out: ${DateFormat('dd MMM').format(_checkOutDate!)}'
                                          : 'Check-out date',
                                      false,
                                      () => _selectDate(false),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                        const SizedBox(height: 8),

                        // Guest dropdown
                        _buildDropdownField(
                          context,
                          Icons.person_outline,
                          '${adultsCount + childrenCount} guests',
                          isGuestDropdownOpen,
                          () {
                            setState(() {
                              isGuestDropdownOpen = !isGuestDropdownOpen;
                            });
                          },
                        ),

                        // Guest Dropdown Menu
                        if (isGuestDropdownOpen)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: EdgeInsets.all(
                              screenWidth < 360 ? 12 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildCounterRow("Children", childrenCount, (
                                  val,
                                ) {
                                  setState(() => childrenCount = val);
                                }),
                                const SizedBox(height: 12),
                                _buildCounterRow("Adults", adultsCount, (val) {
                                  setState(() => adultsCount = val);
                                }, min: 1),
                                const SizedBox(height: 12),
                                _buildCounterRow("Rooms", roomsCount, (val) {
                                  setState(() => roomsCount = val);
                                }, min: 1),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Search Button
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: screenWidth < 360 ? screenWidth * 0.8 : 300,
                  height: screenWidth < 360 ? 36 : 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.buttonGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _searchAvailability,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth < 360 ? 8 : 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              'Search',
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Error Message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
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

              // No Results Message (when staying on the same page)
              if (_availability != null && _availability!.hotelIds.isEmpty) ...[
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
                      Expanded(
                        child: Text(
                          'No rooms available for the selected criteria',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: _getResponsiveFontSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Popular Hotels Section
              const SizedBox(height: 20),
              Text(
                "Popular Hotels",
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _isLoadingHotels
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredHotels.isEmpty
                  ? const Text("No hotels available")
                  : SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filteredHotels.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(width: 20), // space between cards
                      itemBuilder: (context, index) {
                        final hotel = _filteredHotels[index];
                        return SizedBox(
                          width: 300,
                          child: HotelCard(
                            hotel: hotel,
                            onTap: () => _navigateToHotelDetails(hotel),
                          ),
                        );
                      },
                    ),
                  ),

              //SizedBox(height: screenHeight * 0.001),

              // Top Rated Hotels Section
              Text(
                "Featured Hotels",
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _isLoadingHotels
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredHotels.isEmpty
                  ? const Text("No hotels available")
                  : SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filteredHotels.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(width: 20), // space between cards
                      itemBuilder: (context, index) {
                        final hotel = _filteredHotels[index];
                        return SizedBox(
                          width: 300,
                          child: HotelCard(
                            hotel: hotel,
                            onTap: () {
                              _stateController.text = hotel.state;
                            },
                          ),
                        );
                      },
                    ),
                  ),

              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHotelDetails(Hotel hotel) {
    Navigator.pushNamed(context, '/hotel_details', arguments: hotel);
  }
}
