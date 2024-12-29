enum BookSize {
  EXTREMELY_LARGE,
  VERY_LARGE,
  LARGE,
  MEDIUM,
  SMALL;

  static BookSize fromByteLength(int size) {
    final sizeInMB = size / 1024 / 1024;
    if (sizeInMB >= 60) {
      return BookSize.EXTREMELY_LARGE;
    } else if (sizeInMB >= 30) {
      return BookSize.VERY_LARGE;
    } else if (sizeInMB >= 10) {
      return BookSize.LARGE;
    } else if (sizeInMB >= 5) {
      return BookSize.MEDIUM;
    } else {
      return BookSize.SMALL;
    }
  }

  get isTooLarge => this == BookSize.EXTREMELY_LARGE;

  int getImageCompressionRate() {
    switch (this) {
      case BookSize.EXTREMELY_LARGE:
        return 5;
      case BookSize.VERY_LARGE:
        return 12;
      case BookSize.LARGE:
        return 25;
      case BookSize.MEDIUM:
        return 30;
      case BookSize.SMALL:
        return 50;
    }
  }
}
