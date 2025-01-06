
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../services/service_api.dart';

class RoundedImage extends StatelessWidget {
  final double height;
  final double width;
  final String foto;
  final String name;
  final bool headerProfile;
  const RoundedImage(
      {super.key,
      required this.height,
      required this.width,
      required this.foto,
      required this.name,
      required this.headerProfile});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: headerProfile
            ? foto != ""
                ? CachedNetworkImage(
                    imageUrl: "${ServiceApi().baseUrlPath}$foto",
                    fit: BoxFit.fill,
                    progressIndicatorBuilder: (context, url, progress) =>
                        CircularProgressIndicator(
                      value: progress.progress,
                      strokeWidth: 15,
                    ),
                    cacheKey:
                        "${ServiceApi().baseUrlPath}$foto + ${DateTime.now().day.toString()}",
                  )
                : Image.network(
                    "https://ui-avatars.com/api/?name=$name",
                    fit: BoxFit.cover,
                  )
            : foto != "" && foto.contains('absensi/')
                ? CachedNetworkImage(
                    imageUrl: "${ServiceApi().baseUrlPath}$foto",
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) =>
                        CircularProgressIndicator(
                      value: progress.progress,
                      strokeWidth: 15,
                    ),
                    cacheKey:
                        "${ServiceApi().baseUrlPath}$foto + ${DateTime.now().day.toString()}",
                  )
                : foto != "" && foto.contains('/data')
                    ? Image.file(File(foto),
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/image/selfie.png'),
                        fit: BoxFit.cover)
                    : Image.network(
                        "https://ui-avatars.com/api/?name=$name",
                        fit: BoxFit.cover,
                      ),
      ),
    );
  }
}
