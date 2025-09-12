import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourism_app_new/Services/Api%20Services/hotel_api_service.dart';

class HotelVerificationScreen extends StatefulWidget {
  final int hotelId;

  const HotelVerificationScreen({Key? key, required this.hotelId})
    : super(key: key);

  @override
  State<HotelVerificationScreen> createState() =>
      _HotelVerificationScreenState();
}

class _HotelVerificationScreenState extends State<HotelVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final _identityNumberController = TextEditingController();
  final _verificationDocumentController = TextEditingController();
  final _selfieController = TextEditingController();

  // Form data
  String _selectedDocumentType = 'National ID';
  DateTime _selectedDate = DateTime.now();
  XFile? _documentFile;
  XFile? _selfieFile;

  // UI state
  bool _isSubmitting = false;

  // Document types
  final List<String> _documentTypes = [
    'National ID',
    'Passport',
    'Driver\'s License',
    'Business Registration',
    'Other Government ID',
  ];

  @override
  void dispose() {
    _identityNumberController.dispose();
    _verificationDocumentController.dispose();
    _selfieController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickDocumentImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) setState(() => _documentFile = image);
    } catch (e) {
      _showErrorSnackBar('Failed to pick document image: $e');
    }
  }

  Future<void> _pickSelfieImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) setState(() => _selfieFile = image);
    } catch (e) {
      _showErrorSnackBar('Failed to pick selfie image: $e');
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_documentFile == null || _selfieFile == null) {
      _showErrorSnackBar('Please capture both document and selfie images');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Step 1: Create verification entry
      await HotelApiService.submitHotelVerification(
        hotelId: widget.hotelId,
        identityNumber: _identityNumberController.text.trim(),
        verificationDocumentType: _selectedDocumentType,
        verificationDocument:
            _verificationDocumentController.text.trim().isNotEmpty
                ? _verificationDocumentController.text.trim()
                : "init", // placeholder
        verificationDate: _selectedDate,
        verifiedStatus: false,
        selfie:
            _selfieController.text.trim().isNotEmpty
                ? _selfieController.text.trim()
                : "init", // placeholder
      );

      // Step 2: Upload files
      await HotelApiService.uploadVerificationFiles(
        hotelId: widget.hotelId,
        docFile: File(_documentFile!.path),
        selfieFile: File(_selfieFile!.path),
      );

      _showSuccessDialog();
    } catch (e) {
      _showErrorSnackBar('Verification failed: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            icon: Icon(Icons.check_circle, color: Colors.green[600], size: 60),
            title: const Text('Verification Submitted'),
            content: const Text(
              'Your hotel verification has been submitted successfully. '
              'Our team will review your documents and update the status within 2-3 business days.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Verification'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInstructionsCard(),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildDocumentSection(),
              const SizedBox(height: 24),
              _buildImageUploadSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() => Card(
    color: Colors.blue[50],
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '• Provide accurate information\n'
            '• Upload clear document & selfie images\n'
            '• Ensure all text is readable\n'
            '• Processing takes 2-3 business days',
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    ),
  );

  Widget _buildPersonalInfoSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: _identityNumberController,
        decoration: const InputDecoration(
          labelText: 'Identity Number *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.badge),
        ),
        validator:
            (value) =>
                value?.isEmpty ?? true ? 'Identity number required' : null,
      ),
    ),
  );

  Widget _buildDocumentSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedDocumentType,
            decoration: const InputDecoration(
              labelText: 'Document Type *',
              border: OutlineInputBorder(),
            ),
            items:
                _documentTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged:
                (value) => setState(
                  () => _selectedDocumentType = value ?? 'National ID',
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _verificationDocumentController,
            decoration: const InputDecoration(
              labelText: 'Document Reference (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Verification Date *',
                border: OutlineInputBorder(),
              ),
              child: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _selfieController,
            decoration: const InputDecoration(
              labelText: 'Selfie Reference (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildImageUploadSection() => Column(
    children: [
      _buildImagePicker(
        file: _documentFile,
        onPick: _pickDocumentImage,
        label: 'Capture Document Image',
        icon: Icons.document_scanner,
      ),
      const SizedBox(height: 16),
      _buildImagePicker(
        file: _selfieFile,
        onPick: _pickSelfieImage,
        label: 'Capture Selfie',
        icon: Icons.face,
      ),
    ],
  );

  Widget _buildImagePicker({
    required XFile? file,
    required VoidCallback onPick,
    required String label,
    required IconData icon,
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child:
          file != null
              ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(file.path),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed:
                            () => setState(() {
                              if (icon == Icons.document_scanner) {
                                _documentFile = null;
                              } else {
                                _selfieFile = null;
                              }
                            }),
                      ),
                    ),
                  ),
                ],
              )
              : InkWell(
                onTap: onPick,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to take photo',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSubmitButton() => ElevatedButton.icon(
    onPressed: _isSubmitting ? null : _submitVerification,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange[600],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
    icon:
        _isSubmitting
            ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
            : const Icon(Icons.verified_user),
    label: Text(
      _isSubmitting ? 'Submitting Verification...' : 'Submit for Verification',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}
