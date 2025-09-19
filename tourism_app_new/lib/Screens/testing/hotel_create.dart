import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourism_app_new/Screens/testing/hotel_verfication_screen.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HotelCreationScreen extends StatefulWidget {
  const HotelCreationScreen({Key? key}) : super(key: key);

  @override
  State<HotelCreationScreen> createState() => _HotelCreationScreenState();
}

class _HotelCreationScreenState extends State<HotelCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _enableShortStay = false;
  bool _enableLongStay = false;
  List<String> _rules = [];
  List<XFile> _imageFiles = [];
  String _newRule = '';

  bool _isLoading = false;
  bool _showImageSection = false;
  int? _createdHotelId;
  String _uploadStatus = '';

  // Map variables
  LatLng _currentPosition = const LatLng(
    6.9271,
    79.8612,
  ); // Default position (Colombo)
  bool _showMap = false;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Initialize with default coordinates
    _latitudeController.text = _currentPosition.latitude.toString();
    _longitudeController.text = _currentPosition.longitude.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _updateMarker();
  }

  void _updateMarker() {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('hotel_location'),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: 'Hotel Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _currentPosition = position;
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
    });
    _updateMarker();
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
      _latitudeController.text = position.target.latitude.toStringAsFixed(6);
      _longitudeController.text = position.target.longitude.toStringAsFixed(6);
    });
  }

  void _openMapPicker() {
    setState(() {
      _showMap = true;
    });
  }

  void _closeMapPicker() {
    setState(() {
      _showMap = false;
    });
  }

  void _confirmLocation() {
    setState(() {
      _latitudeController.text = _currentPosition.latitude.toStringAsFixed(6);
      _longitudeController.text = _currentPosition.longitude.toStringAsFixed(6);
      _showMap = false;
    });
  }

  Future<void> _createHotel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _uploadStatus = '';
    });

    try {
      final response = await HotelApiService.createHotel(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        rules: _rules,
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        enableShortStay: _enableShortStay,
        enableLongStay: _enableLongStay,
        description: _descriptionController.text.trim(),
      );

      print("Hotel creation response: $response");
      _createdHotelId = response['hotel_id'];
      print("Created hotel ID: $_createdHotelId");

      setState(() {
        _showImageSection = true;
        _isLoading = false;
      });

      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hotel created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create hotel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_imageFiles.isEmpty) {
      print("No images selected");
      return;
    }
    if (_createdHotelId == null) {
      print("No hotel ID, cannot upload images");
      return;
    }

    setState(() => _isLoading = true);
    print("Uploading images for hotel $_createdHotelId ...");

    try {
      final res = await HotelApiService.uploadHotelImages(
        id: _createdHotelId!,
        images: _imageFiles,
      );
      print("Upload success: $res");
      setState(() => _isLoading = false);
    } catch (e) {
      print("Upload failed: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await HotelApiService.pickImageFromGallery();
    if (image != null) setState(() => _imageFiles.add(image));
  }

  Future<void> _takePhotoWithCamera() async {
    final XFile? image = await HotelApiService.takePhotoWithCamera();
    if (image != null) setState(() => _imageFiles.add(image));
  }

  void _addRule() {
    if (_newRule.trim().isNotEmpty) {
      setState(() {
        _rules.add(_newRule.trim());
        _newRule = '';
      });
    }
  }

  void _removeRule(int index) => setState(() => _rules.removeAt(index));
  void _removeImage(int index) => setState(() => _imageFiles.removeAt(index));

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Hotel')),
      body: _showMap ? _buildMapPicker() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHotelDetailsSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildContactSection(),
            const SizedBox(height: 24),
            _buildStayOptionsSection(),
            const SizedBox(height: 24),
            _buildRulesSection(),
            const SizedBox(height: 24),
            _buildDescriptionSection(),
            const SizedBox(height: 24),
            _buildCreateButton(),
            if (_showImageSection) ...[
              const SizedBox(height: 32),
              _buildImageUploadSection(),
              const SizedBox(height: 100),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPicker() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 15,
                ),
                markers: _markers,
                onTap: _onMapTap,
                onCameraMove: _onCameraMove,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              Positioned(
                top: 16,
                left: 16,
                child: FloatingActionButton(
                  onPressed: _closeMapPicker,
                  child: const Icon(Icons.arrow_back),
                  mini: true,
                ),
              ),
              const Center(
                child: Icon(Icons.location_pin, color: Colors.red, size: 48),
              ),
            ],
          ),
        ),

        // 🔹 Card is placed BELOW the map, not overlapping
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Hotel Location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Latitude: ${_currentPosition.latitude.toStringAsFixed(6)}',
                    ),
                    Text(
                      'Longitude: ${_currentPosition.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        child: const Text('Confirm Location'),
                      ),
                    ),
                    //SizedBox(height: 100),
                  ],
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotelDetailsSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hotel Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Hotel Name'),
            validator: (value) => value!.isEmpty ? 'Enter hotel name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            validator: (value) => value!.isEmpty ? 'Enter address' : null,
          ),
        ],
      ),
    ),
  );

  Widget _buildLocationSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _stateController,
            decoration: const InputDecoration(labelText: 'State'),
            validator: (value) => value!.isEmpty ? 'Enter state' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _postalCodeController,
            decoration: const InputDecoration(labelText: 'Postal Code'),
            validator: (value) => value!.isEmpty ? 'Enter postal code' : null,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter latitude';
                    final lat = double.tryParse(value);
                    if (lat == null || lat < -90 || lat > 90)
                      return 'Invalid latitude';
                    return null;
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Enter longitude';
                    final lng = double.tryParse(value);
                    if (lng == null || lng < -180 || lng > 180)
                      return 'Invalid longitude';
                    return null;
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openMapPicker,
            icon: const Icon(Icons.map),
            label: const Text('Select Location on Map'),
          ),
        ],
      ),
    ),
  );

  Widget _buildContactSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter email';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                return 'Enter valid email';
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobileController,
            decoration: const InputDecoration(labelText: 'Mobile Number'),
            validator: (value) => value!.isEmpty ? 'Enter mobile number' : null,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    ),
  );

  Widget _buildStayOptionsSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Stay Options',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          CheckboxListTile(
            title: const Text('Enable Short Stay'),
            value: _enableShortStay,
            onChanged: (v) => setState(() => _enableShortStay = v ?? false),
          ),
          CheckboxListTile(
            title: const Text('Enable Long Stay'),
            value: _enableLongStay,
            onChanged: (v) => setState(() => _enableLongStay = v ?? false),
          ),
        ],
      ),
    ),
  );

  Widget _buildRulesSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Hotel Rules',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Add a rule'),
                  onChanged: (v) => setState(() => _newRule = v),
                  onFieldSubmitted: (_) => _addRule(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addRule, child: const Text('Add')),
            ],
          ),
          ..._rules.asMap().entries.map((e) {
            return ListTile(
              title: Text(e.value),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeRule(e.key),
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );

  Widget _buildDescriptionSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(labelText: 'Description'),
        maxLines: 5,
        validator: (value) => value!.isEmpty ? 'Enter description' : null,
      ),
    ),
  );

  Widget _buildCreateButton() => ElevatedButton(
    onPressed: _isLoading ? null : _createHotel,
    child:
        _isLoading
            ? const CircularProgressIndicator()
            : const Text('Create Hotel'),
  );

  Widget _buildImageUploadSection() => Card(
    color: Colors.green[50],
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Upload Images',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _takePhotoWithCamera,
                  icon: const Icon(Icons.camera),
                  label: const Text('Camera'),
                ),
              ),
            ],
          ),
          if (_imageFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.file(
                      File(_imageFiles[index].path),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadImages,
              child: const Text('Upload Images'),
            ),
          ],
          if (_createdHotelId != null && _imageFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HotelVerificationScreen(
                            hotelId: _createdHotelId!,
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.verified),
                label: const Text('Proceed to Verification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ),
          if (_uploadStatus.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _uploadStatus,
              style: TextStyle(
                color:
                    _uploadStatus.contains('Failed')
                        ? Colors.red
                        : Colors.green,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
