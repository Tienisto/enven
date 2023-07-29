import 'dart:io';

import 'package:enven/model/enven_file.dart';

const _envFiles = [
  '.env',
  '.env.dev',
  '.env.development',
  '.env.prod',
  '.env.production',
];
final _doubleRegex = RegExp(r'^-?\d+\.\d+$');
final _intRegex = RegExp(r'^-?\d+$');

class EnvParser {
  const EnvParser();

  /// Parses the .env file from the file system.
  EnvFile fromFileSystem() {
    EnvFile? curr;
    for (final envFile in _envFiles) {
      final file = File(envFile);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final parsed = parse(content);
        if (curr != null) {
          curr = parsed.withFallback(curr);
        } else {
          curr = parsed;
        }
      }
    }

    if (curr == null) {
      throw Exception('No .env file found');
    }

    return curr;
  }

  /// Parses the .env file from the given [content].
  EnvFile parse(String content) {
    final lines = content.split('\n');

    // config
    String? output;

    final entries = <String, EnvEntry>{};
    Map<String, EnvEntryAnnotation> annotationCache = {};
    for (final line in lines) {
      if (line.startsWith('#')) {
        final annotation = parseAnnotation(line);
        if (annotation != null) {
          switch (annotation.key) {
            case 'output':
              output = annotation.value.toString();
              break;
          }
          annotationCache[annotation.key] = annotation;
        }
      } else {
        final entry = parseEntry(line, annotationCache);
        if (entry != null) {
          entries[entry.key] = entry;
          annotationCache = {};
        }
      }
    }

    return EnvFile(
      config: EnvenConfig(
        output: output,
      ),
      entries: entries,
    );
  }

  /// Parses the annotation from the given [line].
  /// Format: #enven:<key>=<value>
  /// If no value is specified, the value is assumed to be true.
  EnvEntryAnnotation? parseAnnotation(String line) {
    if (!line.startsWith('#enven:')) {
      return null;
    }

    final parts = line.split(':');
    if (parts.length != 2) {
      return null;
    }

    final annotationPart = parts[1];
    final annotationParts = annotationPart.split('=');
    if (annotationParts.length == 1) {
      return EnvEntryAnnotation(
        key: annotationParts[0].trim(),
        value: true,
      );
    } else {
      return EnvEntryAnnotation(
        key: annotationParts[0].trim(),
        value: parseValue(annotationParts[1].trim(), null),
      );
    }
  }

  /// Parses the entry from the given [line].
  EnvEntry? parseEntry(
      String line, Map<String, EnvEntryAnnotation> annotations) {
    final parts = line.split('=');
    if (parts.length != 2) {
      return null;
    }

    return EnvEntry(
      annotations: annotations,
      key: parts[0].trim(),
      value: parseValue(parts[1].trim(),
          annotations[EnvEntryAnnotation.type]?.value as String?),
    );
  }

  /// Parses the value from the given [value] and [type].
  Object parseValue(String value, String? type) {
    if (type != null) {
      switch (type) {
        case 'bool':
          return value == 'true';
        case 'double':
          return double.parse(value);
        case 'int':
          return int.parse(value);
        case 'String':
          return value.split('#')[0].trim();
        default:
          throw Exception('Unknown type: $type');
      }
    }
    if (value == 'true') {
      return true;
    }

    if (value == 'false') {
      return false;
    }

    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }

    if (value.startsWith("'") && value.endsWith("'")) {
      return value.substring(1, value.length - 1);
    }

    final doubleMatch = _doubleRegex.firstMatch(value);
    if (doubleMatch != null) {
      return double.parse(value);
    }

    final intMatch = _intRegex.firstMatch(value);
    if (intMatch != null) {
      return int.parse(value);
    }

    return value.split('#')[0].trim();
  }
}
