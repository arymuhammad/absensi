import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme_controller.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ProThemeSwitchState();
}

class _ProThemeSwitchState extends State<ThemeSwitcher>
    with TickerProviderStateMixin {
  late AnimationController glowController;
  late AnimationController starController;

  @override
  void initState() {
    super.initState();

    /// ☀️ glow animation
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    /// 🌙 star animation
    starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    glowController.dispose();
    starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeC.themeMode.value == ThemeMode.dark;

      return GestureDetector(
        onTap: () {
          themeC.setTheme(isDark ? ThemeType.light : ThemeType.dark);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 80,
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF000428), const Color(0xFF004e92)]
                  : [const Color(0xFFfceabb), const Color(0xFFf8b500)],
            ),
          ),
          child: Stack(
            children: [
              /// 🌙 BINTANG BERGERAK
              if (isDark)
                AnimatedBuilder(
                  animation: starController,
                  builder: (_, __) {
                    return Stack(
                      children: List.generate(5, (i) {
                        final random = Random(i);
                        final dx =
                            (random.nextDouble() * 50) +
                            (starController.value * 10);
                        final dy =
                            (random.nextDouble() * 20) +
                            sin(starController.value * 2 * pi) * 2;

                        return Positioned(
                          left: dx,
                          top: dy,
                          child: Opacity(
                            opacity: 0.5 +
                                (sin(starController.value * 2 * pi) * 0.5),
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

              /// ☀️ SUN GLOW
              if (!isDark)
                Center(
                  child: AnimatedBuilder(
                    animation: glowController,
                    builder: (_, __) {
                      return Container(
                        width: 30 + (glowController.value * 10),
                        height: 30 + (glowController.value * 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),

              /// 🔘 THUMB
              AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                alignment:
                    isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
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