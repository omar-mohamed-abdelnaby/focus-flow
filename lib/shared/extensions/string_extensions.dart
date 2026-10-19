/// Extension methods for String
extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize first letter of each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Check if string is empty or contains only whitespace
  bool get isBlank => trim().isEmpty;

  /// Check if string is not empty and contains non-whitespace characters
  bool get isNotBlank => !isBlank;

  /// Remove all whitespace
  String removeWhitespace() => replaceAll(RegExp(r'\s+'), '');

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number (basic check)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Check if string is numeric
  bool get isNumeric => double.tryParse(this) != null;

  /// Convert string to int (returns null if invalid)
  int? toIntOrNull() => int.tryParse(this);

  /// Convert string to double (returns null if invalid)
  double? toDoubleOrNull() => double.tryParse(this);

  /// Truncate string to specified length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Count occurrences of a substring
  int countOccurrences(String substring) {
    if (isEmpty || substring.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = indexOf(substring, index)) != -1) {
      count++;
      index += substring.length;
    }
    return count;
  }

  /// Reverse string
  String reverse() => split('').reversed.join();

  /// Check if string contains only letters
  bool get isAlphabetic => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Check if string contains only alphanumeric characters
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// Convert to snake_case
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Convert to camelCase
  String toCamelCase() {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((word) => word.capitalize()).join();
  }

  /// Convert to PascalCase
  String toPascalCase() {
    if (isEmpty) return this;
    return split(RegExp(r'[\s_-]+'))
        .map((word) => word.capitalize())
        .join();
  }

  /// Extract numbers from string
  String extractNumbers() => replaceAll(RegExp(r'[^0-9]'), '');

  /// Extract letters from string
  String extractLetters() => replaceAll(RegExp(r'[^a-zA-Z]'), '');

  /// Check if string matches another string (case insensitive)
  bool equalsIgnoreCase(String other) {
    return toLowerCase() == other.toLowerCase();
  }

  /// Wrap text to specified line length
  String wrapText(int lineLength) {
    if (length <= lineLength) return this;

    final words = split(' ');
    final lines = <String>[];
    String currentLine = '';

    for (final word in words) {
      if ((currentLine + word).length <= lineLength) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (currentLine.isNotEmpty) lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) lines.add(currentLine);
    return lines.join('\n');
  }
}

/// Extension methods for nullable String
extension NullableStringExtensions on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is null, empty, or blank
  bool get isNullOrBlank => this == null || this!.isBlank;

  /// Get value or default if null
  String orDefault(String defaultValue) => this ?? defaultValue;

  /// Get value or empty string if null
  String get orEmpty => this ?? '';
}
