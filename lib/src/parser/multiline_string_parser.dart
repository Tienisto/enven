final _startSingleQuoteRegex = RegExp(r"^(\w+)='([^']*)$");
final _startDoubleQuoteRegex = RegExp(r'^(\w+)="([^"]*)$');

final _endSingleQuoteRegex = RegExp(r"^(.*)'(?:\s*#.*)?$");
final _endDoubleQuoteRegex = RegExp(r'^(.*)"(?:\s*#.*)?$');

class MultilineStringParser {
  const MultilineStringParser();

  MultilineValue? start(String line) {
    QuoteType? quoteType;
    String? key;
    String? value;

    final singleQuoteString = _startSingleQuoteRegex.firstMatch(line);
    if (singleQuoteString != null) {
      quoteType = QuoteType.single;
      key = singleQuoteString.group(1);
      value = singleQuoteString.group(2);
    } else {
      final doubleQuoteString = _startDoubleQuoteRegex.firstMatch(line);
      if (doubleQuoteString != null) {
        quoteType = QuoteType.double;
        key = doubleQuoteString.group(1);
        value = doubleQuoteString.group(2);
      }
    }

    if (quoteType == null) {
      return null;
    }

    return MultilineValue(
      buffer: StringBuffer()..write(value),
      key: key!,
      quote: quoteType,
    );
  }

  void append(MultilineValue value, String line) {
    if (value.isFinished) {
      return;
    }

    final match = value._quote == QuoteType.single
        ? _endSingleQuoteRegex.firstMatch(line)
        : _endDoubleQuoteRegex.firstMatch(line);

    value._buffer.write('\n');
    if (match != null) {
      value._buffer.write(match.group(1));
      value._finished = true;
    } else {
      value._buffer.write(line);
    }
  }
}

enum QuoteType {
  single,
  double,
}

class MultilineValue {
  final StringBuffer _buffer;
  final String key;
  final QuoteType _quote;
  bool _finished = false;

  MultilineValue({
    required StringBuffer buffer,
    required this.key,
    required QuoteType quote,
  })  : _buffer = buffer,
        _quote = quote;

  String convertToSingleLine() {
    final quote = _quote == QuoteType.single ? "'" : '"';
    return '$key=$quote${_buffer.toString()}$quote';
  }

  bool get isFinished => _finished;
}
