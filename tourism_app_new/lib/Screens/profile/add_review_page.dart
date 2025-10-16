import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tourism_app_new/Services/Api%20Services/review_api_service.dart';
import 'package:tourism_app_new/models/review_formdata.dart';

class CreateReviewPage extends StatefulWidget {
  final int hotelId;
  final String hotelName;

  const CreateReviewPage({
    super.key,
    required this.hotelId,
    required this.hotelName,
  });

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final ReviewFormData _formData = ReviewFormData(hotelId: 0);
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formData.hotelId = widget.hotelId;
    _commentController.addListener(_updateComment);
  }

  void _updateComment() {
    setState(() {
      _formData.comment = _commentController.text;
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (selectedImages.isNotEmpty) {
        setState(() {
          _formData.selectedImagePaths.addAll(
            selectedImages.map((xFile) => xFile.path),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _formData.selectedImagePaths.add(photo.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _formData.selectedImagePaths.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (!_formData.isValid) {
      _showErrorSnackBar('Please provide a rating and comment');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert image files to multipart files
      List<http.MultipartFile> multipartFiles = [];

      for (String imagePath in _formData.selectedImagePaths) {
        File imageFile = File(imagePath);
        List<int> imageBytes = await imageFile.readAsBytes();

        String fileName = imagePath.split('/').last;
        String fileExtension = fileName.split('.').last.toLowerCase();

        String contentType = 'image/jpeg'; // default
        if (fileExtension == 'png') {
          contentType = 'image/png';
        } else if (fileExtension == 'gif') {
          contentType = 'image/gif';
        }

        multipartFiles.add(
          ReviewService.createMultipartFile(
            'images',
            imageBytes,
            filename: fileName,
            contentType: contentType,
          ),
        );
      }

      // Submit review
      final review = await ReviewService.addReview(
        hotelId: _formData.hotelId,
        rating: _formData.rating,
        comment: _formData.comment,
        imageFiles: multipartFiles,
      );

      _showSuccessSnackBar('Review submitted successfully!');

      // Navigate back with success result
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to submit review: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              _isSubmitting ? null : () => Navigator.of(context).pop(false),
        ),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Info
            _buildHotelInfo(),
            const SizedBox(height: 24),

            // Rating Section
            _buildRatingSection(),
            const SizedBox(height: 24),

            // Comment Section
            _buildCommentSection(),
            const SizedBox(height: 24),

            // Image Section
            _buildImageSection(),
            const SizedBox(height: 32),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.hotel, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotelName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hotel ID: ${widget.hotelId}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Rating *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _formData.rating ? Icons.star : Icons.star_border,
                size: 40,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _formData.rating = index + 1;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _formData.rating == 0
              ? 'Tap to rate'
              : '${_formData.rating} Star${_formData.rating > 1 ? 's' : ''}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Review *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Share your experience...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_commentController.text.length} characters',
          style: TextStyle(
            fontSize: 12,
            color: _commentController.text.isEmpty ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Photos (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Image Selection Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                onPressed: _pickImages,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: _takePhoto,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),

        // Selected Images Grid
        if (_formData.selectedImagePaths.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Selected Images (${_formData.selectedImagePaths.length})',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _formData.selectedImagePaths.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_formData.selectedImagePaths[index]),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting || !_formData.isValid ? null : _submitReview,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          disabledBackgroundColor: Colors.grey[400],
        ),
        child:
            _isSubmitting
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Submit Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }
}
