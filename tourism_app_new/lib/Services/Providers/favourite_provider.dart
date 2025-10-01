import 'package:flutter/material.dart';
import 'package:tourism_app_new/models/favourite_model.dart';
import 'package:tourism_app_new/Services/Api%20Services/favourites_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteProvider with ChangeNotifier {
  List<Favourite> _favourites = [];
  bool _isLoading = false;
  String? _error;

  List<Favourite> get favourites => _favourites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _refetchFavouritesData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }
      _favourites = await FavouriteApiService.getFavourites(user.uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  // Fetches all favourites for the current user, with loading indicator
  Future<void> fetchFavourites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _refetchFavouritesData();

    _isLoading = false;
    notifyListeners();
  }

  // Check if a hotel is a favourite
  bool isFavourite(int hotelId) {
    return _favourites.any((favourite) => favourite.hotelId == hotelId);
  }

  // Toggles a favourite on or off
  Future<void> toggleFavourite(int hotelId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = "User not logged in";
      notifyListeners();
      return;
    }

    if (isFavourite(hotelId)) {
      await _removeFavourite(hotelId);
    } else {
      await _addFavourite(hotelId, user.uid);
    }
  }

  Future<void> _addFavourite(int hotelId, String userId) async {
    try {
      await FavouriteApiService.addFavourite(
        userId: userId,
        hotelId: hotelId,
      );
      await _refetchFavouritesData();
      notifyListeners(); // Update UI after refetch
    } catch (e) {
      _error = "Failed to add favourite: $e";
      notifyListeners();
    }
  }

  Future<void> _removeFavourite(int hotelId) async {
    try {
      await FavouriteApiService.removeFavouriteByHotelId(hotelId);
      await _refetchFavouritesData();
      notifyListeners(); // Update UI after refetch
    } catch (e) {
      _error = "Failed to remove favourite: $e";
      notifyListeners();
    }
  }
}