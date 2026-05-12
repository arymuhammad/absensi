import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget platFormDevice() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Platform.isAndroid
          ? const CircularProgressIndicator()
          : const CupertinoActivityIndicator(),
      const Text('Loading data...'),
    ],
  );
}
