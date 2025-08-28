import 'package:flutter/material.dart';
import 'package:tourism_app_new/Models/hotel_model.dart';

class HotelDetailsScreen extends StatelessWidget {
  const HotelDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Hotel hotel = ModalRoute.of(context)!.settings.arguments as Hotel;

    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Images
            if (hotel.images.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: hotel.images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      hotel.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.hotel, size: 80, color: Colors.grey),
              ),

            // Hotel Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.address}, ${hotel.state}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hotel.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Contact Information
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(hotel.email),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(hotel.mobile),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stay Options
                  const Text(
                    'Stay Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (hotel.enableShortStay)
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        const Text('Short Stay Available'),
                      ],
                    ),
                  if (hotel.enableLongStay)
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        const Text('Long Stay Available'),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Hotel Rules
                  if (hotel.rules.isNotEmpty) ...[
                    const Text(
                      'Hotel Rules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          hotel.rules.map((rule) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(child: Text(rule)),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
