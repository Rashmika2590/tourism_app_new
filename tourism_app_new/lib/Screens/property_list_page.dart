import 'package:flutter/material.dart';
import 'package:tourism_app_new/core/services/api_service.dart';
import 'package:tourism_app_new/models/property_model.dart';

class PropertyListPage extends StatefulWidget {
  final String city;

  const PropertyListPage({super.key, required this.city});

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  late Future<List<Property>> _filteredProperties;

  @override
  void initState() {
    super.initState();
    _filteredProperties = fetchFilteredPropertiesByCity(widget.city);
  }

  Future<List<Property>> fetchFilteredPropertiesByCity(String city) async {
    try {
      // Optional normalization
      final normalizedCity = city.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );

      // Call the API
      final allProperties = await ApiService.filterProperties({}, city: city);

      // Debug print
      for (var p in allProperties) {
        print("🔍 Property: ${p.propertyName} | City: ${p.address.city}");
      }

      // Smart filtering (contains & case-insensitive)
      return allProperties
          .where((p) => (p.address.city).toLowerCase().contains(normalizedCity))
          .toList();
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Properties in ${widget.city}')),
      body: FutureBuilder<List<Property>>(
        future: _filteredProperties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final properties = snapshot.data!;
          print("🧱 UI Rendering ${properties.length} tiles");

          if (properties.isEmpty) {
            return const Center(child: Text('No properties found'));
          }

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return ListTile(
                title: Text(property.propertyName),
                subtitle: Text('ID: ${property.id}'),
                leading: const Icon(Icons.home),
              );
            },
          );
        },
      ),
    );
  }
}
