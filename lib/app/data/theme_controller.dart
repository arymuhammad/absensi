import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circular_theme_reveal/circular_theme_reveal.dart';

enum ThemeType { auto, light, dark }

class ThemeController extends GetxController with GetTickerProviderStateMixin {
  // =========================================================
  // THEME STATE
  // =========================================================

  final themeMode = ThemeMode.light.obs;
  final themeType = ThemeType.auto.obs;

  // =========================================================
  // SWITCH STATE
  // =========================================================

  final RxnBool switchDark = RxnBool();
  final isTransitioning = false.obs;

  // =========================================================
  // ANIMATION CONTROLLER
  // =========================================================

  late AnimationController glowController;
  late AnimationController starController;

  Timer? timer;

  final Random random = Random(10);

  late AnimationController thumbController;

  // Posisi bintang dibuat sekali agar tidak berubah setiap frame.
  late final List<Offset> starPositions = List.generate(
    5,
    (_) => Offset(random.nextDouble() * 50, random.nextDouble() * 20),
  );

  @override
  void onInit() {
    super.onInit();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    thumbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0,
    );

    _loadTheme();

    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (themeType.value == ThemeType.auto) {
        _applyTheme();
      }
    });
  }

  // =========================================================
  // LOAD THEME
  // =========================================================

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_type');

    if (index != null && index >= 0 && index < ThemeType.values.length) {
      themeType.value = ThemeType.values[index];
    }

    _applyTheme(animateThumb: false);

    thumbController.value = themeMode.value == ThemeMode.dark ? 1 : 0;
  }

  // =========================================================
  // SET THEME
  // =========================================================

  Future<void> setTheme(ThemeType type) async {
    themeType.value = type;

    // Terapkan tema langsung, jangan menunggu SharedPreferences.
    _applyTheme();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_type', type.index);
  }

  // =========================================================
  // APPLY THEME
  // =========================================================

  void _applyTheme({bool animateThumb = true}) {
    late final bool isDark;
    late final ThemeMode newMode;

    if (themeType.value == ThemeType.auto) {
      final hour = DateTime.now().hour;

      isDark = hour >= 18 || hour < 6;
      newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      isDark = themeType.value == ThemeType.dark;
      newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    themeMode.value = newMode;

    if (animateThumb && !isTransitioning.value) {
      thumbController.animateTo(
        isDark ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }

    _updateSystemBar(isDark);
  }

  // =========================================================
  // SWITCH THEME WITH CIRCULAR REVEAL
  // =========================================================

  Future<void> toggleTheme(BuildContext context) async {
    if (isTransitioning.value) return;

    final currentDark = themeMode.value == ThemeMode.dark;
    final targetDark = !currentDark;

    final targetTheme = targetDark ? ThemeType.dark : ThemeType.light;

    switchDark.value = targetDark;
    isTransitioning.value = true;

    // Animasi thumb dimulai langsung.
    thumbController.animateTo(
      targetDark ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );

    try {
      final overlay = CircularThemeRevealOverlay.of(context);

      if (overlay == null) {
        await setTheme(targetTheme);
        return;
      }

      final center = CircularThemeRevealOverlay.getCenterFromContext(context);

      await overlay.startTransition(
        center: center,
        reverse: currentDark,
        onThemeChange: () {
          setTheme(targetTheme);
        },
      );
    } catch (e) {
      debugPrint('Theme transition error: $e');
      await setTheme(targetTheme);
    } finally {
      switchDark.value = null;
      isTransitioning.value = false;

      // Pastikan posisi akhir sesuai tema aplikasi.
      thumbController.animateTo(
        themeMode.value == ThemeMode.dark ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // =========================================================
  // SYSTEM BAR
  // =========================================================

  void _updateSystemBar(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFF1B2541),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  void onClose() {
    timer?.cancel();

    glowController.dispose();
    starController.dispose();
    thumbController.dispose();

    super.onClose();
  }
}
