import 'package:flutter/material.dart';

class CsBgImg extends StatelessWidget {
  const CsBgImg({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/image/bg.png'),
                      fit: BoxFit.fill)),
            );
  }
}
