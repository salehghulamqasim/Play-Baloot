import 'package:flutter/material.dart';
import 'package:motion/motion.dart';

/// Compact shiny playing card for dialogs/bottom sheets
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF), // Pure white
              Color(0xFFF8F8FF), // Ghost white
              Color(0xFFFFFFF0), // Ivory
            ],
          ),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          // Top rank and suit
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(suit, style: TextStyle(fontSize: 8, color: color)),
                ],
              ),
            ],
          ),

          // Center large suit
          Expanded(
            child: Center(
              child: Text(
                suit,
                style: TextStyle(fontSize: 24, color: color.withOpacity(0.8)),
              ),
            ),
          ),

          // Bottom rank and suit (upside down)
          Transform.rotate(
            angle: 3.14159, // 180 degrees
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rank,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(suit, style: TextStyle(fontSize: 8, color: color)),
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

/// Victory celebration widget for bottom sheet
class VictoryCardCelebration extends StatelessWidget {
  const VictoryCardCelebration({super.key, this.showCard = true});

  final bool showCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Victory text with sparkles
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Motion.elevated(
              elevation: 4,
              child: const Text(
                'VICTORY!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('✨', style: TextStyle(fontSize: 16)),
          ],
        ),

        if (showCard) ...[
          const SizedBox(height: 12),
          // Winning card
          const CompactShinyCard(
            suit: '♠',
            rank: 'A',
            color: Colors.black,
            width: 50,
            height: 70,
          ),
        ],

        const SizedBox(height: 12),
      ],
    );
  }
}

/// Updated WinningBottomSheet with card integration
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
      padding: EdgeInsets.fromLTRB(24, 16, 24, viewInsets + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFDDDEE3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Victory Card Celebration
          VictoryCardCelebration(showCard: showVictoryCard),

          // Winner Label
          Text(
            winnerLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 16),

          // Message Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 15,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Finish Button
          Motion.elevated(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onFinish?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  finishButtonText,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Helper function to show the winning bottom sheet
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

/// Example usage
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Sheet Card Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Baloot Card Game',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            // Preview compact card
            const CompactShinyCard(
              suit: '♠',
              rank: 'A',
              color: Colors.black,
              width: 60,
              height: 80,
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () async {
                await showWinningBottomSheet(
                  context: context,
                  winnerLabel: 'Team A Wins!',
                  title: 'Victory!',
                  message: 'Amazing performance! Well played.',
                  finishButtonText: 'New Game',
                  showVictoryCard: true,
                  onFinish: () {
                    print('Game finished!');
                  },
                );
              },
              child: const Text('Show Victory Dialog'),
            ),
          ],
        ),
      ),
    );
  }
}
