import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:tourism_app_new/Services/Providers/booking_state.dart';
import 'package:tourism_app_new/widgets/property_card.dart';
import 'package:tourism_app_new/Screens/testing/hotel_detail.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  GoogleMapController? _mapController;
  List<Hotel> _hotels = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    final bookingState = Provider.of<BookingState>(context, listen: false);
    if (bookingState.latitude == null || bookingState.longitude == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Current location not available.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hotels = await HotelApiService.searchHotels(
        latitude: bookingState.latitude,
        longitude: bookingState.longitude,
        radiusKm: bookingState.radiusKm,
      );
      setState(() {
        _hotels = hotels;
        _isLoading = false;
        _updateMarkers();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load hotels: $e";
      });
    }
  }

  void _updateMarkers() {
    final markers = _hotels.map((hotel) {
      return Marker(
        markerId: MarkerId(hotel.id.toString()),
        position: LatLng(hotel.latitude, hotel.longitude),
        infoWindow: InfoWindow(
          title: hotel.name,
          snippet: hotel.address,
        ),
      );
    }).toSet();
    setState(() {
      _markers = markers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = Provider.of<BookingState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotels Near You"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [5, 10, 20].map((radius) {
                return ChoiceChip(
                  label: Text('$radius km'),
                  selected: bookingState.radiusKm == radius,
                  onSelected: (selected) {
                    if (selected) {
                      bookingState.setLocation(radius: radius.toDouble());
                      _fetchHotels();
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _buildBody(bookingState),
    );
  }

  Widget _buildBody(BookingState bookingState) {
    if (bookingState.latitude == null || bookingState.longitude == null) {
      return const Center(child: Text("Getting your location..."));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(bookingState.latitude!, bookingState.longitude!),
              zoom: 14,
            ),
            markers: _markers,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _hotels.length,
            itemBuilder: (context, index) {
              final hotel = _hotels[index];
              return HotelCard(
                hotel: hotel,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnhancedHotelDetailsScreen(hotel: hotel),
                    ),
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