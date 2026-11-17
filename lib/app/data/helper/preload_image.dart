import 'package:flutter/material.dart';

class AppBackgroundPreloader extends StatefulWidget {
  final Widget child;

  const AppBackgroundPreloader({
    super.key,
    required this.child,
  });

  @override
  State<AppBackgroundPreloader> createState() =>
      _AppBackgroundPreloaderState();
}

class _AppBackgroundPreloaderState
    extends State<AppBackgroundPreloader> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(
      const AssetImage('assets/image/bg-ctn.png'),
      context,
    );

    precacheImage(
      const AssetImage('assets/image/bg-hd.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}