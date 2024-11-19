import 'package:flutter/material.dart';

class CustomSnackBar {
  CustomSnackBar(BuildContext context, Widget content,
  {SnackBarAction? snackBarAction, Color backGroundColor = Colors.green}) {
    final SnackBar snackBar = SnackBar(
      action: snackBarAction,
      backgroundColor: backGroundColor,
      content: content,
      behavior: SnackBarBehavior.floating);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}