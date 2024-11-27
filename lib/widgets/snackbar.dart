import 'package:flutter/material.dart';

class CustomSnackBar {
  CustomSnackBar(BuildContext context, Widget content,
      {SnackBarAction? snackBarAction, Color backGroundColor = Colors.white}) {
    final SnackBar snackBar = SnackBar(
      action: snackBarAction,
      backgroundColor: backGroundColor,
      content: DefaultTextStyle(
        style: const TextStyle(color: Colors.black), // 텍스트 컬러를 검정색으로 설정
        child: content,
      ),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
