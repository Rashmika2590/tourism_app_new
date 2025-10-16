import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';

class RoomCreationScreen extends StatefulWidget {
  final int hotelId;

  const RoomCreationScreen({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<RoomCreationScreen> createState() => _RoomCreationScreenState();
}

class _RoomCreationScreenState extends State<RoomCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _occupancyController = TextEditingController();
  final _amenitiesController = TextEditingController();
  final _numberOfRoomsController = TextEditingController(text: "1");
  final _descriptionController = TextEditingController();

  bool _loading = false;
  bool _isBatchCreation = false;
  int? _createdRoomId;
  List<File> _selectedImages = [];
  bool _uploadingImages = false;
  bool _allowFreeCancellation = false;
  bool _enableShortStay = false;
  bool _enableLongStay = false;

  // New: For room type updates
  bool _isUpdatingRoomType = false;

  Future<void> _pickImagesFromGallery() async {
    try {
      final images = await RoomApiService.pickMultipleImagesFromGallery();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      _showErrorSnackBar("Error picking images: $e");
    }
  }

  Future<void> _captureImageFromCamera() async {
    try {
      final File? imageFile = await RoomApiService.captureImageFromCamera();
      if (imageFile != null) {
        setState(() {
          _selectedImages.add(imageFile);
        });
      }
    } catch (e) {
      _showErrorSnackBar("Error capturing image: $e");
    }
  }

  // New: Upload images using the new room type endpoint
  Future<void> _uploadRoomTypeImages() async {
    if (_selectedImages.isEmpty || _typeController.text.isEmpty) {
      _showErrorSnackBar("Please select images and enter room type");
      return;
    }

    setState(() => _uploadingImages = true);

    try {
      final result = await RoomApiService.uploadRoomTypeImages(
        hotelId: widget.hotelId,
        roomType: _typeController.text.trim(),
        imageFiles: _selectedImages,
      );

      _showSuccessSnackBar(
        "${_selectedImages.length} images uploaded successfully for room type ${_typeController.text}",
      );

      print("Upload response: $result");

      // If the response contains image URLs, you can use them
      if (result['image_urls'] != null) {
        print("Uploaded image URLs: ${result['image_urls']}");
      }
    } catch (e) {
      _showErrorSnackBar("Error uploading images: $e");
      print("Detailed upload error: $e");
    } finally {
      setState(() => _uploadingImages = false);
    }
  }

  // New: Update room type attributes
  Future<void> _updateRoomType() async {
    if (!_formKey.currentState!.validate()) return;
    if (_typeController.text.isEmpty) {
      _showErrorSnackBar("Please enter room type");
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await RoomApiService.updateRoomTypeAttributes(
        hotelId: widget.hotelId,
        roomType: _typeController.text.trim(),
        typeDescription:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        price:
            _priceController.text.isEmpty
                ? null
                : double.tryParse(_priceController.text),
        maxOccupancy:
            _occupancyController.text.isEmpty
                ? null
                : int.tryParse(_occupancyController.text),
        name: _nameController.text.isEmpty ? null : _nameController.text,
        amenities:
            _amenitiesController.text.isEmpty
                ? null
                : _amenitiesController.text
                    .split(",")
                    .map((e) => e.trim())
                    .toList(),
        freeCancellation: _allowFreeCancellation,
        enableShortStay: _enableShortStay,
        enableLongStay: _enableLongStay,
      );

      _showSuccessSnackBar(
        result['message'] ?? "Room type updated successfully!",
      );
      Navigator.pop(context, result);
    } catch (e) {
      _showErrorSnackBar("Error updating room type: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_isBatchCreation) {
        final numberOfRooms = int.tryParse(_numberOfRoomsController.text) ?? 1;

        // Create multiple rooms in batch
        for (int i = 0; i < numberOfRooms; i++) {
          await RoomApiService.createRoom(
            hotelId: widget.hotelId,
            name: "${_nameController.text} ${i + 1}",
            type: _typeController.text,
            description: _descriptionController.text,
            freeCancellation: _allowFreeCancellation,
            enableShortStay: _enableShortStay,
            enableLongStay: _enableLongStay,
            price: double.tryParse(_priceController.text) ?? 0.0,
            maxOccupancy: int.tryParse(_occupancyController.text) ?? 0,
            amenities:
                _amenitiesController.text
                    .split(",")
                    .map((e) => e.trim())
                    .toList(),
          );
        }

        _showSuccessSnackBar("$numberOfRooms rooms created successfully!");
        Navigator.pop(context, {'batch_created': true, 'count': numberOfRooms});
      } else {
        final result = await RoomApiService.createRoom(
          hotelId: widget.hotelId,
          name: _nameController.text,
          type: _typeController.text,
          description: _descriptionController.text,
          freeCancellation: _allowFreeCancellation,
          enableShortStay: _enableShortStay,
          enableLongStay: _enableLongStay,
          price: double.tryParse(_priceController.text) ?? 0.0,
          maxOccupancy: int.tryParse(_occupancyController.text) ?? 0,
          amenities:
              _amenitiesController.text
                  .split(",")
                  .map((e) => e.trim())
                  .toList(),
        );

        _createdRoomId = result['id'];
        _showSuccessSnackBar("Room created successfully! ID: $_createdRoomId");
        Navigator.pop(context, result);
      }
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(Icons.image, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text('No images selected', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.file(
                _selectedImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUpdatingRoomType ? "Update Room Type" : "Create Room"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Mode Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Mode:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text("Create Room"),
                              value: false,
                              groupValue: _isUpdatingRoomType,
                              onChanged: (value) {
                                setState(() {
                                  _isUpdatingRoomType = value!;
                                  _isBatchCreation = false;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text("Update Room Type"),
                              value: true,
                              groupValue: _isUpdatingRoomType,
                              onChanged: (value) {
                                setState(() {
                                  _isUpdatingRoomType = value!;
                                  _isBatchCreation = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Batch Creation Toggle (only for create mode)
              if (!_isUpdatingRoomType)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text("Batch Creation:", style: TextStyle(fontSize: 16)),
                        Spacer(),
                        Switch(
                          value: _isBatchCreation,
                          onChanged: (value) {
                            setState(() {
                              _isBatchCreation = value;
                              if (value) {
                                _selectedImages.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              // Number of Rooms (only for batch creation)
              if (_isBatchCreation && !_isUpdatingRoomType)
                TextFormField(
                  controller: _numberOfRoomsController,
                  decoration: InputDecoration(
                    labelText: "Number of Rooms",
                    hintText: "Enter number of identical rooms to create",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (_isBatchCreation &&
                        (v!.isEmpty ||
                            int.tryParse(v) == null ||
                            int.parse(v) < 1)) {
                      return "Enter valid number of rooms";
                    }
                    return null;
                  },
                ),

              SizedBox(height: 10),

              // Room Type (required for both create and update)
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: "Room Type*",
                  hintText:
                      _isUpdatingRoomType
                          ? "e.g., Suite, Deluxe, Standard"
                          : "Enter room type",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter room type" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Room Name${_isUpdatingRoomType ? '' : '*'}",
                  hintText: "e.g., Ocean View Room, Executive Suite",
                  border: OutlineInputBorder(),
                ),
                validator:
                    _isUpdatingRoomType
                        ? null
                        : (v) => v!.isEmpty ? "Enter room name" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "Price${_isUpdatingRoomType ? '' : '*'}",
                  hintText: "e.g., 1500.00",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator:
                    _isUpdatingRoomType
                        ? null
                        : (v) => v!.isEmpty ? "Enter price" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description${_isUpdatingRoomType ? '' : '*'}",
                  hintText: "Describe the room features and amenities...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    _isUpdatingRoomType
                        ? null
                        : (v) => v!.isEmpty ? "Enter description" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _occupancyController,
                decoration: InputDecoration(
                  labelText: "Max Occupancy${_isUpdatingRoomType ? '' : '*'}",
                  hintText: "e.g., 2",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    _isUpdatingRoomType
                        ? null
                        : (v) => v!.isEmpty ? "Enter occupancy" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _amenitiesController,
                decoration: InputDecoration(
                  labelText: "Amenities (comma separated)",
                  hintText: "WiFi, TV, AC, Breakfast, Parking, etc.",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 10),

              // Cancellation Policy
              _buildFreeCancellationToggle(),
              SizedBox(height: 10),

              // Stay Type Toggles
              _buildStayTypeToggles(),
              SizedBox(height: 10),

              // Image Upload Section (not for batch creation)
              if (!_isBatchCreation) ...[
                SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Room Type Images:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _isUpdatingRoomType
                              ? "Upload images for this room type"
                              : "Upload images for the room (optional)",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        SizedBox(height: 10),

                        // Image Selection Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImagesFromGallery,
                                icon: Icon(Icons.photo_library),
                                label: Text('Gallery'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _captureImageFromCamera,
                                icon: Icon(Icons.camera_alt),
                                label: Text('Camera'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        // Upload Images Button (for room type)
                        if (_selectedImages.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed:
                                _uploadingImages ? null : _uploadRoomTypeImages,
                            icon:
                                _uploadingImages
                                    ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Icon(Icons.cloud_upload),
                            label: Text(
                              _uploadingImages
                                  ? 'Uploading...'
                                  : 'Upload Images for Room Type',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),

                        SizedBox(height: 10),

                        // Selected Images Preview
                        _buildImagePreview(),

                        SizedBox(height: 10),

                        // Selected Images Count
                        if (_selectedImages.isNotEmpty)
                          Text(
                            'Selected images: ${_selectedImages.length}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Action Buttons
              if (_isUpdatingRoomType)
                ElevatedButton(
                  onPressed: _loading ? null : _updateRoomType,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _loading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text("Update Room Type Attributes"),
                )
              else
                ElevatedButton(
                  onPressed: _loading ? null : _createRoom,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _loading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            _isBatchCreation
                                ? "Create ${_numberOfRoomsController.text} Rooms"
                                : "Create Room",
                          ),
                ),

              SizedBox(height: 10),

              // Cancel Button
              OutlinedButton(
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _occupancyController.dispose();
    _amenitiesController.dispose();
    _numberOfRoomsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildFreeCancellationToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cancellation Policy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Allow Free Cancellation:"),
                const Spacer(),
                Switch(
                  value: _allowFreeCancellation,
                  onChanged: (value) {
                    setState(() => _allowFreeCancellation = value);
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            if (_allowFreeCancellation)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'This room will have free cancellation. Price will be adjusted.',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStayTypeToggles() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stay Type Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Enable Short Stay:"),
                const Spacer(),
                Switch(
                  value: _enableShortStay,
                  onChanged: (value) {
                    setState(() => _enableShortStay = value);
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text("Enable Long Stay:"),
                const Spacer(),
                Switch(
                  value: _enableLongStay,
                  onChanged: (value) {
                    setState(() => _enableLongStay = value);
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
            if (_enableShortStay || _enableLongStay)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _enableShortStay && _enableLongStay
                      ? 'Room available for both short and long stays'
                      : _enableShortStay
                      ? 'Room available for short stays only'
                      : 'Room available for long stays only',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
