
import 'package:flutter/material.dart';

class GlobalBackground extends StatelessWidget {
  final Widget child;

  const GlobalBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background terang
        AnimatedOpacity(
          opacity: isDark ? 0 : 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: Image.asset(
            'assets/image/bg-ctn.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),

        // Background gelap
        AnimatedOpacity(
          opacity: isDark ? 1 : 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: Image.asset(
            'assets/image/bg-ctn-drk.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),

        child,
      ],
    );
  }
}
