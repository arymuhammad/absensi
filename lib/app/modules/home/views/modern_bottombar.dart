import 'dart:ui';
import 'package:flutter/material.dart';

import 'widget/navbar_style/pulse_glow.dart';

class ModernBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const ModernBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none, // ✅ penting
      children: [
        // ===== GLASS BACKGROUND =====
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _item(Icons.home, "Home", 0),
                  _item(Icons.history, "History", 1),
                  const SizedBox(width: 60),
                  _item(Icons.settings, "Setting", 3),
                  _item(Icons.person, "Profile", 4),
                ],
              ),
            ),
          ),
        ),

        // ===== FLOATING CENTER BUTTON =====
        Positioned(
          bottom: 20,
          child: GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2541), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.6),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _item(IconData icon, String label, int index) {
  final bool active = selectedIndex == index;

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => onTap(index),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: PulseGlow(
        active: active,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: active ? 13 : 11,
                color: active ? Colors.white : Colors.grey,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


}
