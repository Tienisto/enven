import 'dart:io';

import 'package:enven/src/model/file.dart';
import 'package:enven/src/model/result.dart';
import 'package:enven/src/parser/multiline_string_parser.dart';
import 'package:enven/src/parser/value_parser.dart';

const _envFiles = [
  '.env',
  '.env.dev',
  '.env.development',
  '.env.prod',
  '.env.production',
];

class EnvParser {
  final ValueParser valueParser;
  final MultilineStringParser multilineStringParser;

  const EnvParser({
    this.valueParser = const ValueParser(),
    this.multilineStringParser = const MultilineStringParser(),
  });

  /// Parses the .env file from the file system.
  EnvResult readFileSystem() {
    final candidates = <String>[];
    final contents = <String>[];
    for (int i = 0; i < _envFiles.length; i++) {
      final file = File(_envFiles[i]);
      if (file.existsSync()) {
        candidates.add(_envFiles[i]);
        contents.add(file.readAsStringSync());
      }
    }

    return EnvResult(
      candidates: candidates,
      content: parseContentList(contents),
    );
  }

  EnvFile parseContentList(List<String> files) {
    if (files.isEmpty) {
      throw Exception('No .env file found');
    }

    EnvFile? curr;
    for (final content in files) {
      final parsed = parseContent(content);
      if (curr != null) {
        curr = parsed.withFallback(curr, this);
      } else {
        curr = parsed;
      }
    }

    return curr!;
  }

  /// Parses the .env file from the given [content].
  EnvFile parseContent(String content) {
    final lines = content.split('\n');

    // file config
    String? output;
    String? seed;

    final entries = <String, EnvEntry>{};
    Map<String, EnvEntryAnnotation> annotationCache = {};
    MultilineValue? multilineValue;
    for (final line in lines) {
      if (multilineValue == null) {
        multilineValue = multilineStringParser.start(line);
        if (multilineValue != null) {
          continue;
        }
      } else {
        multilineStringParser.append(multilineValue, line);
        if (!multilineValue.isFinished) {
          continue;
        }
      }

      final rawValue = multilineValue?.convertToSingleLine() ?? line;

      if (multilineValue == null && rawValue.startsWith('#')) {
        final annotation = parseAnnotation(rawValue);
        if (annotation != null) {
          switch (annotation.key) {
            case EnvEntryAnnotation.output:
              output = annotation.value.toString();
              break;
            case EnvEntryAnnotation.seed:
              seed = annotation.value.toString();
              break;
            default:
              annotationCache[annotation.key] = annotation;
          }
        }
      } else {
        final entry = parseEntry(rawValue, annotationCache);
        if (entry != null) {
          entries[entry.key] = entry;
          annotationCache = {};
          multilineValue = null;
        }
      }
    }

    return EnvFile(
      config: EnvenConfig(
        output: output,
        seed: seed,
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
        value: valueParser.parseValue(value: annotationParts[1].trim())!,
      );
    }
  }

  /// Parses the entry from the given [line].
  EnvEntry? parseEntry(
    String line,
    Map<String, EnvEntryAnnotation> annotations,
  ) {
    final parts = line.split('=');
    if (parts.length < 2) {
      return null;
    }

    return EnvEntry(
      annotations: annotations,
      key: parts[0].trim(),
      value: valueParser.parseValue(
        value: parts.sublist(1).join('=').trim(),
        type: annotations.getTypeAnnotation(),
      ),
    );
  }
}
