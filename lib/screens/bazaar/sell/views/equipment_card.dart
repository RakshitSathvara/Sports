// EquipmentCard.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/model/buy_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/chat_enums.dart';

class EquipmentCard extends StatelessWidget {
  final EquipmentData equipment;
  final VoidCallback onTap;
  final Function(EquipmentData) onView;
  final Function(EquipmentData) onEdit;
  final Function(EquipmentData) onDelete;

  const EquipmentCard({
    super.key,
    required this.onTap,
    required this.equipment,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (equipment.equipmentStatus!.name.toLowerCase()) {
      case 'active':
        return const Color(0xFF1AB805);
      case 'pending':
        return const Color(0xFFEDBE00);
      case 'expired':
        return const Color(0xFFA80000);
      case 'sold':
        return const Color(0xFF3C3C3C);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.18;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: imageHeight,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: equipment.equipmentImages.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: equipment.equipmentImages.first.filePath,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                equipment.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  color: Color(0xFF2B2B2B),
                                ),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ((equipment.equipmentStatus!.code == EquipmentStatusCode.sold.toString()) ||
                                    (equipment.equipmentStatus!.code == EquipmentStatusCode.expired.toString()))
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Color(0xFF006590),
                                        size: 20,
                                      ),
                                      onSelected: (String choice) {
                                        switch (choice) {
                                          case 'view':
                                            onView(equipment);
                                            break;

                                          case 'delete':
                                            onDelete(equipment);
                                            break;
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        const PopupMenuItem<String>(
                                          value: 'view',
                                          child: Text('View'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Color(0xFF006590),
                                        size: 20,
                                      ),
                                      onSelected: (String choice) {
                                        switch (choice) {
                                          case 'view':
                                            onView(equipment);
                                            break;
                                          case 'edit':
                                            onEdit(equipment);
                                            break;
                                          case 'delete':
                                            onDelete(equipment);
                                            break;
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        const PopupMenuItem<String>(
                                          value: 'view',
                                          child: Text('View'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          child: Text(
                            equipment.equipmentStatus?.name ?? '',
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        Text(
                          equipment.expiryDate == null
                              ? ''
                              : 'Expiry: ${equipment.expiryDate == null ? '' : DateFormat('dd/MM/yyyy').format(equipment.expiryDate!)}',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B6B6B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'S\$ - ${equipment.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF006590),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
