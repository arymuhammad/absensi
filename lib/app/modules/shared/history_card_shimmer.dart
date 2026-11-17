import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HistoryCardShimmer extends StatelessWidget {
  const HistoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = (screenWidth * 0.16).clamp(52.0, 70.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:  isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.78)
                        : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade400,
        child: Row(
          children: [
            /// DATE BOX
            Container(
              width: boxWidth,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.78)
                        : Colors.white.withValues(alpha: 0.82),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _box(40, 10, isDark),
                  const SizedBox(height: 6),
                  _box(20, 16, isDark),
                  const SizedBox(height: 6),
                  _box(40, 10, isDark),
                ],
              ),
            ),

            /// CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TIME ROW
                    Row(
                      children: [
                        _timeBlock(isDark),
                        _divider(isDark),
                        _timeBlock(isDark),
                        _divider(isDark),
                        _timeBlock(isDark),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// LOCATION
                    Row(
                      children: [
                        _circle(16, isDark),
                        const SizedBox(width: 6),
                        Expanded(child: _box(double.infinity, 12, isDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _divider(bool isDark) {
    return Container(
      height: 28,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color:
          isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.78)
              : Colors.white.withValues(alpha: 0.82),
    );
  }

  static Widget _timeBlock(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_box(50, 14, isDark), const SizedBox(height: 6), _box(60, 10, isDark)],
    );
  }

  static Widget _box(double width, double height, bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  static Widget _circle(double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.82),
        shape: BoxShape.circle,
      ),
    );
  }
}
