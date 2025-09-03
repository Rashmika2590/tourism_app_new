// // Widgets/room_availability_widget.dart
// import 'package:flutter/material.dart';
// import 'package:tourism_app_new/Services/Api%20Services/Authentication/availablility_api_service.dart';
// import 'package:tourism_app_new/models/availability_model.dart';

// class RoomAvailabilityWidget extends StatefulWidget {
//   final Function(RoomAvailability)? onResultsFound;
//   final bool showTitle;
//   final bool compact;

//   const RoomAvailabilityWidget({
//     super.key,
//     this.onResultsFound,
//     this.showTitle = true,
//     this.compact = false,
//   });

//   @override
//   State<RoomAvailabilityWidget> createState() => _RoomAvailabilityWidgetState();
// }

// class _RoomAvailabilityWidgetState extends State<RoomAvailabilityWidget> {
//   final _formKey = GlobalKey<FormState>();

//   DateTime? _checkInDate;
//   DateTime? _checkOutDate;
//   String _checkInTime = '10:00:00';
//   String _checkOutTime = '12:00:00';

//   final _stateController = TextEditingController();
//   final _adultCountController = TextEditingController(text: '1');
//   final _childrenCountController = TextEditingController(text: '0');

//   bool _isLoading = false;
//   bool _showAdvanced = false;

//   @override
//   void dispose() {
//     _stateController.dispose();
//     _adultCountController.dispose();
//     _childrenCountController.dispose();
//     super.dispose();
//   }

//   Future<void> _searchAvailability() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_checkInDate == null || _checkOutDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select both check-in and check-out dates'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final availability = await RoomAvailabilityService.searchAvailability(
//         checkInDate: _checkInDate!,
//         checkInTime: _checkInTime,
//         checkOutDate: _checkOutDate!,
//         checkOutTime: _checkOutTime,
//         state: _stateController.text.isEmpty ? null : _stateController.text,
//         adultCount: int.tryParse(_adultCountController.text),
//         childrenCount: int.tryParse(_childrenCountController.text),
//       );

//       if (widget.onResultsFound != null) {
//         widget.onResultsFound!(availability);
//       }

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             availability.hasAvailableRooms()
//                 ? 'Found ${availability.getTotalAvailableRooms()} available rooms'
//                 : 'No rooms available for selected dates',
//           ),
//           backgroundColor:
//               availability.hasAvailableRooms() ? Colors.green : Colors.orange,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(widget.compact ? 12.0 : 16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Title
//               if (widget.showTitle) ...[
//                 Row(
//                   children: [
//                     const Icon(Icons.search, color: Colors.blue),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Search Available Rooms',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//               ],

//               // Check-in Date and Time
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: InkWell(
//                       onTap: () => _selectDate(true),
//                       child: InputDecorator(
//                         decoration: InputDecoration(
//                           labelText: 'Check-in Date *',
//                           border: const OutlineInputBorder(),
//                           suffixIcon: const Icon(Icons.calendar_today),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: widget.compact ? 8 : 16,
//                           ),
//                         ),
//                         child: Text(
//                           _checkInDate != null
//                               ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
//                               : 'Select date',
//                           style: TextStyle(fontSize: widget.compact ? 14 : 16),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     flex: 1,
//                     child: DropdownButtonFormField<String>(
//                       value: _checkInTime,
//                       decoration: InputDecoration(
//                         labelText: 'Time *',
//                         border: const OutlineInputBorder(),
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: widget.compact ? 8 : 16,
//                         ),
//                       ),
//                       items: _getTimeOptions(),
//                       onChanged:
//                           (value) => setState(() => _checkInTime = value!),
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: widget.compact ? 12 : 16),

//               // Check-out Date and Time
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: InkWell(
//                       onTap: () => _selectDate(false),
//                       child: InputDecorator(
//                         decoration: InputDecoration(
//                           labelText: 'Check-out Date *',
//                           border: const OutlineInputBorder(),
//                           suffixIcon: const Icon(Icons.calendar_today),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: widget.compact ? 8 : 16,
//                           ),
//                         ),
//                         child: Text(
//                           _checkOutDate != null
//                               ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
//                               : 'Select date',
//                           style: TextStyle(fontSize: widget.compact ? 14 : 16),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     flex: 1,
//                     child: DropdownButtonFormField<String>(
//                       value: _checkOutTime,
//                       decoration: InputDecoration(
//                         labelText: 'Time *',
//                         border: const OutlineInputBorder(),
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: widget.compact ? 8 : 16,
//                         ),
//                       ),
//                       items: _getTimeOptions(),
//                       onChanged:
//                           (value) => setState(() => _checkOutTime = value!),
//                     ),
//                   ),
//                 ],
//               ),

//               // Advanced Options Toggle
//               SizedBox(height: widget.compact ? 12 : 16),
//               TextButton.icon(
//                 onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
//                 icon: Icon(
//                   _showAdvanced ? Icons.expand_less : Icons.expand_more,
//                 ),
//                 label: Text(
//                   _showAdvanced ? 'Hide Filters' : 'Show More Filters',
//                 ),
//               ),

//               // Advanced Options
//               if (_showAdvanced) ...[
//                 SizedBox(height: widget.compact ? 8 : 12),

//                 // State/Location
//                 TextFormField(
//                   controller: _stateController,
//                   decoration: InputDecoration(
//                     labelText: 'State/Location',
//                     border: const OutlineInputBorder(),
//                     hintText: 'e.g., Colombo',
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: widget.compact ? 8 : 16,
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: widget.compact ? 8 : 12),

//                 // Guest Counts
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _adultCountController,
//                         decoration: InputDecoration(
//                           labelText: 'Adults',
//                           border: const OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: widget.compact ? 8 : 16,
//                           ),
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value != null && value.isNotEmpty) {
//                             final count = int.tryParse(value);
//                             if (count == null || count < 0) {
//                               return 'Valid count required';
//                             }
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _childrenCountController,
//                         decoration: InputDecoration(
//                           labelText: 'Children',
//                           border: const OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: widget.compact ? 8 : 16,
//                           ),
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value != null && value.isNotEmpty) {
//                             final count = int.tryParse(value);
//                             if (count == null || count < 0) {
//                               return 'Valid count required';
//                             }
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],

//               SizedBox(height: widget.compact ? 16 : 24),

//               // Search Button
//               ElevatedButton.icon(
//                 onPressed: _isLoading ? null : _searchAvailability,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(
//                     vertical: widget.compact ? 12 : 16,
//                   ),
//                 ),
//                 icon:
//                     _isLoading
//                         ? const SizedBox(
//                           height: 16,
//                           width: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         )
//                         : const Icon(Icons.search),
//                 label: Text(
//                   _isLoading ? 'Searching...' : 'Search Rooms',
//                   style: TextStyle(fontSize: widget.compact ? 14 : 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDate(bool isCheckIn) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );

//     if (picked != null) {
//       setState(() {
//         if (isCheckIn) {
//           _checkInDate = picked;
//           // Clear check-out date if it's before new check-in date
//           if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
//             _checkOutDate = null;
//           }
//         } else {
//           _checkOutDate = picked;
//         }
//       });
//     }
//   }

//   List<DropdownMenuItem<String>> _getTimeOptions() {
//     final times = <String>[];
//     for (int hour = 0; hour < 24; hour++) {
//       for (int minute = 0; minute < 60; minute += 30) {
//         final timeStr =
//             '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
//         times.add(timeStr);
//       }
//     }

//     return times.map((time) {
//       final displayTime = time.substring(0, 5); // Remove :00 for display
//       return DropdownMenuItem(value: time, child: Text(displayTime));
//     }).toList();
//   }
// }

// // Alternative Compact Search Card Widget
// class CompactRoomSearchCard extends StatefulWidget {
//   final Function(RoomAvailability) onSearch;

//   const CompactRoomSearchCard({super.key, required this.onSearch});

//   @override
//   State<CompactRoomSearchCard> createState() => _CompactRoomSearchCardState();
// }

// class _CompactRoomSearchCardState extends State<CompactRoomSearchCard> {
//   DateTime? _checkInDate;
//   DateTime? _checkOutDate;
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.hotel, color: Colors.blue),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Quick Room Search',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () => _selectDate(true),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Check-in',
//                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _checkInDate != null
//                                 ? '${_checkInDate!.day}/${_checkInDate!.month}'
//                                 : 'Select date',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 8),
//                   child: const Icon(Icons.arrow_forward, color: Colors.grey),
//                 ),

//                 Expanded(
//                   child: InkWell(
//                     onTap: () => _selectDate(false),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Check-out',
//                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _checkOutDate != null
//                                 ? '${_checkOutDate!.day}/${_checkOutDate!.month}'
//                                 : 'Select date',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _isLoading ? null : _quickSearch,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 icon:
//                     _isLoading
//                         ? const SizedBox(
//                           height: 16,
//                           width: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         )
//                         : const Icon(Icons.search),
//                 label: Text(_isLoading ? 'Searching...' : 'Search'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDate(bool isCheckIn) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );

//     if (picked != null) {
//       setState(() {
//         if (isCheckIn) {
//           _checkInDate = picked;
//           if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
//             _checkOutDate = null;
//           }
//         } else {
//           _checkOutDate = picked;
//         }
//       });
//     }
//   }

//   Future<void> _quickSearch() async {
//     if (_checkInDate == null || _checkOutDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select both dates'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final availability = await RoomAvailabilityService.searchAvailability(
//         checkInDate: _checkInDate!,
//         checkInTime: '10:00:00',
//         checkOutDate: _checkOutDate!,
//         checkOutTime: '12:00:00',
//         adultCount: 1,
//         childrenCount: 0,
//       );

//       widget.onSearch(availability);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
// }
