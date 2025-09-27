import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/property_model.dart';
import 'package:tourism_app_new/routs.dart';
import 'package:tourism_app_new/widgets/property_card.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tourism_app_new/constants/api_keys.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  double? _latitude;
  double? _longitude;
  late TabController _tabController;
  int selectedTabIndex = 0;
  DateTime? selectedDateTime;

  final List<String> durations = [
    '3 hours',
    '6 hours',
    '8 hours',
    '10 hours',
    '12 hours',
    '24 hours',
  ];
  String? selectedDuration;
  bool isDurationDropdownOpen = false;
  bool isGuestDropdownOpen = false;

  int childrenCount = 0;
  int adultsCount = 1;
  int roomsCount = 1;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void _search() async {
    double? searchLat = _latitude;
    double? searchLng = _longitude;

    if (_cityController.text.trim().isEmpty) {
      final position = await _getCurrentLocation();
      if (position != null) {
        searchLat = position.latitude;
        searchLng = position.longitude;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please enter a location or enable location services.'),
          ),
        );
        return;
      }
    }

    if (searchLat == null || searchLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not determine location. Please try again.'),
        ),
      );
      return;
    }

    if (selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a duration.')),
      );
      return;
    }

    final checkInDateTime = selectedDateTime ?? DateTime.now();
    final durationHours = int.parse(selectedDuration!.split(' ')[0]);
    final checkOutDateTime = checkInDateTime.add(Duration(hours: durationHours));

    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyListPage(
          latitude: searchLat!,
          longitude: searchLng!,
          adultCount: adultsCount,
          childrenCount: childrenCount,
          checkInDate: dateFormatter.format(checkInDateTime),
          checkInTime: timeFormatter.format(checkInDateTime),
          checkOutDate: dateFormatter.format(checkOutDateTime),
          checkOutTime: timeFormatter.format(checkOutDateTime),
        ),
      ),
    );
  }

  // Extract city name from Google Places API response
  String _extractCityName(String fullAddress) {
    // Remove common suffixes and extract main city name
    String cityName = fullAddress;

    // Split by comma and take the first part
    List<String> parts = fullAddress.split(',');
    if (parts.isNotEmpty) {
      cityName = parts[0].trim();
    }

    // Remove common prefixes like "City of", "Greater", etc.
    final prefixesToRemove = ['City of ', 'Greater ', 'Metro '];
    for (String prefix in prefixesToRemove) {
      if (cityName.startsWith(prefix)) {
        cityName = cityName.substring(prefix.length);
        break;
      }
    }

    return cityName;
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<Map<String, String>>> _getSuggestions(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleMapsApiKey&types=(cities)',
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

  List<Property> getMockProperties() {
    return List.generate(5, (index) {
      return Property(
        id: '$index',
        propertyName: 'Bromo Cabin #$index',
        propertyType: 1,
        availability: 1,
        allowShortStays: true,
        allowLongStays: true,
        userRole: 0,
        numOfHours: 4,
        guestStayType: 1,
        address: Address(
          no: 'No 1',
          street: 'Sunset Ave',
          city: 'Galle',
          province: 'Southern',
          country: 'Sri Lanka',
          postalCode: '80000',
          latitude: 6.03,
          longitude: 80.22,
        ),
        propertyImage: PropertyImage(
          primaryImageUrl:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
          secondaryImages: [],
        ),
        guestCapacities: [GuestCapacity(guestType: 1, maxGuests: 2)],
        packages: [
          Package(
            packageName: 'Standard',
            packageType: 1,
            packageImage: PackageImage(
              primaryImageUrl: '',
              secondaryImages: [],
            ),
            packagePriceDetail: PackagePriceDetail(
              basePrice: 2000,
              weekendPrice: 2500,
              monthlyDiscount: 10,
              isWiFiIncluded: true,
              wiFiPrice: 0,
              isParkingIncluded: true,
              parkingPrice: 0,
            ),
          ),
        ],
        rating: Rating(userId: 'user1', rating: 4.8, comment: 'Excellent stay'),
      );
    });
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

  // Helper method to get responsive padding based on screen size
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

  // Helper method to get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSize - 2;
    } else if (screenWidth > 480) {
      return baseSize + 1;
    }
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final properties = getMockProperties();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              isDurationDropdownOpen = false;
              isGuestDropdownOpen = false;
            });
          },
          child: ListView(
            padding: _getResponsivePadding(context),
            children: [
              // Header with responsive layout
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
                        size: screenWidth < 360 ? 18 : 20,
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
              SizedBox(height: screenHeight * 0.015),

              // Responsive TabBar
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
                    Tab(icon: Icon(Icons.bed), text: "Quick Stay"),
                    Tab(
                      icon: Icon(Icons.calendar_today),
                      text: "Extended Stay",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Book a stay for just a few hours — Quick Stay lets you check in and out within 24 hours.",
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 10),
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Location Input with fixed autocomplete
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
                    controller: _cityController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintText: '   Where do you want to go?',
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
                        'City: ${_extractCityName(suggestion['description']!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) async {
                    final placeId = suggestion['place_id']!;
                    final description = suggestion['description']!;

                    try {
                      List<Location> locations =
                          await locationFromAddress(description);
                      if (locations.isNotEmpty) {
                        final location = locations.first;
                        setState(() {
                          _latitude = location.latitude;
                          _longitude = location.longitude;
                        });
                        _cityController.text = _extractCityName(description);

                        print(
                            '📍Geocoded: Lat: ${location.latitude}, Lng: ${location.longitude}');
                      }
                    } catch (e) {
                      print('Error geocoding: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not get location for address'),
                        ),
                      );
                    }
                  },
                  noItemsFoundBuilder:
                      (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No cities found'),
                      ),
                ),
              ),

              const SizedBox(height: 10),

              // Booking Container with responsive design
              Container(
                padding: EdgeInsets.all(screenWidth < 360 ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Book Now/Later Toggle - Responsive
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTabIndex = 0;
                                selectedDateTime = null;
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

                    // Duration and Guest Dropdown Section - Responsive
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Responsive layout for dropdowns
                        screenWidth < 360
                            ? Column(
                              children: [
                                _buildDropdownField(
                                  context,
                                  Icons.access_time,
                                  selectedDuration ?? 'Choose duration',
                                  isDurationDropdownOpen,
                                  () {
                                    setState(() {
                                      isDurationDropdownOpen =
                                          !isDurationDropdownOpen;
                                      isGuestDropdownOpen = false;
                                    });
                                  },
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
                                      isDurationDropdownOpen = false;
                                    });
                                  },
                                ),
                              ],
                            )
                            : Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    context,
                                    Icons.access_time,
                                    selectedDuration ?? 'Choose duration',
                                    isDurationDropdownOpen,
                                    () {
                                      setState(() {
                                        isDurationDropdownOpen =
                                            !isDurationDropdownOpen;
                                        isGuestDropdownOpen = false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDropdownField(
                                    context,
                                    Icons.person_outline,
                                    '${adultsCount + childrenCount} guests',
                                    isGuestDropdownOpen,
                                    () {
                                      setState(() {
                                        isGuestDropdownOpen =
                                            !isGuestDropdownOpen;
                                        isDurationDropdownOpen = false;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                        // Duration Dropdown Menu
                        if (isDurationDropdownOpen)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
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
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: durations.length,
                              itemBuilder: (context, index) {
                                final duration = durations[index];
                                final isSelected = duration == selectedDuration;
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenWidth < 360 ? 12 : 16,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    duration,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? const Color(0xFF00B3A6)
                                              : Colors.black,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      fontSize: _getResponsiveFontSize(
                                        context,
                                        14,
                                      ),
                                    ),
                                  ),
                                  trailing:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Color(0xFF00B3A6),
                                          )
                                          : null,
                                  onTap: () {
                                    setState(() {
                                      selectedDuration = duration;
                                      isDurationDropdownOpen = false;
                                    });
                                  },
                                );
                              },
                            ),
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

              // Responsive Search Button
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
                    onPressed: _search,
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
                    child: Text(
                      'Search',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Responsive Property Lists
              _buildHorizontalPropertyList("Near your location", properties),
              const SizedBox(height: 20),
              _buildHorizontalPropertyList("Top rated in Galle", properties),
              const SizedBox(height: 20),
              _buildHorizontalPropertyList("More Listings", properties),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for dropdown fields with gray background and white outline
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
          color: Colors.grey.shade200, // Gray background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white, // White outline
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black, // White icon
              size: screenWidth < 360 ? 18 : 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey.shade700, // White text
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.black, // White arrow
              size: screenWidth < 360 ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalPropertyList(String title, List<Property> properties) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // SizedBox(
        //   height: screenWidth < 360 ? 180 : 210,
        //   child: ListView.builder(
            // scrollDirection: Axis.horizontal,
        //     itemCount: properties.length,
        //     padding: EdgeInsets.zero,
        //     itemBuilder: (context, index) {
        //       return SizedBox(
        //         width:
        //             screenWidth < 360 ? 280 : (screenWidth < 480 ? 300 : 320),
        //         child: PropertyCard(property: properties[index], onTap: () {}),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}
