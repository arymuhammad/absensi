import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme_controller.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();

    return Obx(() {
      // Jika sedang transisi, gunakan target posisi thumb.
      // Jika tidak, gunakan tema aplikasi sebenarnya.
      final isDark =
          themeC.switchDark.value ?? (themeC.themeMode.value == ThemeMode.dark);

      return GestureDetector(
        onTap:
            themeC.isTransitioning.value
                ? null
                : () => themeC.toggleTheme(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: 80,
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [const Color(0xFF000428), const Color(0xFF004e92)]
                      : [const Color(0xFFfceabb), const Color(0xFFf8b500)],
            ),
          ),
          child: Stack(
            children: [
              // =================================================
              // STARS
              // =================================================

              if (isDark)
                AnimatedBuilder(
                  animation: themeC.starController,
                  builder: (_, __) {
                    return Stack(
                      children: List.generate(themeC.starPositions.length, (i) {
                        final position = themeC.starPositions[i];

                        final progress = themeC.starController.value;

                        final dx = position.dx + (progress * 10);

                        final dy = position.dy + sin(progress * 2 * pi) * 2;

                        return Positioned(
                          left: dx,
                          top: dy,
                          child: Opacity(
                            opacity: 0.5 + (sin(progress * 2 * pi) * 0.5),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 6,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

              // =================================================
              // SUN GLOW
              // =================================================
              if (!isDark)
                Center(
                  child: AnimatedBuilder(
                    animation: themeC.glowController,
                    builder: (_, __) {
                      final value = themeC.glowController.value;

                      return Container(
                        width: 30 + (value * 10),
                        height: 30 + (value * 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),

              // =================================================
              // THUMB
              // =================================================
              AnimatedBuilder(
                animation: themeC.thumbController,
                builder: (context, child) {
                  final alignment =
                      Alignment.lerp(
                        Alignment.centerLeft,
                        Alignment.centerRight,
                        themeC.thumbController.value,
                      )!;

                  return Align(alignment: alignment, child: child);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.blueAccent.withOpacity(0.6)
                                : Colors.orangeAccent.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny,
                    size: 16,
                    color: isDark ? Colors.indigo : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
