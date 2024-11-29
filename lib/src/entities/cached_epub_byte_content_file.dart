import 'dart:typed_data';

import 'package:epubx/epubx.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedEpubByteContentFile extends EpubContentFile {
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'byteDataCache',
      maxNrOfCacheObjects: 100,
      stalePeriod: const Duration(days: 300),
    ),
  );

  static Future<Uint8List> getContentFromCache(String hashCodeValue) async {
    final cachedFile = await _cacheManager.getFileFromCache(hashCodeValue);
    if (cachedFile != null) {
      return cachedFile.file.readAsBytes();
    } else {
      return Future.value(Uint8List(0));
    }
  }

  static Future<void> invalidateCache() {
    return _cacheManager.emptyCache();
  }

  late int hashCodeValue;

  CachedEpubByteContentFile.fromJson(Map<String, dynamic> json) {
    FileName = json['FileName'];
    ContentType = EpubContentType.values[json['ContentType']];
    ContentMimeType = json['ContentMimeType'];
    hashCodeValue = json['hashCodeValue'];
  }

  CachedEpubByteContentFile(EpubByteContentFile byteFile) {
    FileName = byteFile.FileName;
    ContentType = byteFile.ContentType;
    ContentMimeType = byteFile.ContentMimeType;

    hashCodeValue = byteFile.hashCode;

    _cacheManager.putFile(
        hashCodeValue.toString(), Uint8List.fromList(byteFile.Content!));

    // Try and collect the garbage
    byteFile.Content = null;
  }

  Future<Uint8List> getContent() async {
    return getContentFromCache(hashCodeValue.toString());
  }

  @override
  int get hashCode {
    return hashCodeValue;
  }

  @override
  bool operator ==(other) {
    if (!(other is CachedEpubByteContentFile)) {
      return false;
    }
    return hashCodeValue == other.hashCodeValue &&
        ContentMimeType == other.ContentMimeType &&
        ContentType == other.ContentType &&
        FileName == other.FileName;
  }

  Map<String, dynamic> toJson() {
    return {
      'FileName': FileName,
      'ContentType': ContentType!.index,
      'ContentMimeType': ContentMimeType,
      'hashCodeValue': hashCodeValue,
    };
  }
}
