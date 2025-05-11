import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hush/core/config/theme.dart';
import 'package:hush/core/shared/common_widget/form_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,

        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Parameter Setting',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 65,
        itemBuilder: (context, index) {
          return CustomFormField(title: 'Kosong', icon: Icon(Icons.link));
        },
      ),
    );
  }
}
