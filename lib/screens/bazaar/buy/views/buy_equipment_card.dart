import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/model/buy_equipment_response_model.dart';

class BuyEquipmentCard extends StatelessWidget {
  final EquipmentData equipment;
  final VoidCallback onTap;
  final VoidCallback onFavouriteTap;
  final bool isFavorite;

  const BuyEquipmentCard({
    super.key,
    required this.onTap,
    required this.equipment,
    required this.onFavouriteTap,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 6.2 / 5.1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: equipment.equipmentImages.first.filePath,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    equipment.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Source
                  Text(
                    'by ${equipment.equipmentCategory?.name ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      overflow: TextOverflow.ellipsis,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Price and Favorite Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'S\$ - ${equipment.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006590),
                        ),
                      ),
                      GestureDetector(
                        onTap: onFavouriteTap,
                        child: Image.asset(
                          isFavorite ? 'assets/images/ic_bazaar_selected_fav.png' : 'assets/images/ic_bazaar_un_selected_fav.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
