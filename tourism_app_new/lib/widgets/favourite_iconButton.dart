// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tourism_app_new/Services/Providers/favourite_provider.dart';
// import 'package:tourism_app_new/constants/colors.dart';

// class FavouriteIconButton extends StatelessWidget {
//   final int hotelId;
//   final String userId; // You should get this from your auth service
//   final double iconSize;
//   final Color? filledColor;
//   final Color? outlineColor;
//   final bool showBackground;
//   final Color? backgroundColor;

//   const FavouriteIconButton({
//     Key? key,
//     required this.hotelId,
//     required this.userId,
//     this.iconSize = 24,
//     this.filledColor,
//     this.outlineColor,
//     this.showBackground = true,
//     this.backgroundColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FavouritesProvider>(
//       builder: (context, favouritesProvider, child) {
//         final isFavourite = favouritesProvider.isFavourite(hotelId);
//         final isLoading = favouritesProvider.isLoading;

//         return GestureDetector(
//           onTap:
//               isLoading
//                   ? null
//                   : () => _toggleFavourite(context, favouritesProvider),
//           child: Container(
//             width: iconSize + 16,
//             height: iconSize + 16,
//             decoration:
//                 showBackground
//                     ? BoxDecoration(
//                       color: backgroundColor ?? Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular((iconSize + 16) / 2),
//                     )
//                     : null,
//             child: Center(
//               child:
//                   isLoading
//                       ? SizedBox(
//                         width: iconSize * 0.7,
//                         height: iconSize * 0.7,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             filledColor ?? AppColors.accent,
//                           ),
//                         ),
//                       )
//                       : Icon(
//                         isFavourite ? Icons.favorite : Icons.favorite_border,
//                         color:
//                             isFavourite
//                                 ? (filledColor ?? AppColors.accent)
//                                 : (outlineColor ?? Colors.white),
//                         size: iconSize,
//                       ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _toggleFavourite(
//     BuildContext context,
//     FavouritesProvider provider,
//   ) async {
//     final success = await provider.toggleFavourite(
//       userId: userId,
//       hotelId: hotelId,
//     );

//     if (!context.mounted) return;

//     if (success) {
//       final isFavourite = provider.isFavourite(hotelId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             isFavourite ? 'Added to favorites' : 'Removed from favorites',
//           ),
//           duration: const Duration(seconds: 1),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to update favorites'),
//           duration: Duration(seconds: 2),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }
