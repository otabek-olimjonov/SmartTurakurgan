import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirishnomalar')),
      backgroundColor: kColorCream,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_outlined, size: 56, color: kColorStone),
            SizedBox(height: 12),
            Text(
              'Hozircha bildirishnomalar yo\'q',
              style: TextStyle(fontSize: 15, color: kColorTextMuted),
            ),
          ],
        ),
      ),
    );
  }
}
