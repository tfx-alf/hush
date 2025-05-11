import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hush/core/config/theme.dart';
import 'package:hush/core/shared/common_widget/button_widget.dart';
import 'package:hush/core/shared/common_widget/form_widget.dart';
import 'package:hush/features/home/presentation/screen/home_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HUSH',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Hostile-Bird Ultimate Security Handler',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Container(
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFormField(
                      title: 'Email',
                      obsecuretext: false,
                      showtitle: true,
                      icon: const Icon(Icons.email),
                      controller: TextEditingController(),
                    ),
                    SizedBox(height: 16.h),
                    CustomFormField(
                      title: 'Password',
                      obsecuretext: true,
                      showtitle: true,
                      icon: const Icon(Icons.lock),
                      controller: TextEditingController(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            CustomFilledButton(
              title: 'Login',
              onpressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
