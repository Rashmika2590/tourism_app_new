// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class PickLocationScreen extends StatefulWidget {
//   const PickLocationScreen({Key? key}) : super(key: key);

//   @override
//   State<PickLocationScreen> createState() => _PickLocationScreenState();
// }

// class _PickLocationScreenState extends State<PickLocationScreen> {
//   GoogleMapController? _mapController;
//   LatLng? _selectedPosition;

//   void _onMapTapped(LatLng position) {
//     setState(() {
//       _selectedPosition = position;
//     });
//   }

//   void _confirmLocation() {
//     if (_selectedPosition != null) {
//       Navigator.pop(context, _selectedPosition);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please tap on map to select location")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Pick Hotel Location")),
//       body: GoogleMap(
//         initialCameraPosition: const CameraPosition(
//           target: LatLng(6.9271, 79.8612), // default Colombo
//           zoom: 12,
//         ),
//         onMapCreated: (controller) => _mapController = controller,
//         onTap: _onMapTapped,
//         markers:
//             _selectedPosition == null
//                 ? {}
//                 : {
//                   Marker(
//                     markerId: const MarkerId("selected"),
//                     position: _selectedPosition!,
//                   ),
//                 },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _confirmLocation,
//         child: const Icon(Icons.check),
//       ),
//     );
//   }
// }
