import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';

import '../helper/helpers.dart';

class Mybottomnavbar extends StatefulWidget {
  const Mybottomnavbar({Key? key, this.index1 = 0}) : super(key: key);
  final int index1;
  @override
  _Mybottom_nav_barState createState() => _Mybottom_nav_barState();
}

class _Mybottom_nav_barState extends State<Mybottomnavbar> {
  int index = 0;

  void selectTab(int i) {
    setState(() {
      index = i;
      switch (index) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(
              context, Constants.APPPAGES, Helper.of(context).predicate,
              arguments: 0);
          break;
        case 1:
          Navigator.pushNamedAndRemoveUntil(
              context, Constants.APPPAGES, Helper.of(context).predicate,
              arguments: 1);
          break;
        case 2:
          Navigator.pushNamedAndRemoveUntil(
              context, Constants.APPPAGES, Helper.of(context).predicate,
              arguments: 2);
          break;
        case 3:
          Navigator.pushNamedAndRemoveUntil(
              context, Constants.APPPAGES, Helper.of(context).predicate,
              arguments: 3);
          break;
        case 4:
          Navigator.pushNamedAndRemoveUntil(
              context, Constants.APPPAGES, Helper.of(context).predicate,
              arguments: 4);
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.background,
        unselectedLabelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 12),
        selectedLabelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 12),
        items: const [
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/home.png"),
              ),
              label: "HOME"),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/calendar.png"),
              ),
              label: "CALENDER"),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/map.png"),
              ),
              label: "MAP"),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/message.png"),
              ),
              label: "MESSAGES"),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/profile.png"),
              ),
              label: "PROFILE"),
        ],
        currentIndex: index,
        onTap: selectTab);
  }
}
