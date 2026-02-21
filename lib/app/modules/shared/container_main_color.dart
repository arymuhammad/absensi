import 'package:flutter/material.dart';

class ContainerMainColor extends StatelessWidget {
  const ContainerMainColor({super.key, required this.child, required this.begin, required this.end, required this.radius});
  final Widget child;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final double radius;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:  LinearGradient(
          colors: const [Color(0xFF1B2541), Color(0xFF3949AB)],
          begin: begin,
          end: end,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
