import 'package:flutter/material.dart';
import 'package:tourism_app_new/Models/hotel_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/Authentication/hotel_api_service.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({Key? key}) : super(key: key);

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  // Controllers for search filters
  final _stateController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();

  // State variables
  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  bool _isLoading = true;
  bool _showFilters = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllHotels();
  }

  @override
  void dispose() {
    _stateController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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

  Future<void> _searchHotels() async {
    setState(() => _isLoading = true);

    try {
      final hotels = await HotelApiService.searchHotels(
        state:
            _stateController.text.trim().isEmpty
                ? null
                : _stateController.text.trim(),
        latitude:
            _latitudeController.text.trim().isEmpty
                ? null
                : double.tryParse(_latitudeController.text.trim()),
        longitude:
            _longitudeController.text.trim().isEmpty
                ? null
                : double.tryParse(_longitudeController.text.trim()),
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
    _latitudeController.clear();
    _longitudeController.clear();
    _radiusController.clear();
    setState(() => _showFilters = false);
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadAllHotels,
        ),
      ),
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
                    labelText: 'State',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
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
          Text(
            '${_filteredHotels.length} Hotels Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
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
                  : 'Be the first to add a hotel!',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  _searchQuery.isNotEmpty || _showFilters
                      ? _clearFilters
                      : () => Navigator.pushNamed(context, '/create-hotel'),
              icon: Icon(
                _searchQuery.isNotEmpty || _showFilters
                    ? Icons.clear_all
                    : Icons.add,
              ),
              label: Text(
                _searchQuery.isNotEmpty || _showFilters
                    ? 'Clear Search'
                    : 'Add Hotel',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllHotels,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredHotels.length,
        itemBuilder: (context, index) {
          final hotel = _filteredHotels[index];
          return _buildHotelCard(hotel);
        },
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToHotelDetails(hotel),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Image
            if (hotel.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(hotel.images.first),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {
                        // Handle image loading error
                      },
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hotel, size: 60, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text(
                      'No Image Available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Hotel Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name and Verification Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hotel.verification?.verifiedStatus == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Short Stay',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (hotel.enableLongStay)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Long Stay',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description (truncated)
                  Text(
                    hotel.description.length > 100
                        ? '${hotel.description.substring(0, 100)}...'
                        : hotel.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Contact Info and View Details Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hotel.email,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hotel.mobile,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToHotelDetails(hotel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
