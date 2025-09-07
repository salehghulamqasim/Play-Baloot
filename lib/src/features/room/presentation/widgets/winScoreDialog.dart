import 'package:flutter/material.dart';
import 'package:motion/motion.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact shiny playing card for dialogs/bottom sheets (responsive)
class CompactShinyCard extends StatelessWidget {
  const CompactShinyCard({
    super.key,
    this.suit = '♠',
    this.rank = 'A',
    this.color = Colors.black,
    this.width = 60.0,
    this.height = 80.0,
  });

  final String suit;
  final String rank;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Motion.elevated(
      elevation: 8,
      shadow: false,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8F8FF), Color(0xFFFFFFF0)],
          ),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(suit, style: TextStyle(fontSize: 8.sp, color: color)),
                ],
              ),
            ],
          ),

          Expanded(
            child: Center(
              child: Text(
                suit,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: color.withOpacity(0.8),
                ),
              ),
            ),
          ),

          Transform.rotate(
            angle: 3.14159,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rank,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(suit, style: TextStyle(fontSize: 8.sp, color: color)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Victory celebration widget for bottom sheet (responsive)
class VictoryCardCelebration extends StatelessWidget {
  const VictoryCardCelebration({super.key, this.showCard = true});

  final bool showCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✨', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            Motion.elevated(
              elevation: 4,
              shadow: false,
              borderRadius: BorderRadius.circular(8.r),
              child: Text(
                'VICTORY!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF007AFF),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text('✨', style: TextStyle(fontSize: 16.sp)),
          ],
        ),

        if (showCard) ...[
          SizedBox(height: 12.h),
          const CompactShinyCard(
            suit: '♠',
            rank: 'A',
            color: Colors.black,
            width: 50,
            height: 70,
          ),
        ],

        SizedBox(height: 12.h),
      ],
    );
  }
}

/// Winning bottom sheet (responsive)
class WinningBottomSheet extends StatelessWidget {
  final String winnerLabel;
  final String title;
  final String message;
  final String finishButtonText;
  final VoidCallback? onFinish;
  final bool showVictoryCard;

  const WinningBottomSheet({
    super.key,
    required this.winnerLabel,
    this.title = 'Congratulations',
    this.message = 'Game over. Great match!',
    this.finishButtonText = 'Finish',
    this.onFinish,
    this.showVictoryCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, viewInsets + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFDDDEE3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          VictoryCardCelebration(showCard: showVictoryCard),

          Text(
            winnerLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF007AFF),
            ),
          ),
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE5E5EA), width: 1.w),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 15.sp,
                color: const Color(0xFF1D1D1F),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          AppleStyleButton(
            label: finishButtonText,
            onPressed: () {
              Navigator.pop(context);
              onFinish?.call();
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

/// Apple-style button (responsive)
class AppleStyleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppleStyleButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Helper to show the winning bottom sheet
Future<void> showWinningBottomSheet({
  required BuildContext context,
  required String winnerLabel,
  String title = 'Congratulations',
  String message = 'Game over. Great match!',
  String finishButtonText = 'Finish',
  VoidCallback? onFinish,
  bool showVictoryCard = true,
}) async {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => WinningBottomSheet(
          winnerLabel: winnerLabel,
          title: title,
          message: message,
          finishButtonText: finishButtonText,
          onFinish: onFinish,
          showVictoryCard: showVictoryCard,
        ),
  );
}
