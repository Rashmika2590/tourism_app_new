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

  bool _loading = false;
  bool _isBatchCreation = false;
  int? _createdRoomId;
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _uploadingImages = false;

  Future<void> _pickImagesFromGallery() async {
    try {
      final File? imageFile = await RoomApiService.pickImageFromGallery();
      if (imageFile != null) {
        setState(() {
          _selectedImages.add(imageFile);
        });
      }
    } catch (e) {
      _showErrorSnackBar("Error picking image: $e");
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

  Future<void> _uploadImagesToS3() async {
    if (_selectedImages.isEmpty) return;

    setState(() => _uploadingImages = true);

    try {
      for (var imageFile in _selectedImages) {
        final imageUrl = await RoomApiService.uploadImageToS3(imageFile);
        _uploadedImageUrls.add(imageUrl);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${_selectedImages.length} images uploaded successfully!",
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar("Error uploading images: $e");
    } finally {
      setState(() => _uploadingImages = false);
    }
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_isBatchCreation) {
        // Batch room creation (no images)
        final result = await RoomApiService.createRoomsBatch(
          hotelId: widget.hotelId,
          numberOfRooms: int.tryParse(_numberOfRoomsController.text) ?? 1,
          name: _nameController.text,
          type: _typeController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          maxOccupancy: int.tryParse(_occupancyController.text) ?? 0,
          amenities:
              _amenitiesController.text
                  .split(",")
                  .map((e) => e.trim())
                  .toList(),
        );

        _showSuccessSnackBar(
          "${_numberOfRoomsController.text} rooms created successfully!",
        );
        Navigator.pop(context, result);
      } else {
        // Single room creation
        final result = await RoomApiService.createRoom(
          hotelId: widget.hotelId,
          name: _nameController.text,
          type: _typeController.text,
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

        // Upload images if any are selected
        if (_selectedImages.isNotEmpty) {
          await _uploadImagesAndAddToRoom();
        } else {
          Navigator.pop(context, result);
        }
      }
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    } finally {
      if (mounted && !(_selectedImages.isNotEmpty && _createdRoomId != null)) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _uploadImagesAndAddToRoom() async {
    if (_createdRoomId == null) return;

    setState(() => _uploadingImages = true);

    try {
      // Upload images to S3
      for (var imageFile in _selectedImages) {
        final imageUrl = await RoomApiService.uploadImageToS3(imageFile);
        _uploadedImageUrls.add(imageUrl);
      }

      // Add image URLs to room
      if (_uploadedImageUrls.isNotEmpty) {
        await RoomApiService.addRoomImages(
          roomId: _createdRoomId!,
          imageUrls: _uploadedImageUrls,
        );
      }

      _showSuccessSnackBar("Room images uploaded successfully!");
    } catch (e) {
      _showErrorSnackBar("Error uploading images: $e");
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImages = false;
          _loading = false;
        });
        Navigator.pop(context, {
          'roomId': _createdRoomId,
          'imagesUploaded': true,
          'imageUrls': _uploadedImageUrls,
        });
      }
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
      appBar: AppBar(title: Text("Create Room")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Batch Creation Toggle
              Row(
                children: [
                  Text("Batch Creation:", style: TextStyle(fontSize: 16)),
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
              SizedBox(height: 10),

              // Number of Rooms (only for batch creation)
              if (_isBatchCreation)
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

              if (_isBatchCreation) SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Room Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: "Room Type",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter type" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? "Enter price" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _occupancyController,
                decoration: InputDecoration(
                  labelText: "Max Occupancy",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Enter occupancy" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _amenitiesController,
                decoration: InputDecoration(
                  labelText: "Amenities (comma separated)",
                  hintText: "WiFi, TV, AC, etc.",
                  border: OutlineInputBorder(),
                ),
              ),

              // Image Upload Section (only for single room creation)
              if (!_isBatchCreation) ...[
                SizedBox(height: 20),
                Text(
                  "Room Images:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

                // Manual Upload Button
                if (_selectedImages.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _uploadingImages ? null : _uploadImagesToS3,
                    icon:
                        _uploadingImages
                            ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Icon(Icons.cloud_upload),
                    label: Text(
                      _uploadingImages ? 'Uploading...' : 'Upload Images to S3',
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

              const SizedBox(height: 20),

              // Create Room Button
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
                              ? "Create Rooms in Batch"
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
    super.dispose();
  }
}
