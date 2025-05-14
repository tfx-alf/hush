import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hush/core/config/theme.dart';
import 'package:hush/core/shared/common_widget/button_widget.dart';
import 'package:hush/features/joystick/presentation/screen/joystick_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HUSH Bird Repellent',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '2 Client Connected',
                        style: TextStyle(fontSize: 16, color: greenColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JoystickScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: greenColor,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Device ID ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Device Connected',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: greenColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: greenColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              CustomFilledButton(
                title: 'Sync Device',
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
      ),
    );
  }
}
