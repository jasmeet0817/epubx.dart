import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:image/image.dart' as images;
import 'package:logger/logger.dart';

import '../ref_entities/epub_book_ref.dart';
import '../ref_entities/epub_byte_content_file_ref.dart';
import '../schema/opf/epub_manifest_item.dart';
import '../schema/opf/epub_metadata_meta.dart';

class BookCoverReader {
  static final logger = Logger();

  static Future<images.Image?> readBookCover(EpubBookRef bookRef) async {
    var metaItems = bookRef.Schema!.Package!.Metadata!.MetaItems;
    if (metaItems == null || metaItems.isEmpty) return null;

    var coverMetaItem = metaItems.firstWhereOrNull(
        (EpubMetadataMeta metaItem) =>
            metaItem.Name != null && metaItem.Name!.toLowerCase() == 'cover');
    if (coverMetaItem == null) return null;
    if (coverMetaItem.Content == null || coverMetaItem.Content!.isEmpty) {
      logger.e('Incorrect EPUB metadata: cover item content is missing.');
      return null;
    }

    var coverManifestItem = bookRef.Schema!.Package!.Manifest!.Items!
        .firstWhereOrNull((EpubManifestItem manifestItem) =>
            manifestItem.Id!.toLowerCase() ==
            coverMetaItem.Content!.toLowerCase());
    if (coverManifestItem == null) {
      logger.e(
          'Incorrect EPUB manifest: item with ID = \"${coverMetaItem.Content}\" is missing.');
      return null;
    }

    EpubByteContentFileRef? coverImageContentFileRef;
    if (!bookRef.Content!.Images!.containsKey(coverManifestItem.Href)) {
      logger.e(
          'Incorrect EPUB manifest: item with href = \"${coverManifestItem.Href}\" is missing.');
      return null;
    }

    coverImageContentFileRef = bookRef.Content!.Images![coverManifestItem.Href];
    var coverImageContent =
        await coverImageContentFileRef!.readContentAsBytes();
    var retval = images.decodeImage(Uint8List.fromList(coverImageContent));
    return retval;
  }
}
