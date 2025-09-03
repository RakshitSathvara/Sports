import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/helper/dialog_helper.dart';

class Helper {
  late BuildContext context;
  late DateTime currentBackPressTime;
  Helper.of(BuildContext context) {
    context = context;
  }
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void goBack(dynamic result) {
    Navigator.pop(context, result);
  }

  bool predicate(Route<dynamic> route) {
    //print(route);
    return false;
  }
}
