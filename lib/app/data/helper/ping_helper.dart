import 'dart:io';

class PingResult {
  final bool success;
  final int? latencyMs;
  final String rawOutput;

  PingResult({
    required this.success,
    this.latencyMs,
    required this.rawOutput,
  });
}

class PingHelper {
  /// Main function (auto platform)
  static Future<PingResult> ping(String host) async {
    if (Platform.isAndroid) {
      return _pingAndroid(host);
    } else if (Platform.isIOS) {
      return _pingIOSFallback(host);
    } else {
      return _tcpPing(host);
    }
  }

  /// ANDROID → ICMP ping
  static Future<PingResult> _pingAndroid(String host) async {
    try {
      final result = await Process.run(
        'ping',
        ['-c', '1', '-W', '1', host],
      );

      final output = result.stdout.toString();

      final latency = _parsePingLatency(output);

      return PingResult(
        success: latency != null,
        latencyMs: latency,
        rawOutput: output,
      );
    } catch (e) {
      return PingResult(
        success: false,
        rawOutput: e.toString(),
      );
    }
  }

  /// iOS → TCP latency fallback
  static Future<PingResult> _pingIOSFallback(String host) async {
    try {
      final stopwatch = Stopwatch()..start();

      final socket = await Socket.connect(
        host,
        80,
        timeout: const Duration(seconds: 2),
      );

      stopwatch.stop();
      socket.destroy();

      return PingResult(
        success: true,
        latencyMs: stopwatch.elapsedMilliseconds,
        rawOutput: 'TCP latency',
      );
    } catch (e) {
      return PingResult(
        success: false,
        rawOutput: e.toString(),
      );
    }
  }

  /// Generic TCP ping
  static Future<PingResult> _tcpPing(String host) async {
    try {
      final stopwatch = Stopwatch()..start();

      final socket = await Socket.connect(
        host,
        80,
        timeout: const Duration(seconds: 2),
      );

      stopwatch.stop();
      socket.destroy();

      return PingResult(
        success: true,
        latencyMs: stopwatch.elapsedMilliseconds,
        rawOutput: 'TCP latency',
      );
    } catch (e) {
      return PingResult(
        success: false,
        rawOutput: e.toString(),
      );
    }
  }

  /// Parse latency from ping output
  static int? _parsePingLatency(String output) {
    final regex = RegExp(r'time[=<]\s?(\d+\.?\d*)\s?ms');
    final match = regex.firstMatch(output);

    if (match != null) {
      return double.parse(match.group(1)!).round();
    }
    return null;
  }
}
