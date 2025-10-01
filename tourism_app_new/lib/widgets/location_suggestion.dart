// widgets/location_search_field.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class LocationSuggestion {
  final String description;
  final String placeId;
  final double? lat;
  final double? lng;

  LocationSuggestion({
    required this.description,
    required this.placeId,
    this.lat,
    this.lng,
  });
}

class LocationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(LocationSuggestion) onLocationSelected;

  const LocationSearchField({
    Key? key,
    required this.controller,
    required this.onLocationSelected,
  }) : super(key: key);

  static const String _apiKey =
      "AIzaSyC3d7coKXELrnxFCwCJ2ku2bhqnNpEo7-s"; // <-- replace with env key

  Future<List<LocationSuggestion>> _getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey&types=(cities)';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List<dynamic>;

        return predictions.map((prediction) {
          return LocationSuggestion(
            description: prediction['description'],
            placeId: prediction['place_id'],
          );
        }).toList();
      }
    }
    return [];
  }

  Future<LocationSuggestion> _getLatLng(LocationSuggestion suggestion) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${suggestion.placeId}&fields=geometry&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        return LocationSuggestion(
          description: suggestion.description,
          placeId: suggestion.placeId,
          lat: location['lat'],
          lng: location['lng'],
        );
      }
    }
    return suggestion;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return TypeAheadField<LocationSuggestion>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Where do you want to stay?",
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
        ),
      ),
      suggestionsCallback: _getSuggestions,
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(
            suggestion.description,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        );
      },
      onSuggestionSelected: (suggestion) async {
        final detailed = await _getLatLng(suggestion);
        controller.text = detailed.description;
        onLocationSelected(detailed);
      },
      noItemsFoundBuilder:
          (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No locations found'),
          ),

      // 👇 Full screen dropdown with custom styling
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        color: Colors.grey.shade100, // dropdown background color
        borderRadius: BorderRadius.circular(12), // rounded corners
        elevation: 4,
        constraints: BoxConstraints(
          minWidth: screenWidth,
          maxWidth: screenWidth,
        ),
      ),
      suggestionsBoxVerticalOffset: 0,
      hideOnLoading: false,
    );
  }
}
