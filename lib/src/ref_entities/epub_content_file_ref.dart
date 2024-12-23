import 'dart:async';
import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:epubx/src/utils/image_compressor.dart';
import 'package:quiver/core.dart';

import '../entities/epub_content_type.dart';
import '../utils/zip_path_utils.dart';
import 'epub_book_ref.dart';

abstract class EpubContentFileRef {
  late EpubBookRef epubBookRef;

  String? FileName;

  EpubContentType? ContentType;
  String? ContentMimeType;
  EpubContentFileRef(EpubBookRef epubBookRef) {
    this.epubBookRef = epubBookRef;
  }

  @override
  int get hashCode =>
      hash3(FileName.hashCode, ContentMimeType.hashCode, ContentType.hashCode);

  @override
  bool operator ==(other) {
    if (!(other is EpubContentFileRef)) {
      return false;
    }

    return (other.FileName == FileName &&
        other.ContentMimeType == ContentMimeType &&
        other.ContentType == ContentType);
  }

  ArchiveFile getContentFileEntry() {
    var contentFilePath = ZipPathUtils.combine(
        epubBookRef.Schema!.ContentDirectoryPath, FileName);
    var contentFileEntry = epubBookRef.EpubArchive()!
        .files
        .firstWhereOrNull((ArchiveFile x) => x.name == contentFilePath);
    if (contentFileEntry == null) {
      throw Exception(
          'EPUB parsing error: file $contentFilePath not found in archive.');
    }
    return contentFileEntry;
  }

  List<int> getContentStream() {
    return openContentStream(getContentFileEntry());
  }

  List<int> openContentStream(ArchiveFile contentFileEntry) {
    if (contentFileEntry.content == null) {
      throw Exception(
          'Incorrect EPUB file: content file \"$FileName\" specified in manifest is not found.');
    }
    return contentFileEntry.content;
  }

  Future<Uint8List> readContentAsBytes(bool isImage,
      {int imageCompressionRate = 25}) async {
    var contentFileEntry = getContentFileEntry();
    var content = openContentStream(contentFileEntry);
    if (isImage) {
      return compressImage(content, imageCompressionRate);
    }
    return Uint8List.fromList(content);
  }

  Future<String> readContentAsText() async {
    var contentStream = getContentStream();
    var result = convert.utf8.decode(contentStream);
    return result;
  }
}
