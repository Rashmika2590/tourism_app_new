// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:tourism_app_new/Services/Api%20Services/availablility_api_service.dart';
// import 'package:tourism_app_new/Services/Providers/booking_state.dart';
// import 'package:tourism_app_new/constants/colors.dart';
// import 'package:tourism_app_new/models/availability_model.dart';
// import 'package:tourism_app_new/models/search_params_model.dart';

// class EnhancedCheckAvailabilityCard extends StatefulWidget {
//   final int hotelId;
//   final String hotelState;
//   final SearchParams initialSearchParams;
//   final Function(SearchParams)? onAvailabilityConfirmed;

//   const EnhancedCheckAvailabilityCard({
//     Key? key,
//     required this.hotelId,
//     required this.hotelState,
//     required this.initialSearchParams,
//     this.onAvailabilityConfirmed,
//   }) : super(key: key);

//   @override
//   State<EnhancedCheckAvailabilityCard> createState() =>
//       _EnhancedCheckAvailabilityCardState();
// }

// class _EnhancedCheckAvailabilityCardState
//     extends State<EnhancedCheckAvailabilityCard> {
//   bool showDatePicker = false;
//   bool showDurationDropdown = false;
//   bool showGuestSelector = false;
//   bool showCheckoutInfo = false;

//   late DateTime selectedDate;
//   late TimeOfDay selectedTime;
//   late int selectedDurationHours;
//   late int adults;
//   late int children;
//   late int rooms;

//   final themeColor = const Color(0xFF4ECDC4);
//   final List<int> durationOptions = [1, 2, 3, 4, 5, 6, 8, 12, 24, 48, 72];

//   RoomAvailability? availability;
//   bool _isCheckingAvailability = false;
//   String? availabilityMessage;
//   bool hasAvailability = false;
//   bool _showAvailabilityButton = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeFromSearchParams();
//   }

//   void _initializeFromSearchParams() {
//     selectedDate = widget.initialSearchParams.checkInDate;
//     selectedTime = widget.initialSearchParams.checkInTime;
//     selectedDurationHours = widget.initialSearchParams.durationHours;
//     adults = widget.initialSearchParams.adults;
//     children = widget.initialSearchParams.children;
//     rooms = widget.initialSearchParams.rooms;
//   }

//   DateTime get checkoutDateTime =>
//       selectedDate.add(Duration(hours: selectedDurationHours));
//   TimeOfDay get checkoutTime => TimeOfDay.fromDateTime(checkoutDateTime);

//   String _formatDuration(int hours) {
//     if (hours < 24) {
//       return '$hours hour${hours > 1 ? 's' : ''}';
//     } else {
//       int days = hours ~/ 24;
//       int remainingHours = hours % 24;
//       if (remainingHours == 0) {
//         return '$days day${days > 1 ? 's' : ''}';
//       } else {
//         return '$days day${days > 1 ? 's' : ''} ${remainingHours}h';
//       }
//     }
//   }

//   String _formatDateTime(DateTime date, TimeOfDay time) {
//     return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${time.format(context)}';
//   }

//   Future<void> _checkAvailability() async {
//     setState(() {
//       _isCheckingAvailability = true;
//       availabilityMessage = null;
//       hasAvailability = false;
//     });

//     try {
//       final checkInTime =
//           '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';
//       final checkOutTime =
//           '${checkoutTime.hour.toString().padLeft(2, '0')}:${checkoutTime.minute.toString().padLeft(2, '0')}:00';

//       final result = await RoomAvailabilityService.searchAvailability(
//         checkInDate: selectedDate,
//         checkInTime: checkInTime,
//         checkOutDate: checkoutDateTime,
//         checkOutTime: checkOutTime,
//         state: widget.hotelState,
//         adultCount: adults,
//         childrenCount: children,
//       );

//       setState(() {
//         availability = result;
//         _isCheckingAvailability = false;
//         hasAvailability = result.hasAvailableRooms();

//         if (hasAvailability) {
//           availabilityMessage =
//               '${result.getTotalAvailableRooms()} rooms available!';
//         } else {
//           availabilityMessage =
//               'No rooms available for the selected dates and criteria. Please try different dates or modify your search.';
//         }
//       });

//       // Update provider with new search parameters
//       final bookingState = Provider.of<BookingState>(context, listen: false);
//       bookingState.setState(widget.hotelState);
//       bookingState.setCheckInDate(selectedDate);
//       bookingState.setCheckInTime(selectedTime);
//       bookingState.setDuration(selectedDurationHours);
//       bookingState.setGuests(adultCount: adults, childrenCount: children);

//       // Show result message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(availabilityMessage!),
//           backgroundColor: hasAvailability ? Colors.green : Colors.orange,
//           action:
//               hasAvailability
//                   ? SnackBarAction(
//                     label: 'Proceed',
//                     textColor: Colors.white,
//                     onPressed: () => _proceedWithBooking(),
//                   )
//                   : null,
//         ),
//       );
//     } catch (e) {
//       print("Error checking availability: $e");
//       setState(() {
//         availability = RoomAvailability(available: {});
//         _isCheckingAvailability = false;
//         hasAvailability = false;
//         availabilityMessage = 'Failed to check availability. Please try again.';
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//       );
//     }
//   }

//   void _proceedWithBooking() {
//     if (hasAvailability && widget.onAvailabilityConfirmed != null) {
//       final searchParams = SearchParams(
//         state: widget.hotelState,
//         checkInDate: selectedDate,
//         checkInTime: selectedTime,
//         durationHours: selectedDurationHours,
//         adults: adults,
//         children: children,
//         rooms: rooms,
//       );
//       widget.onAvailabilityConfirmed!(searchParams);
//     }
//   }

//   String _formatCheckoutDate() {
//     DateTime checkoutDate = selectedDate.add(
//       Duration(hours: selectedDurationHours),
//     );
//     return '${checkoutDate.day.toString().padLeft(2, '0')}-${checkoutDate.month.toString().padLeft(2, '0')}-${checkoutDate.year}';
//   }

//   String _formatCheckoutTime() {
//     DateTime checkoutDate = selectedDate.add(
//       Duration(hours: selectedDurationHours),
//     );
//     TimeOfDay checkoutTime = TimeOfDay.fromDateTime(checkoutDate);
//     return checkoutTime.format(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header
//           // Container(
//           //   padding: const EdgeInsets.all(15),
//           //   child: Row(
//           //     children: [
//           //       const Text(
//           //         'Check Availability',
//           //         style: TextStyle(
//           //           fontSize: 18,
//           //           fontWeight: FontWeight.bold,
//           //           color: Colors.black87,
//           //         ),
//           //       ),
//           //       const Spacer(),
//           //       if (availabilityMessage != null)
//           //         Icon(
//           //           hasAvailability ? Icons.check_circle : Icons.error,
//           //           color: hasAvailability ? Colors.green : Colors.orange,
//           //           size: 20,
//           //         ),
//           //     ],
//           //   ),
//           // ),

//           // --- main content ---
//           Container(
//             padding: const EdgeInsets.all(15),
//             child: Expanded(
//               // ensures scroll takes available space
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // First Row: Check-in and Check-out
//                     Row(
//                       children: const [
//                         Text(
//                           'Check-in',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         Spacer(),
//                         Text(
//                           'Check-out',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     Row(
//                       children: [
//                         // Check-in Date and Time
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 showDatePicker = !showDatePicker;
//                                 showDurationDropdown = false;
//                                 showGuestSelector = false;
//                                 showCheckoutInfo = false;
//                                 _showAvailabilityButton = true;
//                               });
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 10,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: themeColor,
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.calendar_today,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Expanded(
//                                     child: Text(
//                                       '${selectedDate.day.toString().padLeft(2, '0')}-'
//                                       '${selectedDate.month.toString().padLeft(2, '0')}-'
//                                       '${selectedDate.year}',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     selectedTime.format(context),
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),

//                         // Check-out Date and Time
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {},
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 10,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.calendar_today,
//                                     size: 16,
//                                     color: Color.fromARGB(255, 114, 114, 114),
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Expanded(
//                                     child: Text(
//                                       _formatCheckoutDate(),
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         color: Color.fromARGB(
//                                           255,
//                                           114,
//                                           114,
//                                           114,
//                                         ),
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     _formatCheckoutTime(),
//                                     style: const TextStyle(
//                                       color: Color.fromARGB(255, 114, 114, 114),
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // Second Row: Duration and Guest/Room Info
//                     Row(
//                       children: [
//                         // Duration
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               showDurationDropdown = !showDurationDropdown;
//                               showDatePicker = false;
//                               showGuestSelector = false;
//                               showCheckoutInfo = false;
//                               _showAvailabilityButton = true;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 14,
//                               vertical: 10,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300],
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               _formatDuration(selectedDurationHours),
//                               style: const TextStyle(
//                                 color: Color.fromARGB(255, 114, 114, 114),
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),

//                         // Guest and Room Info
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 showGuestSelector = !showGuestSelector;
//                                 showDatePicker = false;
//                                 showDurationDropdown = false;
//                                 showCheckoutInfo = false;
//                                 _showAvailabilityButton = true;
//                               });
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 10,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: themeColor,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.people_outline,
//                                     size: 18,
//                                     color: Colors.white,
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Flexible(
//                                     child: Text(
//                                       '$adults Adults',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w800,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Flexible(
//                                     child: Text(
//                                       '$children Children',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w800,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Flexible(
//                                     child: Text(
//                                       '$rooms Room',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w800,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Extended sections
//           if (showDatePicker) _buildDatePickerSection(),
//           if (showDurationDropdown) _buildDurationSection(),
//           if (showGuestSelector) _buildGuestSection(),
//           if (showCheckoutInfo) _buildCheckoutInfoSection(),

//           // Check Availability Button (initially hidden)
//           if (_showAvailabilityButton || availabilityMessage != null) ...[
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed:
//                       _isCheckingAvailability ? null : _checkAvailability,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: themeColor,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child:
//                       _isCheckingAvailability
//                           ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Colors.white,
//                               ),
//                             ),
//                           )
//                           : const Text(
//                             'Check Availability',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                 ),
//               ),
//             ),
//           ],

//           // Availability message
//           if (availabilityMessage != null) ...[
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: hasAvailability ? Colors.green[50] : Colors.orange[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color:
//                         hasAvailability
//                             ? Colors.green[200]!
//                             : Colors.orange[200]!,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       hasAvailability
//                           ? Icons.check_circle_outline
//                           : Icons.info_outline,
//                       color: hasAvailability ? Colors.green : Colors.orange,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         availabilityMessage!,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color:
//                               hasAvailability
//                                   ? Colors.green[800]
//                                   : Colors.orange[800],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Proceed button when available
//             if (hasAvailability) ...[
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 10,
//                 ),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _proceedWithBooking,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                     child: const Text(
//                       'Proceed to Room Selection',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildCheckoutInfoSection() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: Container(
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.blue[50],
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.blue[200]!),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Check-out Information',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                     color: Colors.blue[800],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Icon(Icons.logout, color: Colors.blue[600], size: 18),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Check-out: ${_formatDateTime(checkoutDateTime, checkoutTime)}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDatePickerSection() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: Container(
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               DateFormat('MMMM yyyy').format(selectedDate).toUpperCase(),
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildCalendar(),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 const Text(
//                   'Check-in Time',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: () async {
//                     final TimeOfDay? time = await showTimePicker(
//                       context: context,
//                       initialTime: selectedTime,
//                       builder: (context, child) {
//                         return Theme(
//                           data: ThemeData(
//                             colorScheme: ColorScheme.light(primary: themeColor),
//                           ),
//                           child: child!,
//                         );
//                       },
//                     );
//                     if (time != null) {
//                       setState(() {
//                         selectedTime = time;
//                       });
//                     }
//                   },
//                   child: Text(
//                     selectedTime.format(context),
//                     style: TextStyle(
//                       color: themeColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   showDatePicker = false;
//                 });
//               },
//               style: _buttonStyle(),
//               child: const Text(
//                 'Done',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDurationSection() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: Container(
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.access_time, color: Colors.grey[400], size: 22),
//                 const SizedBox(width: 10),
//                 Text(
//                   'Choose duration',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children:
//                       durationOptions
//                           .map((hours) => _buildDurationOption(hours))
//                           .toList(),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   showDurationDropdown = false;
//                 });
//               },
//               style: _buttonStyle(),
//               child: const Text(
//                 'Done',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDurationOption(int hours) {
//     bool isSelected = selectedDurationHours == hours;
//     return GestureDetector(
//       onTap:
//           () => setState(() {
//             selectedDurationHours = hours;
//           }),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//         margin: const EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? themeColor.withOpacity(0.1) : Colors.grey[50],
//           border: Border.all(
//             color: isSelected ? themeColor : Colors.grey[300]!,
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Text(
//           _formatDuration(hours),
//           style: TextStyle(
//             color: isSelected ? themeColor : Colors.grey[700],
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGuestSection() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: Container(
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.people_outline, color: Colors.grey[400], size: 22),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'No. of guests',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             _buildGuestCounter(
//               'Adults',
//               adults,
//               (value) => setState(() {
//                 adults = value;
//               }),
//             ),
//             const SizedBox(height: 16),
//             _buildGuestCounter(
//               'Children',
//               children,
//               (value) => setState(() {
//                 children = value;
//               }),
//             ),
//             const SizedBox(height: 16),
//             _buildGuestCounter(
//               'Rooms',
//               rooms,
//               (value) => setState(() {
//                 rooms = value;
//               }),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   showGuestSelector = false;
//                 });
//               },
//               style: _buttonStyle(),
//               child: const Text(
//                 'Done',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGuestCounter(String label, int value, Function(int) onChanged) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey[700],
//           ),
//         ),
//         Row(
//           children: [
//             _buildCounterButton(
//               Icons.remove,
//               () => value > 0 ? onChanged(value - 1) : null,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 '$value',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ),
//             _buildCounterButton(Icons.add, () => onChanged(value + 1)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildCounterButton(IconData icon, VoidCallback? onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[400]!),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, size: 20, color: Colors.grey[600]),
//       ),
//     );
//   }

//   Widget _buildCalendar() {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children:
//               ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
//                 return Container(
//                   width: 36,
//                   child: Text(
//                     d,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 );
//               }).toList(),
//         ),
//         const SizedBox(height: 16),
//         ...List.generate(5, (weekIndex) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(7, (dayIndex) {
//                 int day = weekIndex * 7 + dayIndex - 2;
//                 if (day <= 0 || day > 31)
//                   return Container(width: 36, height: 36);
//                 bool isSelected = day == selectedDate.day;
//                 return GestureDetector(
//                   onTap:
//                       () => setState(() {
//                         selectedDate = DateTime(
//                           selectedDate.year,
//                           selectedDate.month,
//                           day,
//                         );
//                       }),
//                   child: Container(
//                     width: 36,
//                     height: 36,
//                     decoration:
//                         isSelected
//                             ? BoxDecoration(
//                               color: themeColor,
//                               borderRadius: BorderRadius.circular(18),
//                             )
//                             : null,
//                     child: Center(
//                       child: Text(
//                         '$day',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: isSelected ? Colors.white : Colors.black,
//                           fontWeight:
//                               isSelected ? FontWeight.bold : FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
//     backgroundColor: themeColor,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//   );
// }
