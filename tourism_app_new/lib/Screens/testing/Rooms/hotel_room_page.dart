// import 'package:flutter/material.dart';
// import 'package:tourism_app_new/Services/Api%20Services/Authentication/room_api_service.dart';
// import 'package:tourism_app_new/models/availability_model.dart';
// import 'package:tourism_app_new/Models/hotel_model.dart';
// import 'package:tourism_app_new/models/room_model.dart';

// class HotelRoomsPage extends StatefulWidget {
//   final RoomAvailability availability;
//   final Map<int, Hotel> hotelDetails;

//   const HotelRoomsPage({
//     super.key,
//     required this.availability,
//     required this.hotelDetails,
//   });

//   @override
//   State<HotelRoomsPage> createState() => _HotelRoomsPageState();
// }

// class _HotelRoomsPageState extends State<HotelRoomsPage> {
//   Map<int, List<Room>> _hotelRooms = {}; // hotelId -> rooms
//   Map<int, bool> _isLoadingRooms = {}; // hotelId -> loading state

//   @override
//   void initState() {
//     super.initState();
//     _fetchAllHotelRooms();
//   }

//   Future<void> _fetchAllHotelRooms() async {
//     for (int hotelId in widget.availability.hotelIds) {
//       setState(() {
//         _isLoadingRooms[hotelId] = true;
//       });
//       try {
//         setState(() {
//           _hotelRooms[hotelId];
//         });
//       } catch (e) {
//         debugPrint("Failed to fetch rooms for hotel $hotelId: $e");
//       } finally {
//         setState(() {
//           _isLoadingRooms[hotelId] = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Available Hotels & Rooms")),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children:
//             widget.availability.hotelIds.map((hotelId) {
//               final hotel = widget.hotelDetails[hotelId];
//               final rooms = _hotelRooms[hotelId] ?? [];
//               final isLoading = _isLoadingRooms[hotelId] ?? false;

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Hotel name
//                       Text(
//                         hotel?.name ?? "Hotel ID: $hotelId",
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         hotel?.state ?? "Unknown Location",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       if (isLoading)
//                         const Center(child: CircularProgressIndicator())
//                       else if (rooms.isEmpty)
//                         const Text("No rooms available for this hotel")
//                       else
//                         DefaultTabController(
//                           length: rooms.length,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Horizontal tabs for rooms
//                               TabBar(
//                                 isScrollable: true,
//                                 labelColor: Colors.blue,
//                                 unselectedLabelColor: Colors.grey,
//                                 indicatorColor: Colors.blue,
//                                 tabs:
//                                     rooms.map((room) {
//                                       return Tab(text: room.name);
//                                     }).toList(),
//                               ),
//                               SizedBox(
//                                 height: 200, // height for room details area
//                                 child: TabBarView(
//                                   children:
//                                       rooms.map((room) {
//                                         return Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 room.name,
//                                                 style: const TextStyle(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Text(
//                                                 'Price: LKR ${room.price}',
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Text(
//                                                 'Capacity: ${room.maxOccupancy} persons',
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Text(
//                                                 'Amenities: ${room.amenities.join(', ')}',
//                                               ),
//                                               // Add more room details here
//                                             ],
//                                           ),
//                                         );
//                                       }).toList(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//       ),
//     );
//   }
// }
