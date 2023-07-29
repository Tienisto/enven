extension StringExtensions on String {
  /// capitalizes a given string
  /// 'hello' => 'Hello'
  /// 'Hello' => 'Hello'
  /// '' => ''
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  /// transforms the string to the specified case
  /// if case is null, then no transformation will be applied
  String toCamelCase() {
    final words = getWords();
    final firstWord = words[0].toLowerCase();
    final rest = words.skip(1).map((word) => word.capitalize()).join('');
    return '$firstWord$rest';
  }

  /// get word list from string input
  /// assume that words are separated by special characters or by camel case
  List<String> getWords() {
    final input = this;
    final StringBuffer buffer = StringBuffer();
    final List<String> words = [];
    final bool isAllCaps = input.toUpperCase() == input;

    for (int i = 0; i < input.length; i++) {
      final String currChar = input[i];
      final String? nextChar = i + 1 == input.length ? null : input[i + 1];

      if (_symbolSet.contains(currChar)) {
        continue;
      }

      buffer.write(currChar);

      final bool isEndOfWord = nextChar == null ||
          (!isAllCaps && _upperAlphaRegex.hasMatch(nextChar)) ||
          _symbolSet.contains(nextChar);

      if (isEndOfWord) {
        words.add(buffer.toString());
        buffer.clear();
      }
    }

    return words;
  }
}

final RegExp _upperAlphaRegex = RegExp(r'[A-Z]');
final Set<String> _symbolSet = {' ', '.', '_', '-', '/', '\\'};
