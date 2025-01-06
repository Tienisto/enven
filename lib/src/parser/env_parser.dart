import 'dart:io';

import 'package:enven/src/model/enven_file.dart';
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

  const EnvParser({
    this.valueParser = const ValueParser(),
  });

  /// Parses the .env file from the file system.
  EnvFile readFileSystem() {
    return parseContentList(
      _envFiles
          .map((e) {
            final file = File(e);
            if (!file.existsSync()) {
              return null;
            }
            return file.readAsStringSync();
          })
          .where((element) => element != null)
          .cast<String>()
          .toList(),
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
    for (final line in lines) {
      if (line.startsWith('#')) {
        final annotation = parseAnnotation(line);
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
