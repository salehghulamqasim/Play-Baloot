import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class IntroIconWithText extends StatelessWidget {
  final String iconPath;
  final String label;
  final double iconSize; // NEW
  final double textSize; // NEW
  final Color iconColor;

  const IntroIconWithText({
    super.key,
    required this.iconPath,
    required this.label,
    this.iconSize = 100, //size of the image or icons
    this.textSize = 26,
    this.iconColor = Colors.black, // default color for the icon
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          iconPath,
          height: iconSize.h,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: textSize.sp, height: 1.25),
          ),
        ),
      ],
    );
  }
}

class FancyButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FancyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 70.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 12.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 30.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 22.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppleStyleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // <-- make nullable

  const AppleStyleButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        onPressed: onPressed, // if null => disabled (greyed)
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
