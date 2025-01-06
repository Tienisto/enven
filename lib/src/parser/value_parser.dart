final _boolRegex = RegExp(r'^(true|false)(?:\s*#.*)?$');
final _doubleRegex = RegExp(r'^(-?\d+\.\d+)(?:\s*#.*)?$');
final _intRegex = RegExp(r'^(-?\d+)(?:\s*#.*)?$');
final _stringSingleQuoteRegex = RegExp(r"^'(.*)'(?:\s*#.*)?$", dotAll: true);
final _stringDoubleQuoteRegex = RegExp(r'^"(.*)"(?:\s*#.*)?$', dotAll: true);
final _nullRegex = RegExp(r'^(null)(?:\s*#.*)?$');

class ValueParser {
  const ValueParser();

  /// Parses the value from the given [value] and [type].
  Object? parseValue({required String value, String? type}) {
    if (type != null) {
      if (type.endsWith('?')) {
        if (_nullRegex.hasMatch(value)) {
          return null;
        } else {
          type = type.substring(0, type.length - 1);
        }
      }

      switch (type) {
        case 'bool':
          return parseBool(value);
        case 'double':
          return parseDouble(value);
        case 'int':
          return parseInt(value);
        case 'String':
          return parseString(value);
        default:
          throw Exception('Unknown type: $type');
      }
    }

    final boolValue = parseBool(value);
    if (boolValue != null) {
      return boolValue;
    }

    final doubleValue = parseDouble(value);
    if (doubleValue != null) {
      return doubleValue;
    }

    final intValue = parseInt(value);
    if (intValue != null) {
      return intValue;
    }

    return parseString(value);
  }

  bool? parseBool(String value) {
    final match = _boolRegex.firstMatch(value);
    return match != null ? match.group(1) == 'true' : null;
  }

  double? parseDouble(String value) {
    final match = _doubleRegex.firstMatch(value);
    return match != null ? double.parse(match.group(1)!) : null;
  }

  int? parseInt(String value) {
    final match = _intRegex.firstMatch(value);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  String parseString(String value) {
    final singleQuoteMatch = _stringSingleQuoteRegex.firstMatch(value);
    if (singleQuoteMatch != null) {
      return singleQuoteMatch.group(1)!;
    }

    final doubleQuoteMatch = _stringDoubleQuoteRegex.firstMatch(value);
    if (doubleQuoteMatch != null) {
      return doubleQuoteMatch.group(1)!;
    }

    return value.split('#')[0].trim();
  }
}
