// // lib/core/services/api/availability_api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:tourism_app_new/core/services/Api%20Services/api_helper.dart';
// import 'package:tourism_app_new/core/services/Api%20Services/hotelApi_service.dart';
// import 'package:tourism_app_new/models/availability_model.dart';
// import 'package:tourism_app_new/models/hotel_model.dart';

// /// Service for handling Availability API calls.
// class AvailabilityApiService extends ApiHelper {
//   static const String _availabilityEndpoint = '/availability/';

//   /// Search availability with given search params
//   static Future<AvailabilityResponse> searchAvailability(
//     AvailabilitySearchParams searchParams,
//   ) async {
//     final response = await ApiHelper.makeAuthenticatedRequest<http.Response>(
//       requestFunction: (token) async {
//         final queryParams = searchParams.toQueryParams();
//         final uri = Uri.parse(
//           '${ApiHelper.baseUrl}$_availabilityEndpoint',
//         ).replace(queryParameters: queryParams);

//         print('Searching availability with URL: $uri');

//         return await http.get(
//           uri,
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );
//       },
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> jsonData = jsonDecode(response.body);
//       return AvailabilityResponse.fromJson(jsonData);
//     } else if (response.statusCode == 404) {
//       return AvailabilityResponse(available: {});
//     } else {
//       print(
//         'Search Availability Error - Status: ${response.statusCode}, Body: ${response.body}',
//       );
//       throw Exception('Failed to search availability: ${response.body}');
//     }
//   }

//   /// Search availability and get detailed hotel information
//   static Future<List<HotelWithAvailability>> searchAvailabilityWithHotelDetails(
//     AvailabilitySearchParams searchParams,
//   ) async {
//     try {
//       final availabilityResponse = await searchAvailability(searchParams);

//       if (availabilityResponse.availableHotelIds.isEmpty) {
//         return [];
//       }

//       final List<Hotel> hotels = await HotelApiService.getHotelsByIds(
//         availabilityResponse.availableHotelIds,
//       );

//       final List<HotelWithAvailability> hotelsWithAvailability = [];

//       for (final hotelId in availabilityResponse.availableHotelIds) {
//         final hotel = hotels.firstWhere(
//           (h) => h.id == hotelId,
//           orElse: () {
//             print('Hotel with ID $hotelId not found in hotel list - skipping');
//             return Hotel(
//               id: hotelId,
//               name: 'Unknown Hotel',
//               address: '',
//               state: '',
//               postalCode: '',
//               latitude: 0.0,
//               longitude: 0.0,
//               rules: [],
//               email: '',
//               mobile: '',
//               images: '',
//               enableShortStay: false,
//               enableLongStay: false,
//               description: '',
//             );
//           },
//         );

//         final availableRoomIds = availabilityResponse.getAvailableRoomIds(
//           hotelId,
//         );

//         hotelsWithAvailability.add(
//           HotelWithAvailability(
//             hotel: hotel,
//             availableRoomIds: availableRoomIds,
//           ),
//         );
//       }

//       return hotelsWithAvailability;
//     } catch (e) {
//       print('Error in searchAvailabilityWithHotelDetails: $e');
//       throw Exception('Failed to search availability with hotel details: $e');
//     }
//   }

//   /// Search availability with full hotel and room details
//   static Future<List<HotelWithAvailability>> searchAvailabilityWithFullDetails(
//     AvailabilitySearchParams searchParams,
//   ) async {
//     try {
//       final hotelsWithAvailability = await searchAvailabilityWithHotelDetails(
//         searchParams,
//       );

//       if (hotelsWithAvailability.isEmpty) return [];

//       final List<HotelWithAvailability> completeResults = [];

//       for (final hotelAvailability in hotelsWithAvailability) {
//         try {
//           final allRooms = await HotelApiService.getHotelRooms(
//             hotelAvailability.hotel.id!,
//           );

//           final availableRooms =
//               allRooms
//                   .where(
//                     (room) =>
//                         hotelAvailability.availableRoomIds.contains(room.id),
//                   )
//                   .toList();

//           completeResults.add(
//             hotelAvailability.copyWith(availableRooms: availableRooms),
//           );
//         } catch (e) {
//           print(
//             'Error fetching rooms for hotel ${hotelAvailability.hotel.id}: $e',
//           );
//           completeResults.add(hotelAvailability);
//         }
//       }

//       return completeResults;
//     } catch (e) {
//       print('Error in searchAvailabilityWithFullDetails: $e');
//       throw Exception('Failed to search availability with full details: $e');
//     }
//   }

//   /// Quick availability search with minimal parameters
//   static Future<AvailabilityResponse> quickAvailabilitySearch({
//     required DateTime checkInDate,
//     required DateTime checkOutDate,
//     String checkInTime = "14:00",
//     String checkOutTime = "11:00",
//     int adultCount = 1,
//     int childrenCount = 0,
//     String? state,
//   }) async {
//     final searchParams = AvailabilitySearchParams(
//       checkInDate: checkInDate,
//       checkInTime: checkInTime,
//       checkOutDate: checkOutDate,
//       checkOutTime: checkOutTime,
//       adultCount: adultCount,
//       childrenCount: childrenCount,
//       state: state,
//     );

//     return await searchAvailability(searchParams);
//   }

//   /// Search availability near a specific location
//   static Future<AvailabilityResponse> searchAvailabilityNearLocation({
//     required DateTime checkInDate,
//     required DateTime checkOutDate,
//     required double latitude,
//     required double longitude,
//     double maxDistanceKm = 10.0,
//     String checkInTime = "14:00",
//     String checkOutTime = "11:00",
//     int adultCount = 1,
//     int childrenCount = 0,
//   }) async {
//     final searchParams = AvailabilitySearchParams(
//       checkInDate: checkInDate,
//       checkInTime: checkInTime,
//       checkOutDate: checkOutDate,
//       checkOutTime: checkOutTime,
//       latitude: latitude,
//       longitude: longitude,
//       maxDistanceKm: maxDistanceKm,
//       adultCount: adultCount,
//       childrenCount: childrenCount,
//     );

//     return await searchAvailability(searchParams);
//   }

//   /// Check availability for a specific hotel
//   static Future<List<int>> checkHotelAvailability({
//     required int hotelId,
//     required AvailabilitySearchParams searchParams,
//   }) async {
//     final availabilityResponse = await searchAvailability(searchParams);
//     return availabilityResponse.getAvailableRoomIds(hotelId);
//   }

//   /// Check if a specific room is available
//   static Future<bool> isRoomAvailable({
//     required int roomId,
//     required int hotelId,
//     required AvailabilitySearchParams searchParams,
//   }) async {
//     final availableRoomIds = await checkHotelAvailability(
//       hotelId: hotelId,
//       searchParams: searchParams,
//     );
//     return availableRoomIds.contains(roomId);
//   }
// }
