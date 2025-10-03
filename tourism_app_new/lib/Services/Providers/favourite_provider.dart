import 'package:flutter/foundation.dart';
import 'package:tourism_app_new/Models/hotel_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/favourites_api_service.dart';

class FavouriteService with ChangeNotifier {
  List<Hotel> _favouriteHotels = [];
  Set<int> _favouriteHotelIds = {};

  List<Hotel> get favouriteHotels => _favouriteHotels;
  Set<int> get favouriteHotelIds => _favouriteHotelIds;

  // Check if a hotel is favourite
  bool isFavourite(int hotelId) {
    return _favouriteHotelIds.contains(hotelId);
  }

  // Load user favourites
  Future<void> loadUserFavourites() async {
    try {
      final favourites = await FavouriteApiService.getUserFavourites();
      _favouriteHotels = favourites;
      _favouriteHotelIds = Set<int>.from(favourites.map((hotel) => hotel.id));
      notifyListeners();
    } catch (e) {
      print('Error loading favourites: $e');
      rethrow;
    }
  }

  // Toggle favourite status
  Future<void> toggleFavourite(int hotelId, bool currentlyFavourite) async {
    try {
      final newStatus = await FavouriteApiService.toggleFavourite(
        hotelId,
        currentlyFavourite,
      );

      if (newStatus) {
        // Added to favourites
        _favouriteHotelIds.add(hotelId);
      } else {
        // Removed from favourites
        _favouriteHotelIds.remove(hotelId);
        _favouriteHotels.removeWhere((hotel) => hotel.id == hotelId);
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling favourite: $e');
      rethrow;
    }
  }

  // Add hotel to favourites list (when you have full hotel data)
  void addFavouriteHotel(Hotel hotel) {
    if (!_favouriteHotelIds.contains(hotel.id)) {
      _favouriteHotelIds.add(hotel.id);
      _favouriteHotels.add(hotel);
      notifyListeners();
    }
  }

  // Clear all favourites (for logout)
  void clearFavourites() {
    _favouriteHotels.clear();
    _favouriteHotelIds.clear();
    notifyListeners();
  }
}
