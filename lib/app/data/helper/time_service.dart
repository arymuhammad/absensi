import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<DateTime?> fetchServerTime(String url) async {
  try {
    final res = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));

    final dateHeader = res.headers['date'];
    if (dateHeader == null) return null;

    final utcTime = HttpDate.parse(dateHeader);
    return utcTime.toLocal();
  } catch (_) {
    return null;
  }
}

Future<DateTime> getSecureTime() async {
  DateTime? serverTime;

  final prefs = await SharedPreferences.getInstance();

  // 🔒 CEK HARD LOCK DI AWAL
  // final isLocked = prefs.getBool("is_time_locked") ?? false;
  // if (isLocked) {
  //   throw Exception("APP LOCKED");
  // }

  // 1. server utama
  serverTime = await fetchServerTime("http://103.156.15.61/api-absensi");

  // 2. fallback urbanxmor
  serverTime ??= await fetchServerTime("https://urbanxmor.com");

  final nowDevice = DateTime.now();

  // ambil cache
  final lastServerMillis = prefs.getInt("last_server_time");
  final lastDeviceMillis = prefs.getInt("last_device_time");

  // =========================
  // ✅ JIKA ONLINE (DAPAT SERVER TIME)
  // =========================
  if (serverTime != null) {
    final diff = serverTime.difference(nowDevice).inSeconds.abs();

    // ✅ JIKA SUDAH NORMAL → UNLOCK
    if (diff <= 60) {
      await prefs.setBool("is_time_locked", false);
    }

    // 🔥 kalau selisih terlalu jauh → manipulasi
    if (diff > 60) {
      await prefs.setBool("is_time_locked", true);
      throw Exception("Time manipulation detected!");
    }

    await prefs.setInt("last_server_time", serverTime.millisecondsSinceEpoch);
    await prefs.setInt("last_device_time", nowDevice.millisecondsSinceEpoch);
    // 🔥 penting (buat offline nanti)
    await prefs.setInt(
      "last_estimated_time",
      serverTime.millisecondsSinceEpoch,
    );
    return serverTime;
  }
  final updatedLock = prefs.getBool("is_time_locked") ?? false;
  // =========================
  // ⚠️ OFFLINE MODE
  // =========================
  if (updatedLock) {
    throw Exception("APP TERKUNCI");
  }
  if (lastServerMillis != null && lastDeviceMillis != null) {
    final lastServerTime = DateTime.fromMillisecondsSinceEpoch(
      lastServerMillis,
    );
    final lastDeviceTime = DateTime.fromMillisecondsSinceEpoch(
      lastDeviceMillis,
    );

    final deviceDiff = nowDevice.difference(lastDeviceTime);
    final estimatedNow = lastServerTime.add(deviceDiff);

    final lastEstimatedMillis = prefs.getInt("last_estimated_time");
    // 🔥 DETEKSI ANEH (drift)
    if (deviceDiff.inSeconds < -30 || deviceDiff.inMinutes > 10) {
      await prefs.setBool("is_time_locked", true);
      throw Exception("Time manipulation detected!");
    }

    // 🔥 DETEKSI MUNDUR (ANTI BYPASS)
    if (lastEstimatedMillis != null) {
      final lastEstimated = DateTime.fromMillisecondsSinceEpoch(
        lastEstimatedMillis,
      );

      if (estimatedNow.isBefore(lastEstimated)) {
        await prefs.setBool("is_time_locked", true);
        throw Exception("Reverse time detected!");
      }
    }
    // 🔥 SIMPAN ESTIMASI TERAKHIR
    await prefs.setInt(
      "last_estimated_time",
      estimatedNow.millisecondsSinceEpoch,
    );

    return estimatedNow;
  }

  // =========================
  // ❌ TIDAK ADA DATA SAMA SEKALI
  // =========================
  throw Exception("Tidak bisa mendapatkan waktu valid.");
}

// Future<DateTime?> getServerTimeLocal() async {
//   final res = await http.get(Uri.parse("http://103.156.15.61/api-absensi"));

//   final dateHeader = res.headers['date'];
//   if (dateHeader == null) return null;

//   // parse GMT → UTC
//   final utcTime = HttpDate.parse(dateHeader);

//   // convert ke timezone device
//   final localTime = utcTime.toLocal();

//   return localTime;
// }
