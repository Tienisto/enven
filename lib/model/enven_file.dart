/// Represents a .env file.
class EnvFile {
  /// Global configuration specified in the .env file.
  final EnvenConfig config;

  /// All entries in the .env file.
  final Map<String, EnvEntry> entries;

  EnvFile({
    required this.config,
    required this.entries,
  });

  /// Merges this [EnvFile] with the given [fallback].
  EnvFile withFallback(EnvFile fallback) {
    final mergedEntries = <String, EnvEntry>{...fallback.entries};
    for (final entry in entries.entries) {
      if (mergedEntries.containsKey(entry.key)) {
        // fallback exists, merge annotations
        mergedEntries[entry.key] =
            entry.value.withFallback(mergedEntries[entry.key]!);
      } else {
        // no fallback, just add
        mergedEntries[entry.key] = entry.value;
      }
    }
    return EnvFile(
      config: EnvenConfig(
        output: config.output ?? fallback.config.output,
      ),
      entries: mergedEntries,
    );
  }
}

/// Global configuration specified in a .env file.
class EnvenConfig {
  static const defaultOutput = 'lib/gen/env.g.dart';

  /// The output file path.
  final String? output;

  EnvenConfig({
    required this.output,
  });
}

/// Represents a single entry in a .env file.
class EnvEntry {
  /// Annotations for this entry.
  final Map<String, EnvEntryAnnotation> annotations;

  final String key;
  final Object value;

  EnvEntry({
    required this.annotations,
    required this.key,
    required this.value,
  });

  /// Merges this [EnvEntry] with the given [fallback].
  /// We only merge annotations, not the key or value.
  EnvEntry withFallback(EnvEntry fallback) {
    return EnvEntry(
      annotations: {
        ...fallback.annotations,
        ...annotations,
      },
      key: key,
      value: value,
    );
  }
}

/// Represents a single annotation for a .env entry.
class EnvEntryAnnotation {
  static const obfuscate = 'obfuscate';
  static const type = 'type';
  static const name = 'name';

  final String key;
  final Object value;

  EnvEntryAnnotation({
    required this.key,
    required this.value,
  });
}
