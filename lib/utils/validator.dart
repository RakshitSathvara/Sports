import 'package:flutter/material.dart';

class Validator {
  static String? validateMobileAndEmail(String? value) {
    if (value!.trim().isEmpty) {
      return "Please enter the email or mobile number";
    } else if ((!RegExp(r'(^(?:[+0]9)?[0-9]{10}$)').hasMatch(value))) {
      if (!RegExp(
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(value)) {
        return "Please enter a valid email or mobile number";
      }
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value!.trim().isEmpty) {
      return "Please enter the mobile number";
    }
    /*else if ((!RegExp(r'(^(?:[+0]9)?[0-9]$)').hasMatch(value))) {
      return "Please Enter a valid mobile number";
    }*/
    return null;
  }

  static String? validateEmail(String? value) {
    if (value!.trim().isEmpty) {
      return "Please enter the E-mail";
    } else if ((!RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value))) {
      return "Please enter a valid E-mail";
    }
    return null;
  }

  static String? notEmpty(String? value) {
    if (value!.trim().isEmpty) {
      return "Required field";
    }
    return null;
  }

  static String? checkMatch(String? value, String original, String errorText) {
    if (value == original) {
      return null;
    }
    return errorText;
  }

  static String? validatePassword(String? passValue) {
    String patternPass = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$';
    RegExp regex = RegExp(patternPass);
    debugPrint(passValue);
    if (passValue!.trim().isEmpty) {
      return "Please enter password";
    } else if (passValue.length < 6) {
      return "Password must be more than 6 letters";
    } else if (!regex.hasMatch(passValue)) {
      return "Password must contains 1 uppercase, \n1 lowercase, 1 number, 1 special character";
    } else {
      return null;
    }
  }

  static String? validateLoginPassword(String? passValue) {
    if (passValue!.trim().isEmpty) {
      return "Please enter password";
    } else if (passValue.length < 6) {
      return "Password must be more than 6 letters";
    } else {
      return null;
    }
  }
}
