// // Screens/room_details_screen.dart
// import 'package:flutter/material.dart';
// import 'package:tourism_app_new/Services/Api%20Services/Authentication/hotel_api_service.dart';
// import 'package:tourism_app_new/Models/hotel_model.dart';
// import 'package:tourism_app_new/Models/room_model.dart';

// class RoomDetailsScreen extends StatefulWidget {
//   final int roomId;

//   const RoomDetailsScreen({super.key, required this.roomId});

//   @override
//   State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
// }

// class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
//   Room? _room;
//   Hotel? _hotel;
//   bool _isLoading = true;
//   String? _errorMessage;
//   PageController _imagePageController = PageController();
//   int _currentImageIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchRoomDetails();
//   }

//   @override
//   void dispose() {
//     _imagePageController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchRoomDetails() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // First, we need to get all rooms from all hotels to find this specific room
//       // This is a limitation since we don't have a direct getRoomById API
//       // You might want to add this API endpoint for better performance

//       // For now, we'll fetch hotel details first if we have the hotel ID
//       // If you have a direct room API, replace this logic

//       // Assuming you have a way to get the room directly or by hotel
//       // For demonstration, I'll show how it would work if you had the room data

//       // If you have a direct room API endpoint, use it here:
//       // final room = await RoomApiService.getRoomById(widget.roomId);

//       // For now, using placeholder logic - you'll need to implement based on your API
//       await _searchRoomInHotels();
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _searchRoomInHotels() async {
//     try {
//       // This is a workaround - ideally you'd have a direct room API
//       // You might need to modify this based on your actual API structure

//       // Get all hotels first (you might need to implement this API)
//       // For now, assuming you can get hotel by room or have a search

//       // Placeholder implementation - replace with your actual API call
//       // final room = await HotelApiService.getRoomById(widget.roomId);
//       // final hotel = await HotelApiService.getHotelById(room.hotelId);

//       // For demonstration, creating sample data
//       // Replace this with your actual API calls
//       setState(() {
//         _room = Room(
//           id: widget.roomId,
//           hotelId: 1,
//           name: "Deluxe Ocean View",
//           type: "Deluxe Room",
//           price: 150.0,
//           maxOccupancy: 2,
//           amenities: [
//             "WiFi",
//             "Air Conditioning",
//             "Mini Bar",
//             "Ocean View",
//             "Private Bathroom",
//           ],
//         );
//         // _hotel = Hotel(
//         //   id: 1,
//         //   name: "Sample Hotel",
//         //   address: "123 Beach Road, Colombo",
//         //   images: ["https://via.placeholder.com/400x300"],
//         //   description: "A beautiful hotel by the ocean",
//         //   //rating: 4.5,
//         //   //priceRange: "\$100-200",
//         //   //amenities: ["Pool", "Spa", "Restaurant"],
//         //   latitude: 6.9271,
//         //   longitude: 79.8612,
//         // );
//         _isLoading = false;
//       });

//       // TODO: Replace above with actual API calls:
//       /*
//       final room = await HotelApiService.getRoomById(widget.roomId);
//       final hotel = await HotelApiService.getHotelById(room.hotelId);
//       setState(() {
//         _room = room;
//         _hotel = hotel;
//         _isLoading = false;
//       });
//       */
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : _errorMessage != null
//               ? _buildErrorWidget()
//               : _buildContent(),
//       bottomNavigationBar: _room != null ? _buildBottomBar() : null,
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Room Details'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error, size: 64, color: Colors.red.shade400),
//               const SizedBox(height: 16),
//               Text(
//                 'Error loading room details',
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.red.shade700),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _fetchRoomDetails,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return CustomScrollView(
//       slivers: [
//         _buildSliverAppBar(),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildRoomInfo(),
//                 const SizedBox(height: 24),
//                 _buildPriceInfo(),
//                 const SizedBox(height: 24),
//                 _buildAmenities(),
//                 const SizedBox(height: 24),
//                 //_buildHotelInfo(),
//                 const SizedBox(height: 100), // Space for bottom bar
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: 300.0,
//       floating: false,
//       pinned: true,
//       backgroundColor: Colors.blue,
//       foregroundColor: Colors.white,
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           _room?.name ?? 'Room Details',
//           style: const TextStyle(
//             shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
//           ),
//         ),
//         background: _buildImageCarousel(),
//       ),
//     );
//   }

//   Widget _buildImageCarousel() {
//     // Using hotel images or placeholder
//     final images = _hotel?.images ?? ['https://via.placeholder.com/400x300'];

//     return Stack(
//       children: [
//         PageView.builder(
//           controller: _imagePageController,
//           onPageChanged: (index) {
//             setState(() {
//               _currentImageIndex = index;
//             });
//           },
//           itemCount: images.length,
//           itemBuilder: (context, index) {
//             return Image.network(
//               images[index],
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey.shade300,
//                   child: const Center(
//                     child: Icon(Icons.hotel, size: 64, color: Colors.grey),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//         if (images.length > 1)
//           Positioned(
//             bottom: 16,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children:
//                   images.asMap().entries.map((entry) {
//                     return Container(
//                       width: 8,
//                       height: 8,
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color:
//                             _currentImageIndex == entry.key
//                                 ? Colors.white
//                                 : Colors.white54,
//                       ),
//                     );
//                   }).toList(),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildRoomInfo() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.bed, color: Colors.blue),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Room Information',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow('Room Name', _room!.name, Icons.hotel),
//             _buildInfoRow('Room Type', _room!.type, Icons.category),
//             _buildInfoRow(
//               'Max Occupancy',
//               '${_room!.maxOccupancy} guests',
//               Icons.people,
//             ),
//             _buildInfoRow(
//               'Room ID',
//               '#${_room!.id}',
//               Icons.confirmation_number,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPriceInfo() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.attach_money, color: Colors.green),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Pricing',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.green.shade200),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     '\$${_room!.price.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green.shade700,
//                     ),
//                   ),
//                   Text(
//                     'per night',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.green.shade600,
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

//   Widget _buildAmenities() {
//     if (_room!.amenities.isEmpty) return const SizedBox.shrink();

//     return Card(
//       //     child: Padding(
//       //       padding: const EdgeInsets.all(16.0),
//       //       child: Column(
//       //         crossAxisAlignment: CrossAxisAlignment.start,
//       //         children: [
//       //           Row(
//       //             children: [
//       //               const Icon(Icons.star, color: Colors.amber),
//       //               const SizedBox(width: 8),
//       //               const Text(
//       //                 'Room Amenities',
//       //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       //               ),
//       //             ],
//       //           ),
//       //           const SizedBox(height: 16),
//       //           Wrap(
//       //             spacing: 12,
//       //             runSpacing: 12,
//       //             children:
//       //                 _room!.amenities.map((amenity) {
//       //                   return Container(
//       //                     padding: const EdgeInsets.symmetric(
//       //                       horizontal: 12,
//       //                       vertical: 8,
//       //                     ),
//       //                     decoration: BoxDecoration(
//       //                       color: Colors.blue.shade50,
//       //                       borderRadius: BorderRadius.circular(20),
//       //                       border: Border.all(color: Colors.blue.shade200),
//       //                     ),
//       //                     child: Row(
//       //                       mainAxisSize: MainAxisSize.min,
//       //                       children: [
//       //                         Icon(
//       //                           _getAmenityIcon(amenity),
//       //                           size: 16,
//       //                           color: Colors.blue.shade700,
//       //                         ),
//       //                         const SizedBox(width: 6),
//       //                         Text(
//       //                           amenity,
//       //                           style: TextStyle(
//       //                             color: Colors.blue.shade700,
//       //                             fontWeight: FontWeight.w500,
//       //                           ),
//       //                         ),
//       //                       ],
//       //                     ),
//       //                   );
//       //                 }).toList(),
//       //           ),
//       //         ],
//       //       ),
//       //     ),
//       //   );
//       // }

//       // Widget _buildHotelInfo() {
//       //   if (_hotel == null) return const SizedBox.shrink();

//       //   return Card(
//       //     child: Padding(
//       //       padding: const EdgeInsets.all(16.0),
//       //       child: Column(
//       //         crossAxisAlignment: CrossAxisAlignment.start,
//       //         children: [
//       //           Row(
//       //             children: [
//       //               const Icon(Icons.location_city, color: Colors.purple),
//       //               const SizedBox(width: 8),
//       //               const Text(
//       //                 'Hotel Information',
//       //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       //               ),
//       //             ],
//       //           ),
//       //           const SizedBox(height: 16),
//       //           Row(
//       //             crossAxisAlignment: CrossAxisAlignment.start,
//       //             children: [
//       //               if (_hotel!.images.isNotEmpty)
//       //                 ClipRRect(
//       //                   borderRadius: BorderRadius.circular(8),
//       //                   child: Image.network(
//       //                     _hotel!.images[0],
//       //                     width: 80,
//       //                     height: 80,
//       //                     fit: BoxFit.cover,
//       //                     errorBuilder: (context, error, stackTrace) {
//       //                       return Container(
//       //                         width: 80,
//       //                         height: 80,
//       //                         decoration: BoxDecoration(
//       //                           color: Colors.grey.shade300,
//       //                           borderRadius: BorderRadius.circular(8),
//       //                         ),
//       //                         child: const Icon(Icons.hotel, color: Colors.grey),
//       //                       );
//       //                     },
//       //                   ),
//       //                 ),
//       //               const SizedBox(width: 12),
//       //               Expanded(
//       //                 child: Column(
//       //                   crossAxisAlignment: CrossAxisAlignment.start,
//       //                   children: [
//       //                     Text(
//       //                       _hotel!.name,
//       //                       style: const TextStyle(
//       //                         fontSize: 18,
//       //                         fontWeight: FontWeight.bold,
//       //                       ),
//       //                     ),
//       //                     const SizedBox(height: 4),
//       //                     Row(
//       //                       children: [
//       //                         Icon(
//       //                           Icons.star,
//       //                           color: Colors.amber.shade600,
//       //                           size: 16,
//       //                         ),
//       //                         const SizedBox(width: 4),
//       //                         Text(
//       //                           _hotel!.rating.toString(),
//       //                           style: TextStyle(
//       //                             fontWeight: FontWeight.w500,
//       //                             color: Colors.grey.shade700,
//       //                           ),
//       //                         ),
//       //                       ],
//       //                     ),
//       //                     const SizedBox(height: 4),
//       //                     Text(
//       //                       _hotel!.address,
//       //                       style: TextStyle(
//       //                         color: Colors.grey.shade600,
//       //                         fontSize: 14,
//       //                       ),
//       //                     ),
//       //                   ],
//       //                 ),
//       //               ),
//       //             ],
//       //           ),
//       //           if (_hotel!.description.isNotEmpty) ...[
//       //             const SizedBox(height: 12),
//       //             Text(
//       //               _hotel!.description,
//       //               style: TextStyle(color: Colors.grey.shade700, height: 1.5),
//       //             ),
//       //           ],
//       //           if (_hotel!.amenities.isNotEmpty) ...[
//       //             const SizedBox(height: 12),
//       //             const Text(
//       //               'Hotel Amenities:',
//       //               style: TextStyle(fontWeight: FontWeight.w500),
//       //             ),
//       //             const SizedBox(height: 8),
//       //             // Wrap(
//       //             //   spacing: 8,
//       //             //   runSpacing: 4,
//       //             //   children:
//       //             //       _hotel!.amenities.map((amenity) {
//       //             //         return Chip(
//       //             //           label: Text(
//       //             //             amenity,
//       //             //             style: const TextStyle(fontSize: 12),
//       //             //           ),
//       //             //           backgroundColor: Colors.purple.shade50,
//       //             //           side: BorderSide(color: Colors.purple.shade200),
//       //             //         );
//       //             //       }).toList(),
//       //             // ),
//       //           ],
//       //         ],
//       //       ),
//       //     ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey.shade600),
//           const SizedBox(width: 12),
//           Text(
//             '$label:',
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               flex: 2,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '\$${_room!.price.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                   const Text(
//                     'per night',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 3,
//               child: ElevatedButton(
//                 onPressed: () => _bookRoom(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'Book This Room',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getAmenityIcon(String amenity) {
//     switch (amenity.toLowerCase()) {
//       case 'wifi':
//       case 'wi-fi':
//         return Icons.wifi;
//       case 'air conditioning':
//       case 'ac':
//         return Icons.ac_unit;
//       case 'mini bar':
//       case 'minibar':
//         return Icons.local_bar;
//       case 'ocean view':
//       case 'sea view':
//         return Icons.waves;
//       case 'private bathroom':
//       case 'bathroom':
//         return Icons.bathtub;
//       case 'tv':
//       case 'television':
//         return Icons.tv;
//       case 'balcony':
//         return Icons.balcony;
//       case 'room service':
//         return Icons.room_service;
//       case 'safe':
//         return Icons.security;
//       case 'phone':
//         return Icons.phone;
//       default:
//         return Icons.check_circle;
//     }
//   }

//   void _bookRoom() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildBookingBottomSheet(),
//     );
//   }

//   Widget _buildBookingBottomSheet() {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Book ${_room!.name}',
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Room:',
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     Text(_room!.name),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Price:',
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     Text(
//                       '\$${_room!.price.toStringAsFixed(2)} / night',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Hotel:',
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     Text(_hotel?.name ?? 'Unknown Hotel'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _processBooking();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Confirm Booking'),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
//         ],
//       ),
//     );
//   }

//   void _processBooking() {
//     // Implement your booking logic here
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Booking Confirmed'),
//             content: Text(
//               'Your booking for ${_room!.name} has been confirmed!',
//             ),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.pop(context); // Go back to previous screen
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }
// }
