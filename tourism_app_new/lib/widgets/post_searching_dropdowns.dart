// widgets/post_searching_dropdowns.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app_new/models/search_params_model.dart';

class SearchCardWithData extends StatefulWidget {
  final SearchParams searchParams;
  final Function(SearchParams) onSearchPressed;

  const SearchCardWithData({
    super.key,
    required this.searchParams,
    required this.onSearchPressed,
  });

  @override
  _SearchCardWithDataState createState() => _SearchCardWithDataState();
}

class _SearchCardWithDataState extends State<SearchCardWithData> {
  bool showDatePicker = false;
  bool showDurationDropdown = false;
  bool showGuestSelector = false;
  bool showSearchButton = false;
  bool editingLocation = false;

  late TextEditingController locationController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late int selectedDurationHours;
  late int adults;
  late int children;
  late int rooms;

  final themeColor = const Color(0xFF4ECDC4);
  final List<int> durationOptions = [1, 2, 3, 4, 5, 6, 8, 12, 24, 48, 72];

  @override
  void initState() {
    super.initState();


    locationController =
        TextEditingController(text: widget.searchParams.locationName);
    selectedDate = widget.searchParams.checkInDate;
    selectedTime = widget.searchParams.checkInTime;
    selectedDurationHours = widget.searchParams.durationHours;
    adults = widget.searchParams.adults;
    children = widget.searchParams.children;
    rooms = widget.searchParams.rooms;
  }

  String _formatDuration(int hours) {
    return '$hours hour${hours > 1 ? 's' : ''}';
  }

  void _performSearch() {
    final searchParams = SearchParams(
      locationName: locationController.text.trim(),
      latitude: widget.searchParams.latitude,
      longitude: widget.searchParams.longitude,
      checkInDate: selectedDate,
      checkInTime: selectedTime,
      durationHours: selectedDurationHours,
      adults: adults,
      children: children,
      rooms: rooms,
    );

    widget.onSearchPressed(searchParams);

    setState(() {
      showSearchButton = false;
      showDatePicker = false;
      showDurationDropdown = false;
      showGuestSelector = false;
      editingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasNullDetails = widget.searchParams.checkInDate == null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (hasNullDetails)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "If you need to book this, please add details",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // --- main content ---
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          editingLocation
                              ? TextField(
                                controller: locationController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: "Enter location",
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                onSubmitted: (_) {
                                  setState(() {
                                    editingLocation = false;
                                    showSearchButton = true;
                                  });
                                },
                              )
                              : GestureDetector(
                                onTap: () {
                                  setState(() => editingLocation = true);
                                },
                                child: Text(
                                  locationController.text,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                    ),
                    const SizedBox(width: 12),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selectedTime.format(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDuration(selectedDurationHours),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$adults Adults',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$children Children',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$rooms Room',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
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

          // extended dropdowns
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
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
                const SizedBox(width: 10),
                Text(
                  'Choose duration',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: SingleChildScrollView(
                child: Column(
                  children:
                      durationOptions
                          .map((hours) => _buildDurationOption(hours))
                          .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showDurationDropdown = false;
                  showSearchButton = true;
                });
              },
              style: _buttonStyle(),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(int hours) {
    bool isSelected = selectedDurationHours == hours;
    return GestureDetector(
      onTap: () => setState(() => selectedDurationHours = hours),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? themeColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _formatDuration(hours),
          style: TextStyle(
            color: isSelected ? themeColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM').format(selectedDate).toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildCalendar(),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'From',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showDatePicker = false;
                  showSearchButton = true;
                });
              },
              style: _buttonStyle(),
              child: const Text(
                'Select Date',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
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
                const SizedBox(width: 10),
                const Text(
                  'No. of guests',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGuestCounter(
              'Adults',
              adults,
              (value) => setState(() => adults = value),
            ),
            const SizedBox(height: 16),
            _buildGuestCounter(
              'Children',
              children,
              (value) => setState(() => children = value),
            ),
            const SizedBox(height: 16),
            _buildGuestCounter(
              'Rooms',
              rooms,
              (value) => setState(() => rooms = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showGuestSelector = false;
                  showSearchButton = true;
                });
              },
              style: _buttonStyle(),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
            fontSize: 16,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildSearchSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
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
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _performSearch();
                setState(() => showSearchButton = false);
              },
              style: _buttonStyle(),
              child: const Text(
                '            Search              ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        ...List.generate(5, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
                          fontSize: 16,
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
  );
}
