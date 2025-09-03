import 'package:flutter/material.dart';

@immutable
class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.onTabSelected,
    required this.icon,
  });

  final Function(int index) onTabSelected;
  final Widget icon;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          decoration: BoxDecoration(
            color: const Color(0xFF006590),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Tab Item
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                  widget.onTabSelected(0);
                },
                child: _tabItem(
                  icon: 'assets/images/ic_equipment.png',
                  label: "Equipments",
                  isActive: _selectedIndex == 0,
                ),
              ),
              // Separator
              _verticalDivider(),
              // Right Tab Item
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  widget.onTabSelected(1);
                },
                child: _tabItem(
                  icon: 'assets/images/ic_ads.png',
                  label: "Ads",
                  isActive: _selectedIndex == 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem({
    required String icon,
    required String label,
    required bool isActive,
  }) {
    return Row(
      children: [
        Image.asset(
          icon,
          fit: BoxFit.contain,
          height: 20,
          width: 20,
        ),
        const SizedBox(width: 4.0),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SFPro',
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        height: 20.0,
        width: 1.0,
        color: Colors.white54,
      ),
    );
  }
}
