extension StringExt on String {
  /// Truncates the string to no longer than [maxLength].
  ///
  /// [maxLength] includes the length of [ellipsis], if given.
  String truncate(
    int maxLength, {
    String ellipsis,
  }) {
    if (maxLength < 1) {
      throw ArgumentError.value(
        maxLength,
        'maxLength',
        'maxLength < 1',
      );
    }
    if (ellipsis != null && ellipsis.length >= maxLength) {
      throw ArgumentError.value(
        ellipsis,
        'ellipsis',
        'ellipsis.length >= maxLength',
      );
    }

    if (this.length <= maxLength) return this;

    ellipsis ??= '';
    return this.substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Removes the class name from an enum [toString()].
  String asEnumLabel() {
    return this.replaceFirst(RegExp(r'^[^\.]+\.'), '');
  }

  /// Sets the first character to upper case.
  String capitalize() {
    if (this.isEmpty) return this;

    return this.replaceRange(0, 1, this[0].toUpperCase());
  }
}
