// // Widgets/room_availability_results_widget.dart
// import 'package:flutter/material.dart';
// import 'package:tourism_app_new/models/availability_model.dart';
// import 'package:tourism_app_new/Models/hotel_model.dart';
// import 'package:tourism_app_new/Services/Api%20Services/Authentication/hotel_api_service.dart';

// class RoomAvailabilityResultsWidget extends StatefulWidget {
//   final RoomAvailability availability;
//   final Function(String hotelId, int roomId)? onRoomSelected;
//   final bool showDetailedView;

//   const RoomAvailabilityResultsWidget({
//     super.key,
//     required this.availability,
//     this.onRoomSelected,
//     this.showDetailedView = true,
//   });

//   @override
//   State<RoomAvailabilityResultsWidget> createState() =>
//       _RoomAvailabilityResultsWidgetState();
// }

// class _RoomAvailabilityResultsWidgetState
//     extends State<RoomAvailabilityResultsWidget> {
//   final Map<String, Hotel> _hotelDetails = {};
//   final Map<String, bool> _loadingHotels = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchHotelDetails();
//   }

//   Future<void> _fetchHotelDetails() async {
//     for (String hotelId in widget.availability.hotelIds) {
//       if (!_hotelDetails.containsKey(hotelId)) {
//         setState(() => _loadingHotels[hotelId] = true);
//         try {
//           final hotel = await HotelApiService.getHotelById(int.parse(hotelId));
//           setState(() {
//             _hotelDetails[hotelId] = hotel;
//             _loadingHotels[hotelId] = false;
//           });
//         } catch (_) {
//           setState(() => _loadingHotels[hotelId] = false);
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!widget.availability.hasAvailableRooms()) {
//       return _buildNoResultsCard();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSummaryCard(context),
//         const SizedBox(height: 16),
//         if (widget.showDetailedView) ...[
//           Text(
//             'Available Hotels & Rooms',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 12),
//           ...widget.availability.hotelIds.map(
//             (hotelId) => _buildHotelCard(hotelId),
//           ),
//         ] else ...[
//           _buildCompactList(),
//         ],
//       ],
//     );
//   }

//   Widget _buildNoResultsCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             Icon(Icons.hotel_outlined, size: 64, color: Colors.grey.shade400),
//             const SizedBox(height: 16),
//             const Text(
//               'No Available Rooms',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No rooms match your search criteria for the selected dates.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Try adjusting your dates or search filters.',
//               style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryCard(BuildContext context) {
//     return Card(
//       elevation: 2,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade50, Colors.green.shade100],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Search Results Found!',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green.shade800,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${widget.availability.getTotalAvailableRooms()} rooms available in ${widget.availability.hotelIds.length} hotels',
//                     style: TextStyle(
//                       color: Colors.green.shade700,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHotelCard(String hotelId) {
//     final roomIds = widget.availability.getRoomIdsForHotel(hotelId);
//     final hotel = _hotelDetails[hotelId];
//     final isLoading = _loadingHotels[hotelId] ?? false;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(8),
//                 topRight: Radius.circular(8),
//               ),
//             ),
//             child:
//                 isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : Row(
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: Colors.blue,
//                           radius: 24,
//                           backgroundImage:
//                               hotel != null && hotel.images.isNotEmpty
//                                   ? NetworkImage(hotel.images[0])
//                                   : null,
//                           child:
//                               hotel != null && hotel.images.isEmpty
//                                   ? Text(
//                                     hotelId,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                   )
//                                   : null,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 hotel?.name ?? 'Hotel ID: $hotelId',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               if (hotel != null) ...[
//                                 Text(
//                                   hotel.address,
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 const SizedBox(height: 4),
//                               ],
//                               Text(
//                                 '${roomIds.length} rooms available',
//                                 style: TextStyle(
//                                   color: Colors.green.shade700,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Chip(
//                           label: Text('${roomIds.length}'),
//                           backgroundColor: Colors.green.shade100,
//                           labelStyle: TextStyle(
//                             color: Colors.green.shade800,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//           ),
//           // Available Rooms
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Available Rooms:',
//                   style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children:
//                       roomIds
//                           .map(
//                             (roomId) => InkWell(
//                               onTap:
//                                   widget.onRoomSelected != null
//                                       ? () => widget.onRoomSelected!(
//                                         hotelId,
//                                         roomId,
//                                       )
//                                       : null,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.shade100,
//                                   borderRadius: BorderRadius.circular(20),
//                                   border: Border.all(
//                                     color: Colors.blue.shade200,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.door_front_door,
//                                       size: 16,
//                                       color: Colors.blue.shade700,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       'Room $roomId',
//                                       style: TextStyle(
//                                         color: Colors.blue.shade700,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     if (widget.onRoomSelected != null) ...[
//                                       const SizedBox(width: 4),
//                                       Icon(
//                                         Icons.chevron_right,
//                                         size: 16,
//                                         color: Colors.blue.shade700,
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactList() {
//     return Column(
//       children:
//           widget.availability.hotelIds.map((hotelId) {
//             final roomIds = widget.availability.getRoomIdsForHotel(hotelId);
//             final hotel = _hotelDetails[hotelId];
//             return Card(
//               margin: const EdgeInsets.only(bottom: 8),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.blue,
//                   backgroundImage:
//                       hotel != null && hotel.images.isNotEmpty
//                           ? NetworkImage(hotel.images[0])
//                           : null,
//                   child:
//                       hotel != null && hotel.images.isEmpty
//                           ? Text(
//                             hotelId,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )
//                           : null,
//                 ),
//                 title: Text(hotel?.name ?? 'Hotel $hotelId'),
//                 subtitle: Text('Rooms: ${roomIds.join(', ')}'),
//                 trailing: Chip(
//                   label: Text('${roomIds.length}'),
//                   backgroundColor: Colors.green.shade100,
//                 ),
//                 onTap:
//                     widget.onRoomSelected != null
//                         ? () {
//                           if (roomIds.isNotEmpty) {
//                             widget.onRoomSelected!(hotelId, roomIds.first);
//                           }
//                         }
//                         : null,
//               ),
//             );
//           }).toList(),
//     );
//   }
// }

// // Dialog for showing results
// class RoomAvailabilityDialog extends StatelessWidget {
//   final RoomAvailability availability;
//   final Function(String hotelId, int roomId)? onRoomSelected;

//   const RoomAvailabilityDialog({
//     super.key,
//     required this.availability,
//     this.onRoomSelected,
//   });

//   static Future<void> show(
//     BuildContext context,
//     RoomAvailability availability, {
//     Function(String hotelId, int roomId)? onRoomSelected,
//   }) {
//     return showDialog(
//       context: context,
//       builder:
//           (context) => RoomAvailabilityDialog(
//             availability: availability,
//             onRoomSelected: onRoomSelected,
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Row(
//         children: [
//           Icon(Icons.hotel, color: Colors.blue),
//           SizedBox(width: 8),
//           Text('Available Rooms'),
//         ],
//       ),
//       content: SizedBox(
//         width: double.maxFinite,
//         child:
//             availability.hasAvailableRooms()
//                 ? SingleChildScrollView(
//                   child: RoomAvailabilityResultsWidget(
//                     availability: availability,
//                     onRoomSelected:
//                         onRoomSelected != null
//                             ? (hotelId, roomId) {
//                               Navigator.of(context).pop();
//                               onRoomSelected!(hotelId, roomId);
//                             }
//                             : null,
//                     showDetailedView: false,
//                   ),
//                 )
//                 : const Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.hotel_outlined, size: 48, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No rooms available for the selected dates.',
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Close'),
//         ),
//       ],
//     );
//   }
// }
