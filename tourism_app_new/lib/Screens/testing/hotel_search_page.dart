import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:tourism_app_new/Services/Location/location_service.dart';
import 'package:tourism_app_new/widgets/hotel_card.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({Key? key}) : super(key: key);

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  // Controllers for search filters
  final _stateController = TextEditingController();
  final _radiusController = TextEditingController(text: '10'); // Default radius

  // State variables
  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  bool _isLoading = true;
  bool _showFilters = false;
  String _searchQuery = '';
  String _currentLocationName = '';

  @override
  void initState() {
    super.initState();
    _searchByCurrentLocation();
  }

  @override
  void dispose() {
    _stateController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _loadAllHotels() async {
    setState(() => _isLoading = true);
    try {
      final hotels = await HotelApiService.getAllHotels();
      setState(() {
        _hotels = hotels;
        _filteredHotels = hotels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load hotels: $e');
    }
  }

  Future<void> _searchByCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await LocationService.getCurrentPosition();
      final placemark = await LocationService.getPlacemarkFromPosition(
        position,
      );
      final locationName =
          placemark.locality ??
          placemark.administrativeArea ??
          'Current Location';

      final radius = double.tryParse(_radiusController.text.trim()) ?? 10.0;

      final hotels = await HotelApiService.searchHotels(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusKm: radius,
      );

      setState(() {
        _hotels = hotels;
        _filteredHotels = hotels;
        _isLoading = false;
        _currentLocationName = locationName;
        _stateController.text = locationName;
      });
      _showSuccessSnackBar('Showing hotels near $locationName');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to get location or search hotels: $e');
      _loadAllHotels(); // Fallback to loading all hotels
    }
  }

  Future<void> _searchHotels() async {
    setState(() => _isLoading = true);
    try {
      final hotels = await HotelApiService.searchHotels(
        state:
            _stateController.text.trim().isEmpty
                ? null
                : _stateController.text.trim(),
        radiusKm:
            _radiusController.text.trim().isEmpty
                ? null
                : double.tryParse(_radiusController.text.trim()),
      );

      setState(() {
        _hotels = hotels;
        _filteredHotels = hotels;
        _isLoading = false;
        _showFilters = false;
      });
      _showSuccessSnackBar('Found ${hotels.length} hotels');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Search failed: $e');
    }
  }

  void _clearFilters() {
    _stateController.clear();
    _radiusController.text = '10';
    setState(() {
      _showFilters = false;
      _currentLocationName = '';
    });
    _loadAllHotels();
  }

  void _filterHotelsByName(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredHotels = _hotels;
      } else {
        _filteredHotels =
            _hotels.where((hotel) {
              return hotel.name.toLowerCase().contains(query.toLowerCase()) ||
                  hotel.address.toLowerCase().contains(query.toLowerCase()) ||
                  hotel.state.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _navigateToHotelDetails(Hotel hotel) {
    Navigator.pushNamed(context, '/hotel_details', arguments: hotel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hotels'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
          ),
          IconButton(
            onPressed: _searchByCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'Search Nearby',
          ),
          IconButton(
            onPressed: _loadAllHotels,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilterSection(),
          _buildResultsHeader(),
          Expanded(child: _buildHotelsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-hotel'),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Create New Hotel',
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: _filterHotelsByName,
        decoration: InputDecoration(
          hintText: 'Search hotels by name, address, or state...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _filterHotelsByName('');
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.clear),
                  )
                  : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State or City',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _radiusController,
                  decoration: const InputDecoration(
                    labelText: 'Radius (km)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _searchHotels,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _searchByCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.my_location),
                  label: const Text('Search Nearby'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _currentLocationName.isNotEmpty
                  ? '${_filteredHotels.length} Hotels near $_currentLocationName'
                  : '${_filteredHotels.length} Hotels Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildHotelsList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading hotels...'),
          ],
        ),
      );
    }

    if (_filteredHotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hotels found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _showFilters
                  ? 'Try adjusting your search criteria'
                  : 'Use the location button to find hotels near you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _searchByCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Search Nearby'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _searchByCurrentLocation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredHotels.length,
        itemBuilder: (context, index) {
          final hotel = _filteredHotels[index];
          return HotelCard(
            hotel: hotel,
            onTap: () => _navigateToHotelDetails(hotel),
          );
        },
      ),
    );
  }
}
