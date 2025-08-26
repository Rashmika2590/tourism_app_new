import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app_new/models/room_model.dart';
import 'api_helper.dart';

class RoomApiService {
  /// Create a room
  static Future<Room> createRoom(Room room) async {
    final response = await ApiHelper.makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse('${ApiHelper.baseUrl}/room/');
        return await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(room.toJson()),
        );
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create room: ${response.body}');
    }
  }

  /// Fetch rooms by hotelId
  static Future<List<Room>> getRoomsByHotelId(String hotelId) async {
    final response = await ApiHelper.makeAuthenticatedRequest<http.Response>(
      requestFunction: (token) async {
        final uri = Uri.parse(
          '${ApiHelper.baseUrl}/room/',
        ).replace(queryParameters: {'hotelId': hotelId});
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
      return jsonData.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch rooms: ${response.body}');
    }
  }
}
