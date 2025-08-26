import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/models/room_model.dart';
import 'package:tourism_app_new/core/services/api_service.dart';
import 'package:tourism_app_new/models/availability_model.dart';

class HotelDetailPage extends StatefulWidget {
  final Hotel hotel;
  final List<int>? availableRoomIds; // optional availability filter
  final AvailabilitySearchParams? searchParams; // optional context

  const HotelDetailPage({
    Key? key,
    required this.hotel,
    this.availableRoomIds,
    this.searchParams,
  }) : super(key: key);

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Room> _rooms = [];
  bool _isLoadingRooms = false;
  String? _roomsError;

  // If availability filter was provided, default to filtered view
  bool _showAllRooms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHotelRooms();
    // Default to showing only available if IDs were provided
    _showAllRooms = widget.availableRoomIds == null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHotelRooms() async {
    if (widget.hotel.id == null) return;

    setState(() {
      _isLoadingRooms = true;
      _roomsError = null;
    });

    try {
      final rooms = await ApiService.getHotelRooms(widget.hotel.id!);
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      setState(() {
        _roomsError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingRooms = false;
      });
    }
  }

  List<Room> get _filteredRooms {
    if (widget.availableRoomIds == null || _showAllRooms) {
      return _rooms;
    }
    final ids = widget.availableRoomIds!.toSet();
    return _rooms.where((r) => r.id != null && ids.contains(r.id)).toList();
  }

  double get _minAvailablePrice {
    final rooms = _filteredRooms;
    if (rooms.isEmpty) return 0.0;
    final prices = rooms.map((r) => r.price).toList();
    return prices.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.hotel.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade300, Colors.blue.shade700],
                  ),
                ),
                child:
                    widget.hotel.images.isNotEmpty
                        ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.hotel.images,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildPlaceholderImage(),
                            ),
                            Container(
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
                          ],
                        )
                        : _buildPlaceholderImage(),
              ),
            ),
            actions: [
              if (widget.hotel.verification?.verifiedStatus == true)
                Container(
                  margin: const EdgeInsets.only(right: 16, top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [Tab(text: 'Details'), Tab(text: 'Rooms')],
              ),
            ),
          ),

          // Tab Bar View Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [_buildDetailsTab(), _buildRoomsTab()],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _tabController.index == 1
              ? FloatingActionButton.extended(
                onPressed: () => _showAddRoomDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Room'),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              )
              : null,
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade300, Colors.blue.shade700],
        ),
      ),
      child: const Center(
        child: Icon(Icons.hotel, size: 80, color: Colors.white70),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Info Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.location_on,
                  title: 'Location',
                  subtitle: widget.hotel.state,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.phone,
                  title: 'Contact',
                  subtitle: widget.hotel.mobile,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stay Options
          _buildSectionTitle('Stay Options'),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStayChip(
                'Short Stay',
                widget.hotel.enableShortStay,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStayChip(
                'Long Stay',
                widget.hotel.enableLongStay,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Address Section
          _buildSectionTitle('Address'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow(
              'Full Address',
              '${widget.hotel.address}, ${widget.hotel.state} ${widget.hotel.postalCode}',
            ),
            _buildDetailRow(
              'Coordinates',
              '${widget.hotel.latitude}, ${widget.hotel.longitude}',
            ),
          ]),
          const SizedBox(height: 24),

          // Contact Information
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Email', widget.hotel.email),
            _buildDetailRow('Mobile', widget.hotel.mobile),
          ]),
          const SizedBox(height: 24),

          // Optional: show search context and cheapest price (if available)
          if (widget.searchParams != null) ...[
            _buildSectionTitle('Search Context'),
            const SizedBox(height: 12),
            _buildDetailCard([
              _buildDetailRow(
                'Check-in',
                '${widget.searchParams!.checkInDate.toIso8601String().split('T')[0]} '
                    '${widget.searchParams!.checkInTime}',
              ),
              _buildDetailRow(
                'Check-out',
                '${widget.searchParams!.checkOutDate.toIso8601String().split('T')[0]} '
                    '${widget.searchParams!.checkOutTime}',
              ),
            ]),
            const SizedBox(height: 12),
          ],

          // Description
          if (widget.hotel.description.isNotEmpty) ...[
            _buildSectionTitle('Description'),
            const SizedBox(height: 12),
            _buildDetailCard([
              Text(
                widget.hotel.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ]),
            const SizedBox(height: 24),
          ],

          // Rules
          if (widget.hotel.rules.isNotEmpty) ...[
            _buildSectionTitle('Hotel Rules'),
            const SizedBox(height: 12),
            _buildDetailCard([
              ...widget.hotel.rules
                  .map(
                    (rule) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rule,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ]),
            const SizedBox(height: 24),
          ],

          // Verification Details
          if (widget.hotel.verification != null) ...[
            _buildSectionTitle('Verification Details'),
            const SizedBox(height: 12),
            _buildDetailCard([
              _buildDetailRow(
                'Identity Number',
                widget.hotel.verification!.identityNumber,
              ),
              _buildDetailRow(
                'Document Type',
                widget.hotel.verification!.identityDocumentType,
              ),
              if (widget.hotel.verification!.identityVerificationDate != null)
                _buildDetailRow(
                  'Verification Date',
                  widget.hotel.verification!.identityVerificationDate!
                      .toString()
                      .split(' ')[0],
                ),
              _buildDetailRow(
                'Status',
                widget.hotel.verification!.verifiedStatus
                    ? 'Verified'
                    : 'Not Verified',
              ),
            ]),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRoomsTab() {
    if (_isLoadingRooms) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_roomsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: $_roomsError',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHotelRooms,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Provide toggle for "Show all rooms" if availability was provided
    return Column(
      children: [
        if (widget.availableRoomIds != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showAllRooms
                        ? 'Showing all rooms (${_rooms.length})'
                        : 'Showing available rooms (${_filteredRooms.length})',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllRooms = !_showAllRooms;
                    });
                  },
                  child: Text(
                    _showAllRooms ? 'Show only available' : 'Show all',
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child:
              _rooms.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bed_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No rooms available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Add rooms to get started',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddRoomDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Room'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRooms.length,
                    itemBuilder:
                        (context, index) =>
                            _buildRoomCard(_filteredRooms[index]),
                  ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                    room.type,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green[600], size: 20),
                Text(
                  '\$${room.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(width: 24),
                Icon(Icons.people, color: Colors.orange[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  'Max ${room.maxOccupancy} guests',
                  style: TextStyle(fontSize: 14, color: Colors.orange[600]),
                ),
              ],
            ),
            if (room.amenities.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    room.amenities
                        .take(3)
                        .map(
                          (amenity) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              amenity,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              if (room.amenities.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${room.amenities.length - 3} more amenities',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStayChip(String label, bool isEnabled, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isEnabled ? color.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEnabled ? color : Colors.grey),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isEnabled ? color : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddRoomDialog() {
    if (widget.hotel.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add rooms - Hotel ID not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AddRoomDialog(
            hotelId: widget.hotel.id!,
            onRoomAdded: (room) {
              setState(() {
                _rooms.add(room);
              });
            },
          ),
    );
  }
}

// Sliver delegate (unchanged)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

// AddRoomDialog (same as your original)
class AddRoomDialog extends StatefulWidget {
  final int hotelId;
  final Function(Room) onRoomAdded;

  const AddRoomDialog({
    Key? key,
    required this.hotelId,
    required this.onRoomAdded,
  }) : super(key: key);

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxOccupancyController = TextEditingController();
  final _amenitiesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _maxOccupancyController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _addRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amenities =
          _amenitiesController.text
              .split(',')
              .map((a) => a.trim())
              .where((a) => a.isNotEmpty)
              .toList();

      final room = Room(
        hotelId: widget.hotelId,
        name: _nameController.text,
        type: _typeController.text,
        price: double.parse(_priceController.text),
        maxOccupancy: int.parse(_maxOccupancyController.text),
        amenities: amenities,
      );

      final addedRoom = await ApiService.addRoomToHotel(room);
      widget.onRoomAdded(addedRoom);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Room'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'e.g., Deluxe Suite',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Room Type',
                  hintText: 'e.g., Single, Double, Suite',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price per night',
                  hintText: 'e.g., 150.00',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxOccupancyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Occupancy',
                  hintText: 'e.g., 2',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max occupancy';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amenitiesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Amenities',
                  hintText:
                      'e.g., WiFi, TV, Air Conditioning (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addRoom,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text('Add Room'),
        ),
      ],
    );
  }
}
