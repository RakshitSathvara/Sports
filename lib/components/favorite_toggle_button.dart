import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';

class FavoriteToggleButton extends StatelessWidget {
  final Function() onFavoriteChanged;
  final bool isFavorite;
  final double size;

  const FavoriteToggleButton({
    Key? key,
    required this.onFavoriteChanged,
    required this.isFavorite,
    this.size = 24.0, // default size matching IconButton
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onFavoriteChanged.call();
      },
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          isFavorite ? 'assets/images/iv_selected_fav.png' : 'assets/images/ic_fav.png',
          fit: BoxFit.contain,
          color: Theme.of(context).extension<CustomColors>()!.coachFacilityFavIconColor,
        ),
      ),
    );
  }
}
