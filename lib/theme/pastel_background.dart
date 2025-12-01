import 'dart:ui';
import 'package:flutter/material.dart';

class PastelBackground extends StatelessWidget {
  final Widget child;

  const PastelBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9705D1),
            Color(0x45E925F7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
