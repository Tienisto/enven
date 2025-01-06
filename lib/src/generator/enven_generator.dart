import 'dart:math';

import 'package:enven/src/model/file.dart';
import 'package:enven/src/util/recase.dart';

class EnvenGenerator {
  const EnvenGenerator();

  /// Generates the content of the env.g.dart file.
  String generate(EnvFile env) {
    final buffer = StringBuffer();
    buffer.writeln('/// Generated file. Do not edit.');
    buffer.writeln('///');
    buffer.writeln('/// To regenerate, run: `dart run enven`');
    buffer.writeln('class Env {');
    buffer.writeln('  /// Override this instance to mock the environment.');
    buffer.writeln('  /// Example: `Env.instance = MockEnvData();`');
    buffer.writeln('  static EnvData instance = EnvData();');
    buffer.writeln();

    final entries = env.entries.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i].value;
      final key =
          (entry.annotations[EnvEntryAnnotation.name]?.value.toString() ??
                  entry.key)
              .toCamelCase();

      if (entry.annotations.hasConstAnnotation()) {
        if (entry.annotations.hasObfuscateAnnotation()) {
          throw Exception(
            'Cannot obfuscate a constant value. Key: ${entry.key}',
          );
        }
        buffer.writeln(
          '  static const ${entry.annotations.getTypeAnnotation() ?? entry.value.runtimeType} $key = ${_generateValue(entry.value)};',
        );
      } else {
        buffer.writeln(
          '  static ${entry.annotations.getTypeAnnotation() ?? entry.value.runtimeType} get $key => instance.$key;',
        );
      }
    }

    buffer.writeln('}');

    buffer.writeln();
    buffer.writeln('class EnvData {');
    final random = env.config.seed == null
        ? Random.secure()
        : Random(env.config.seed!.hashCode);
    bool first = true;
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i].value;

      if (entry.annotations.hasConstAnnotation()) {
        continue;
      }

      if (!first) {
        buffer.writeln();
      }

      final key =
          (entry.annotations[EnvEntryAnnotation.name]?.value.toString() ??
                  entry.key)
              .toCamelCase();
      final valueType = entry.annotations.getTypeAnnotation();

      if (entry.value != null && entry.annotations.hasObfuscateAnnotation()) {
        _generateObfuscatedEntry(buffer, random, key, valueType, entry.value);
      } else {
        buffer.writeln(
          '  final ${valueType ?? entry.value.runtimeType} $key = ${_generateValue(entry.value)};',
        );
      }
      first = false;
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateValue(Object? value) {
    if (value == null) {
      return 'null';
    } else if (value is String) {
      final multiline = value.contains('\n');
      final containsSingleQuote = value.contains("'");
      if (multiline) {
        return "'''$value'''";
      } else if (containsSingleQuote) {
        return '"$value"';
      } else {
        return "'$value'";
      }
    } else if (value is bool) {
      return value.toString();
    } else if (value is int) {
      return value.toString();
    } else if (value is double) {
      return value.toString();
    } else {
      throw Exception('Unsupported value type: ${value.runtimeType}');
    }
  }

  void _generateObfuscatedEntry(
    StringBuffer buffer,
    Random random,
    String key,
    String? valueType,
    Object? rawValue,
  ) {
    if (rawValue is String) {
      final value = rawValue.toString();
      final valueCodes = value.codeUnits;
      final randomCodes = List.generate(
        valueCodes.length,
        (index) => random.nextInt(1 << 16),
      );
      final obfuscatedValue = List.generate(
        valueCodes.length,
        (index) => valueCodes[index] ^ randomCodes[index],
      );

      buffer.writeln('  // "${value.replaceAll('\n', r'\n')}"');
      buffer.writeln('  static const _$key = $obfuscatedValue;');
      buffer.writeln('  static const _$key\$ = $randomCodes;');
      buffer.writeln('  ${valueType ?? rawValue.runtimeType} get $key {');
      buffer.writeln('    return String.fromCharCodes([');
      buffer.writeln('      for (int i = 0; i < _$key.length; i++)');
      buffer.writeln('        _$key[i] ^ _$key\$[i],');
      buffer.writeln('    ]);');
      buffer.writeln('  }');
    } else {
      throw Exception(
          'Only strings can be obfuscated. Found type: ${rawValue.runtimeType}');
    }
  }
}
