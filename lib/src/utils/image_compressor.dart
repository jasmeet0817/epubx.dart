import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';

Future<Uint8List> compressImage(List<int> originalImageData) async {
  try {
    return await FlutterImageCompress.compressWithList(
      Uint8List.fromList(originalImageData),
      quality: 12,
      minWidth: 400,
      minHeight: 400,
    );
  } catch (e) {
    Logger().e('Error compressing image: $e');
    return Future.value(Uint8List.fromList(originalImageData));
  }
}
