import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HistoryCardShimmer extends StatelessWidget {
  const HistoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = (screenWidth * 0.16).clamp(52.0, 70.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            /// DATE BOX
            Container(
              width: boxWidth,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(14)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _box(40, 10),
                  const SizedBox(height: 6),
                  _box(20, 16),
                  const SizedBox(height: 6),
                  _box(40, 10),
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
                        _timeBlock(),
                        _divider(),
                        _timeBlock(),
                        _divider(),
                        _timeBlock(),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// LOCATION
                    Row(
                      children: [
                        _circle(16),
                        const SizedBox(width: 6),
                        Expanded(child: _box(double.infinity, 12)),
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

  static Widget _divider() {
    return Container(
      height: 28,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
    );
  }

  static Widget _timeBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(50, 14),
        const SizedBox(height: 6),
        _box(60, 10),
      ],
    );
  }

  static Widget _box(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  static Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
