// import 'package:flutter/material.dart';
// import 'package:tourism_app_new/Services/Api%20Services/favourites_api_service.dart';

// class FavouriteProvider extends ChangeNotifier {
//   // Map of hotelId -> favouriteId (backend ID)
//   final Map<int, int> _favouriteIds = {};

//   // Set of hotel IDs that are favourited
//   final Set<int> _favouritedHotels = {};

//   // Loading states for individual hotels
//   final Map<int, bool> _loadingStates = {};

//   bool isFavourite(int hotelId) => _favouritedHotels.contains(hotelId);

//   bool isLoading(int hotelId) => _loadingStates[hotelId] ?? false;

//   int? getFavouriteId(int hotelId) => _favouriteIds[hotelId];

//   // Initialize favourite status from hotel data
//   void setFavouriteStatus(int hotelId, bool isFavourite, {int? favouriteId}) {
//     if (isFavourite) {
//       _favouritedHotels.add(hotelId);
//       if (favouriteId != null) {
//         _favouriteIds[hotelId] = favouriteId;
//       }
//     } else {
//       _favouritedHotels.remove(hotelId);
//       _favouriteIds.remove(hotelId);
//     }
//     notifyListeners();
//   }

//   // Toggle favourite status
//   Future<bool> toggleFavourite({
//     required int hotelId,
//     required String userId,
//   }) async {
//     // Prevent multiple simultaneous requests for the same hotel
//     if (_loadingStates[hotelId] == true) {
//       return false;
//     }

//     _loadingStates[hotelId] = true;
//     notifyListeners();

//     try {
//       if (_favouritedHotels.contains(hotelId)) {
//         // Remove favourite
//         final favouriteId = _favouriteIds[hotelId];
//         if (favouriteId == null) {
//           throw Exception("Favourite ID not found for hotel $hotelId");
//         }

//         final success = await FavouriteApiService.removeFavourite(favouriteId);

//         if (success) {
//           _favouritedHotels.remove(hotelId);
//           _favouriteIds.remove(hotelId);
//           _loadingStates[hotelId] = false;
//           notifyListeners();
//           return true;
//         }
//       } else {
//         // Add favourite
//         final response = await FavouriteApiService.addFavourite(
//           userId: userId,
//           hotelId: hotelId,
//         );

//         _favouritedHotels.add(hotelId);
//         _favouriteIds[hotelId] = response["id"];
//         _loadingStates[hotelId] = false;
//         notifyListeners();
//         return true;
//       }
//     } catch (e) {
//       print("Error toggling favourite: $e");

//       // Handle "already favourite" case
//       if (e.toString().contains("Already marked as favourite")) {
//         _favouritedHotels.add(hotelId);
//       }
//     } finally {
//       _loadingStates[hotelId] = false;
//       notifyListeners();
//     }

//     return false;
//   }

//   // Bulk update from hotel list (for initial load)
//   void updateFromHotelList(List<dynamic> hotels) {
//     for (var hotel in hotels) {
//       if (hotel is Map && hotel.containsKey('id')) {
//         final hotelId = hotel['id'] as int;
//         final isFav = hotel['is_favourite'] as bool? ?? false;

//         if (isFav) {
//           _favouritedHotels.add(hotelId);
//         } else {
//           _favouritedHotels.remove(hotelId);
//         }
//       }
//     }
//     notifyListeners();
//   }

//   void clear() {
//     _favouriteIds.clear();
//     _favouritedHotels.clear();
//     _loadingStates.clear();
//     notifyListeners();
//   }
// }
