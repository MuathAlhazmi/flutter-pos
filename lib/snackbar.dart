import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:posapp/theme/rally.dart';

snackBarWidget(context, text, icon, iconcolor) {
  return showFlash(
      context: context,
      duration: const Duration(seconds: 2),
      persistent: true,
      builder: (_, controller) {
        return Flash(
          margin: EdgeInsets.symmetric(horizontal: 20),
          borderRadius: BorderRadius.circular(20),
          controller: controller,
          backgroundColor: RallyColors.primaryColor,
          barrierBlur: 13.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          behavior: FlashBehavior.floating,
          position: FlashPosition.top,
          child: FlashBar(
            icon: Icon(icon, color: iconcolor),
            content: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      });
}
