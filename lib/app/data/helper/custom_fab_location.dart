import 'package:flutter/material.dart';

class RaisedFabLocation extends FloatingActionButtonLocation {
  final double offsetY;

  const RaisedFabLocation({this.offsetY = 65});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final offset =
        FloatingActionButtonLocation.endFloat.getOffset(geometry);

    return Offset(
      offset.dx,
      offset.dy - offsetY,
    );
  }
}