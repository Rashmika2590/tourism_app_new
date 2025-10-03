import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app_new/Services/Providers/favourite_provider.dart';
import 'package:tourism_app_new/constants/colors.dart';

class FavouriteIcon extends StatefulWidget {
  final int hotelId;
  final double size;
  final Color favoriteColor;
  final Color unfavoriteColor;
  final bool showSnackbar;

  const FavouriteIcon({
    Key? key,
    required this.hotelId,
    this.size = 10.0,
    this.favoriteColor = AppColors.buttonColor,
    this.unfavoriteColor = AppColors.buttonColor,
    this.showSnackbar = true,
  }) : super(key: key);

  @override
  State<FavouriteIcon> createState() => _FavouriteIconState();
}

class Appcolors {}

class _FavouriteIconState extends State<FavouriteIcon> {
  bool _isLoading = false;

  Future<void> _toggleFavourite(FavouriteService favouriteService) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final currentlyFavourite = favouriteService.isFavourite(widget.hotelId);

    try {
      await favouriteService.toggleFavourite(
        widget.hotelId,
        currentlyFavourite,
      );

      if (widget.showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentlyFavourite
                  ? 'Added to favourites'
                  : 'Removed from favourites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling favourite: $e');

      if (widget.showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update favourite'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouriteService>(
      builder: (context, favouriteService, child) {
        final isFavourite = favouriteService.isFavourite(widget.hotelId);

        return GestureDetector(
          onTap: () => _toggleFavourite(favouriteService),
          child:
              _isLoading
                  ? SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.favoriteColor,
                      ),
                    ),
                  )
                  : Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                    color:
                        isFavourite
                            ? widget.favoriteColor
                            : widget.unfavoriteColor,
                    size: widget.size,
                  ),
        );
      },
    );
  }
}
