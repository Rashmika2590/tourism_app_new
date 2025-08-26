import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/models/hotel_model.dart';
import 'api_helper.dart';

class HotelApiService {
  /// Create a new hotel
  static Future<Hotel> createHotel(Hotel hotel) async {
    final response = await ApiHelper.makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse('${ApiHelper.baseUrl}/hotel/');
        return await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(hotel.toJson()),
        );
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Hotel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create hotel: ${response.body}');
    }
  }

  /// Search hotels
  static Future<List<Hotel>> searchHotels({String? state}) async {
    final response = await ApiHelper.makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse(
          '${ApiHelper.baseUrl}/hotel/',
        ).replace(queryParameters: {'state': state});
        return await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search hotels: ${response.body}');
    }
  }
}
