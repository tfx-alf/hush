import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hush/core/config/theme.dart';

class CustomFormField extends StatelessWidget {
  final String title;
  final bool obsecuretext;
  final TextEditingController? controller;
  final bool showtitle;
  final TextInputType? keyboardtype;
  final Widget icon; // Changed from Icon to Widget
  final Color? iconcolor;
  final Function(String)? onfieldsubmited;
  const CustomFormField({
    key,
    required this.title,
    this.obsecuretext = false,
    this.controller,
    this.showtitle = false,
    this.keyboardtype,
    this.onfieldsubmited,
    required this.icon, // Updated parameter
    this.iconcolor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showtitle)
          Text(
            title,
            style: blackTextStyle.copyWith(
              fontSize: 14.sp,
              fontWeight: medium,
            ),
          ),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          obscureText: obsecuretext,
          controller: controller,
          keyboardType: keyboardtype,
          decoration: InputDecoration(
            hintText: !showtitle ? title : null,
            prefixIcon: icon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          onFieldSubmitted: onfieldsubmited,
        ),
      ],
    );
  }
}
