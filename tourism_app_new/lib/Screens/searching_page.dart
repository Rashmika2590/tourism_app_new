import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app_new/constants/colors.dart';
import 'package:tourism_app_new/models/property_model.dart';
import 'package:tourism_app_new/widgets/property_card.dart';
import 'property_list_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _guestController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  late TabController _tabController;
  int selectedTabIndex = 0; // 0 = Book Now, 1 = Book Later
  DateTime? selectedDateTime;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void _search() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PropertyListPage(city: city)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a location')));
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

  Widget _buildHorizontalPropertyList(String title, List<Property> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            padding: EdgeInsets.zero, // ← removes default left/right padding
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left:
                      index == 0
                          ? 0
                          : 0, // ← no extra left margin for first item
                ),
                child: SizedBox(
                  width: 320, // Keep your original card width
                  child: PropertyCard(
                    property: properties[index],
                    onTap: () {},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
              primary: Color(0xFF00B3A6), // Custom green
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF00B3A6), // Button text color
              ),
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

  @override
  Widget build(BuildContext context) {
    final properties = getMockProperties();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/logo/crabigo_logo.png', height: 40),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.notifications_none, color: Colors.black),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.orange,
                indicatorWeight: 2.5,
                tabs: const [
                  Tab(icon: Icon(Icons.bed), text: "Quick Stay"),
                  Tab(icon: Icon(Icons.calendar_today), text: "Extended Stay"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Book a stay for just a few hours — Quick Stay lets you check in and out within 24 hours.",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Location Search
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                  hintText: 'Where do want to go?',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Book Now / Later
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Book Now
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTabIndex = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Book Later
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await _selectDateTime();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Duration and Guests
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _durationController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Choose duration',
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _guestController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'No. of guests',
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Search Button
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 300, // Set your desired width here
                decoration: BoxDecoration(
                  gradient: AppGradients.buttonGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildHorizontalPropertyList("Near your location", properties),
            const SizedBox(height: 20),
            _buildHorizontalPropertyList("Top rated in Galle", properties),
            const SizedBox(height: 20),
            _buildHorizontalPropertyList("More Listings", properties),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
