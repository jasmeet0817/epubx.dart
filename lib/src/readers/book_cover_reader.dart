import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:image/image.dart' as images;

import '../ref_entities/epub_book_ref.dart';
import '../ref_entities/epub_byte_content_file_ref.dart';
import '../schema/opf/epub_manifest_item.dart';
import '../schema/opf/epub_metadata_meta.dart';

class BookCoverReader {
  static Future<images.Image?> readBookCover(EpubBookRef bookRef) async {
    var metaItems = bookRef.Schema!.Package!.Metadata!.MetaItems;
    if (metaItems == null || metaItems.isEmpty) return null;

    List<EpubMetadataMeta> potentialCoverMetaItems = metaItems
        .where((EpubMetadataMeta metaItem) =>
            metaItem.Name != null &&
            metaItem.Name!.toLowerCase().contains('cover'))
        .toList();
    for (EpubMetadataMeta coverMetaItem in potentialCoverMetaItems) {
      if (coverMetaItem.Content == null || coverMetaItem.Content!.isEmpty) {
        continue;
      }

      EpubManifestItem? coverManifestItem = bookRef
          .Schema!.Package!.Manifest!.Items!
          .firstWhereOrNull((EpubManifestItem manifestItem) =>
              manifestItem.Id!.toLowerCase() ==
              coverMetaItem.Content!.toLowerCase());
      if (coverManifestItem == null) {
        continue;
      }

      EpubByteContentFileRef? coverImageContentFileRef;
      if (!bookRef.Content!.Images!.containsKey(coverManifestItem.Href)) {
        continue;
      }
      coverImageContentFileRef =
          bookRef.Content!.Images![coverManifestItem.Href];
      var coverImageContent =
          await coverImageContentFileRef!.readContentAsBytes();
      var retval = images.decodeImage(coverImageContent);
      return retval;
    }
  }
}
