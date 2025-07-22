import 'package:flutter/material.dart';
import 'package:tourism_app_new/widgets/reviewCard.dart';

class HotelBookingScreen extends StatefulWidget {
  @override
  _HotelBookingScreenState createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  DateTime selectedDate = DateTime(2024, 12, 20);
  TimeOfDay selectedTime = TimeOfDay(hour: 7, minute: 30);
  String selectedDuration = "7 Hours";
  int adults = 2;
  int children = 2;
  int rooms = 1;

  bool showDatePicker = false;
  bool showDurationDropdown = false;
  bool showGuestSelector = false;
  bool showSearchButton = false;

  final themeColor = Color(0xFF4ECDC4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMainSearchCard(),
              SizedBox(height: 20),
              ReviewCarousel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Increased border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main search content
          Container(
            padding: EdgeInsets.all(15), // Increased padding
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey[600],
                      size: 24,
                    ), // Bigger icon
                    SizedBox(width: 12),
                    Text(
                      'Galle',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18, // Bigger font
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDatePicker = !showDatePicker;
                          showDurationDropdown = false;
                          showGuestSelector = false;
                          showSearchButton = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // More rounded
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0').replaceAll('12', 'DEC')}-${selectedDate.year}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14, // Bigger font
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${selectedTime.format(context)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14, // Bigger font
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), // More spacing
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDurationDropdown = !showDurationDropdown;
                          showDatePicker = false;
                          showGuestSelector = false;
                          showSearchButton = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // More rounded
                        ),
                        child: Text(
                          selectedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14, // Bigger font
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Guest container wrapped in grey container
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showGuestSelector = !showGuestSelector;
                          showDatePicker = false;
                          showDurationDropdown = false;
                          showSearchButton = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100], // Grey background
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // Rounded corners
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Colors.grey[600],
                              size: 18, // Bigger icon
                            ),
                            SizedBox(width: 8),
                            Text(
                              '$adults Adults',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13, // Bigger font
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '$children children',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13, // Bigger font
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '$rooms Room',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13, // Bigger font
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Extended dropdown sections
          if (showDatePicker) _buildDatePickerSection(),
          if (showDurationDropdown) _buildDurationSection(),
          if (showGuestSelector) _buildGuestSection(),
          if (showSearchButton) _buildSearchSection(),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: EdgeInsets.all(20), // Increased padding
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, -2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.grey[400], size: 22),
                SizedBox(width: 10),
                Text(
                  'Choose duration',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16, // Bigger font
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: SingleChildScrollView(
                child: Column(
                  children:
                      ['3 Hours', '6 Hours', '7 Hours', '8 Hours', '12 Hours']
                          .map((duration) => _buildDurationOption(duration))
                          .toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showDurationDropdown = false;
                  showSearchButton = true;
                });
              },
              style: _buttonStyle(),
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Bigger font
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(String duration) {
    bool isSelected = selectedDuration == duration;
    return GestureDetector(
      onTap: () => setState(() => selectedDuration = duration),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ), // More padding
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? themeColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(16), // More rounded
        ),
        child: Text(
          duration,
          style: TextStyle(
            color: isSelected ? themeColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15, // Bigger font
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: EdgeInsets.all(20), // Increased padding
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, -2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DECEMBER',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Bigger font
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildCalendar(),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'From',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15, // Bigger font
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData(
                            colorScheme: ColorScheme.light(primary: themeColor),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                  child: Text(
                    selectedTime.format(context),
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Bigger font
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showDatePicker = false;
                  showSearchButton = true;
                });
              },
              style: _buttonStyle(),
              child: Text(
                'Select Date',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Bigger font
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: EdgeInsets.all(20), // Increased padding
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, -2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, color: Colors.grey[400], size: 22),
                SizedBox(width: 10),
                Text(
                  'No. of guests',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16, // Bigger font
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildGuestCounter(
              'Adults',
              adults,
              (value) => setState(() => adults = value),
            ),
            SizedBox(height: 16),
            _buildGuestCounter(
              'Children',
              children,
              (value) => setState(() => children = value),
            ),
            SizedBox(height: 16),
            _buildGuestCounter(
              'Rooms',
              rooms,
              (value) => setState(() => rooms = value),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showGuestSelector = false;
                  showSearchButton = true;
                });
              },
              style: _buttonStyle(),
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Bigger font
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCounter(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16, // Bigger font
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            _buildCounterButton(
              Icons.remove,
              () => value > 0 ? onChanged(value - 1) : null,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Bigger font
                  color: Colors.grey[800],
                ),
              ),
            ),
            _buildCounterButton(Icons.add, () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, // Bigger button
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(10), // More rounded
        ),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildSearchSection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: EdgeInsets.all(10), // Increased padding
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, -2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => setState(() => showSearchButton = false),
                child: Icon(Icons.close, color: Colors.grey[600], size: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print(
                  'Searching: $selectedDate, $selectedTime, $selectedDuration, $adults adults, $children children, $rooms rooms',
                );
              },
              style: _buttonStyle(),
              child: Text(
                '            Search              ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Bigger font
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
                return Container(
                  width: 36,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, // Bigger font
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
        ),
        SizedBox(height: 16),
        ...List.generate(5, (weekIndex) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (dayIndex) {
                int day = weekIndex * 7 + dayIndex - 2;
                if (day <= 0 || day > 31)
                  return Container(width: 36, height: 36);
                bool isSelected = day == selectedDate.day;
                return GestureDetector(
                  onTap:
                      () => setState(
                        () =>
                            selectedDate = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              day,
                            ),
                      ),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration:
                        isSelected
                            ? BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(18),
                            )
                            : null,
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 16, // Bigger font
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
    backgroundColor: themeColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ), // More rounded
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10), // More padding
  );
}
