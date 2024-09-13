import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../services/service_api.dart';

class RoundedImage extends StatelessWidget {
  final double height;
  final double width;
  final String foto;
  final String name;
  const RoundedImage(
      {super.key,
      required this.height,
      required this.width,
      required this.foto,
      required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: foto != ""
            ? CachedNetworkImage(
                imageUrl: "${ServiceApi().baseUrl}$foto",
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) =>
                    CircularProgressIndicator(
                  value: progress.progress,
                  strokeWidth: 15,
                ),
                cacheKey:
                    "${ServiceApi().baseUrl}$foto + ${DateTime.now().day.toString()}",
              )
            : Image.network(
                "https://ui-avatars.com/api/?name=$name",
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
