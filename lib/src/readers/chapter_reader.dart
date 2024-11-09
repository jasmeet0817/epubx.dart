import '../ref_entities/epub_book_ref.dart';
import '../ref_entities/epub_chapter_ref.dart';
import '../ref_entities/epub_text_content_file_ref.dart';
import '../schema/navigation/epub_navigation_point.dart';

class ChapterReader {
  static List<EpubChapterRef> getChapters(EpubBookRef bookRef) {
    if (bookRef.Schema!.Navigation == null) {
      return <EpubChapterRef>[];
    }
    var navigationPoints = bookRef.Schema!.Navigation!.NavMap!.Points!;
    var unmappedChapters = getUnmappedChapters(bookRef, navigationPoints);
    return getChaptersImpl(bookRef, navigationPoints, unmappedChapters);
  }

  static List<EpubChapterRef> getChaptersImpl(
    EpubBookRef bookRef,
    List<EpubNavigationPoint> navigationPoints,
    List<String> unmappedChapters,
  ) {
    var result = <EpubChapterRef>[];
    for (var navigationPoint in navigationPoints) {
      String? contentFileName;
      String? anchor;
      if (navigationPoint.Content?.Source == null) continue;
      var contentSourceAnchorCharIndex =
          navigationPoint.Content!.Source!.indexOf('#');
      if (contentSourceAnchorCharIndex == -1) {
        contentFileName = navigationPoint.Content!.Source;
        anchor = null;
      } else {
        contentFileName = navigationPoint.Content!.Source!
            .substring(0, contentSourceAnchorCharIndex);
        anchor = navigationPoint.Content!.Source!
            .substring(contentSourceAnchorCharIndex + 1);
      }
      contentFileName = Uri.decodeFull(contentFileName!);
      EpubTextContentFileRef? htmlContentFileRef;
      if (!bookRef.Content!.Html!.containsKey(contentFileName)) {
        throw Exception(
            'Incorrect EPUB manifest: item with href = \"$contentFileName\" is missing.');
      }

      htmlContentFileRef = bookRef.Content!.Html![contentFileName];
      var chapterRef = EpubChapterRef(htmlContentFileRef);
      chapterRef.ContentFileName = contentFileName;
      chapterRef.Anchor = anchor;
      chapterRef.Title = navigationPoint.NavigationLabels!.first.Text;
      chapterRef.SubChapters = getChaptersImpl(
          bookRef, navigationPoint.ChildNavigationPoints!, unmappedChapters);
      if (chapterRef.ContentFileName!.contains('_split_')) {
        var fileNamePart = chapterRef.ContentFileName!.split('_split_')[0];
        for (var fileName in unmappedChapters) {
          if (fileName.contains(fileNamePart)) {
            if (fileName == contentFileName) {
              continue;
            }
            chapterRef.otherTextContentFileRefs
                .add(bookRef.Content!.Html![fileName]!);
            chapterRef.OtherContentFileNames.add(fileName);
          }
        }
      }

      result.add(chapterRef);
    }
    ;
    return result;
  }

  /// Sometimes chapters are split into multiple files,
  /// but the split files are not listed in the navigation.
  /// We need to find these files and add them to the chapter as [OtherContentFileNames].
  static List<String> getUnmappedChapters(
      EpubBookRef bookRef, List<EpubNavigationPoint> navigationPoints) {
    var navigationFileNames = Set<String>.from(
        navigationPoints.map((point) => point.Content!.Source!));
    var allFileNames = Set<String>.from(bookRef.Content!.Html!.keys);

    return allFileNames.difference(navigationFileNames).toList();
  }
}
