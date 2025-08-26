import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/hotel_model.dart';
import 'package:tourism_app_new/core/services/api_service.dart';

class CreateHotelPage extends StatefulWidget {
  const CreateHotelPage({Key? key}) : super(key: key);

  @override
  State<CreateHotelPage> createState() => _CreateHotelPageState();
}

class _CreateHotelPageState extends State<CreateHotelPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  // Hotel basic info controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _imagesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();

  // Hotel verification controllers
  final _identityNumberController = TextEditingController();
  final _identityDocumentTypeController = TextEditingController();
  final _selfieController = TextEditingController();

  // Checkboxes
  bool _enableShortStay = false;
  bool _enableLongStay = false;
  bool _verifiedStatus = false;

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
    _imagesController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _identityNumberController.dispose();
    _identityDocumentTypeController.dispose();
    _selfieController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _createHotel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse rules from comma-separated string
      List<String> rules =
          _rulesController.text
              .split(',')
              .map((rule) => rule.trim())
              .where((rule) => rule.isNotEmpty)
              .toList();

      final verification = HotelVerification(
        identityNumber: _identityNumberController.text,
        identityDocumentType: _identityDocumentTypeController.text,
        identityVerificationDate: DateTime.now(),
        verifiedStatus: _verifiedStatus,
        selfie: _selfieController.text,
      );

      final hotel = Hotel(
        name: _nameController.text,
        address: _addressController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        rules: rules,
        email: _emailController.text,
        mobile: _mobileController.text,
        images: _imagesController.text,
        enableShortStay: _enableShortStay,
        enableLongStay: _enableLongStay,
        description: _descriptionController.text,
        verification: verification,
      );

      final createdHotel = await ApiService.createHotel(hotel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hotel created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, createdHotel);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating hotel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Hotel'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Hotel Information'),
                const SizedBox(height: 16),
                _buildTextFormField(
                  _nameController,
                  'Hotel Name',
                  'Enter hotel name',
                ),
                _buildTextFormField(
                  _addressController,
                  'Address',
                  'Enter hotel address',
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        _stateController,
                        'State',
                        'Enter state',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        _postalCodeController,
                        'Postal Code',
                        'Enter postal code',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        _latitudeController,
                        'Latitude',
                        'Enter latitude',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        _longitudeController,
                        'Longitude',
                        'Enter longitude',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                _buildTextFormField(
                  _emailController,
                  'Email',
                  'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextFormField(
                  _mobileController,
                  'Mobile',
                  'Enter mobile number',
                  keyboardType: TextInputType.phone,
                ),
                _buildTextFormField(
                  _imagesController,
                  'Images URL',
                  'Enter image URL',
                ),
                _buildTextFormField(
                  _rulesController,
                  'Rules',
                  'Enter rules (comma separated)',
                  maxLines: 3,
                ),
                _buildTextFormField(
                  _descriptionController,
                  'Description',
                  'Enter hotel description',
                  maxLines: 4,
                ),

                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Enable Short Stay'),
                  value: _enableShortStay,
                  onChanged: (value) {
                    setState(() {
                      _enableShortStay = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Enable Long Stay'),
                  value: _enableLongStay,
                  onChanged: (value) {
                    setState(() {
                      _enableLongStay = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Verification Information'),
                const SizedBox(height: 16),
                _buildTextFormField(
                  _identityNumberController,
                  'Identity Number',
                  'Enter identity number',
                ),
                _buildTextFormField(
                  _identityDocumentTypeController,
                  'Document Type',
                  'e.g., Passport, NIC',
                ),
                _buildTextFormField(
                  _selfieController,
                  'Selfie URL',
                  'Enter selfie image URL',
                ),

                CheckboxListTile(
                  title: const Text('Verified Status'),
                  value: _verifiedStatus,
                  onChanged: (value) {
                    setState(() {
                      _verifiedStatus = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createHotel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Create Hotel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
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

  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (keyboardType == TextInputType.number) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
          }
          if (keyboardType == TextInputType.emailAddress) {
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
          }
          return null;
        },
      ),
    );
  }
}
