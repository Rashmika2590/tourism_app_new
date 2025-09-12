import 'package:flutter/material.dart';
import 'package:tourism_app_new/Services/Api%20Services/room_api_service.dart';

class RoomCreationScreen extends StatefulWidget {
  final int hotelId; // pass from HotelDetails page

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

  bool _loading = false;

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final roomId = await RoomApiService.createRoom(
        hotelId: widget.hotelId,
        name: _nameController.text,
        type: _typeController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        maxOccupancy: int.tryParse(_occupancyController.text) ?? 0,
        amenities: _amenitiesController.text.split(","),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room created successfully! ID: $roomId")),
      );

      Navigator.pop(context, roomId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Room Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: "Room Type"),
                validator: (v) => v!.isEmpty ? "Enter type" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Enter price" : null,
              ),
              TextFormField(
                controller: _occupancyController,
                decoration: InputDecoration(labelText: "Max Occupancy"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Enter occupancy" : null,
              ),
              TextFormField(
                controller: _amenitiesController,
                decoration: InputDecoration(
                  labelText: "Amenities (comma separated)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _createRoom,
                child:
                    _loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Create Room"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
