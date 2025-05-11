import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hush/core/config/theme.dart';
import 'package:hush/core/shared/common_widget/button_widget.dart';

Future<void> showAlertDialog(BuildContext context, String textMessage) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    useSafeArea: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(
            textMessage,
            textAlign: TextAlign.center,
            style: blackTextStyle.copyWith(fontSize: 16.sp, fontWeight: black),
          ),
        ),
        content: Icon(Icons.wifi_off, size: 70.h),
        actions: [
          CustomFilledButton(
            title: 'OK',
            onpressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
