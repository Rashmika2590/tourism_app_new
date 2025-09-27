import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/routs.dart';
import 'package:tourism_app_new/widgets/hotel_card.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:tourism_app_new/Screens/property_list_page.dart';
import 'package:tourism_app_new/Services/Providers/booking_state.dart';
import 'package:tourism_app_new/widgets/filter_bottom_sheet.dart';
import 'package:tourism_app_new/widgets/filtering%20option.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  late TabController _tabController;
  int selectedTabIndex = 0;
  DateTime? selectedDateTime;

  Future<List<Hotel>>? _nearbyHotels;
  Future<List<Hotel>>? _topRatedHotels;
  Future<List<Hotel>>? _moreListingsHotels;

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
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    final bookingState = Provider.of<BookingState>(context, listen: false);
    bookingState.fetchInitialLocation().then((_) {
      _fetchNearbyHotels();
    });
    _fetchStaticHotelLists();
  }

  void _fetchStaticHotelLists() {
    setState(() {
      _topRatedHotels = HotelApiService.searchHotels(state: "Galle");
      _moreListingsHotels = HotelApiService.searchHotels();
    });
  }

  void _fetchNearbyHotels() {
    final bookingState = Provider.of<BookingState>(context, listen: false);
    if (bookingState.latitude == null || bookingState.longitude == null) return;
    setState(() {
      _nearbyHotels = HotelApiService.searchHotels(
        latitude: bookingState.latitude,
        longitude: bookingState.longitude,
        radiusKm: bookingState.radiusKm,
      );
    });
  }

  void _search() {
    final bookingState = Provider.of<BookingState>(context, listen: false);
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PropertyListPage(
                city: city,
                radius: bookingState.radiusKm,
                latitude: bookingState.latitude,
                longitude: bookingState.longitude)),
      );
    } else if (bookingState.latitude != null && bookingState.longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PropertyListPage(
                city: "Nearby",
                radius: bookingState.radiusKm,
                latitude: bookingState.latitude,
                longitude: bookingState.longitude)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
          content: Text('Please enter a location or enable location services')));
    }
  }

  String _extractCityName(String fullAddress) {
    List<String> parts = fullAddress.split(',');
    return parts.isNotEmpty ? parts[0].trim() : fullAddress;
  }

  Future<List<Map<String, String>>> _getSuggestions(String query) async {
    // IMPORTANT: Replace with your own Google Maps API Key in a secure way (e.g., environment variables)
    // const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    // For now, returning empty list as no key is provided.
    print("Warning: Google Maps API key is not set.");
    return [];
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

  void _openFilterBottomSheet() async {
    final bookingState = Provider.of<BookingState>(context, listen: false);
    final result = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        currentFilters: bookingState.filterOptions,
      ),
    );

    if (result != null) {
      bookingState.setFilterOptions(result);
      _fetchNearbyHotels();
    }
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
              isDurationDropdownOpen = false;
              isGuestDropdownOpen = false;
            });
          },
          child: ListView(
            padding: _getResponsivePadding(context),
            children: [
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: screenWidth < 360 ? 14 : 16,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.black,
                            size: screenWidth < 360 ? 18 : 20,
                          ),
                          onPressed: _openFilterBottomSheet,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
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
                  onSuggestionSelected: (suggestion) {
                    String cityName = _extractCityName(
                      suggestion['description']!,
                    );
                    _cityController.text = cityName;
                  },
                  noItemsFoundBuilder:
                      (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No cities found'),
                      ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(screenWidth < 360 ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        if (isGuestDropdownOpen)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
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
              _buildNearbyHotelList(),
              const SizedBox(height: 20),
              _buildHorizontalPropertyList("Top rated in Galle", _topRatedHotels),
              const SizedBox(height: 20),
              _buildHorizontalPropertyList("More Listings", _moreListingsHotels),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
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
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: screenWidth < 360 ? 18 : 20,
            ),
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

  Widget _buildHorizontalPropertyList(String title, Future<List<Hotel>>? hotelsFuture) {
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
        SizedBox(
          height: screenWidth < 360 ? 180 : 210,
          child: FutureBuilder<List<Hotel>>(
            future: hotelsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hotels found for "$title"'));
              }

              final hotels = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hotels.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width:
                        screenWidth < 360 ? 280 : (screenWidth < 480 ? 300 : 320),
                    child: HotelCard(hotel: hotels[index], onTap: () {}),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyHotelList() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            "Near your location",
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: screenWidth < 360 ? 180 : 210,
          child: FutureBuilder<List<Hotel>>(
            future: _nearbyHotels,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hotels found nearby.'));
              }

              final hotels = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hotels.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: screenWidth < 360
                        ? 280
                        : (screenWidth < 480 ? 300 : 320),
                    child: HotelCard(hotel: hotels[index], onTap: () {}),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}