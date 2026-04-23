import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { auto, light, dark }

class ThemeController extends GetxController {
  final themeMode = ThemeMode.light.obs;
  final themeType = ThemeType.auto.obs;
  Timer? timer;
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (themeType.value == ThemeType.auto) {
        _applyTheme(); // 🔥 hanya jalan kalau AUTO
      }
    });
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_type');

    if (index != null) {
      themeType.value = ThemeType.values[index];
    }

    _applyTheme();
  }

  void setTheme(ThemeType type) async {
    themeType.value = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_type', type.index); // 🔥 simpan
    _applyTheme();
  }

  void _applyTheme() {
    if (themeType.value == ThemeType.auto) {
      final hour = DateTime.now().hour;
      final isDark = hour >= 18 || hour < 6;

      themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
      _updateSystemBar(isDark);
    } else if (themeType.value == ThemeType.dark) {
      themeMode.value = ThemeMode.dark;
      _updateSystemBar(true);
    } else {
      themeMode.value = ThemeMode.light;
      _updateSystemBar(false);
    }
  }

  void _updateSystemBar(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFF1B2541),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
