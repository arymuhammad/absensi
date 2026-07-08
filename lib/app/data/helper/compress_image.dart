  import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();

    final targetPath = p.join(
      dir.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,

      // kualitas visual masih bagus
      quality: 78,

      // maksimal sisi terpanjang 1600px
      minWidth: 1280,
      minHeight: 1280,

      format: CompressFormat.jpeg,
    );

    return File(result!.path);
  }