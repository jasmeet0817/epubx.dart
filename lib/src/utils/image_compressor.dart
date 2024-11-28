import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Uint8List> compressImage(List<int> originalImageData) async {
  return await FlutterImageCompress.compressWithList(
    Uint8List.fromList(originalImageData),
    quality: 12,
    minWidth: 400,
    minHeight: 400,
  );
}
