import 'package:flutter/material.dart';

class PulseGlow extends StatefulWidget {
  final Widget child;
  final bool active;

  const PulseGlow({
    super.key,
    required this.child,
    required this.active,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant PulseGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        return DefaultTextStyle.merge(
          style: TextStyle(
            shadows: [
              Shadow(
                color: Colors.blueAccent.withOpacity(_anim.value),
                blurRadius: 14 * _anim.value,
              ),
            ],
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              shadows: [
                Shadow(
                  color: Colors.blueAccent.withOpacity(_anim.value),
                  blurRadius: 14 * _anim.value,
                ),
              ],
            ),
            child: child!,
          ),
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
