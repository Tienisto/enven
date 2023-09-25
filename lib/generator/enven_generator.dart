import 'dart:math';

import 'package:enven/model/enven_file.dart';
import 'package:enven/util/recase.dart';

class EnvenGenerator {
  const EnvenGenerator();

  /// Generates the content of the env.g.dart file.
  String generate(EnvFile env) {
    final buffer = StringBuffer();
    buffer.writeln('/// Generated file. Do not edit.');
    buffer.writeln('///');
    buffer.writeln('/// To regenerate, run: `dart run enven`');
    buffer.writeln();
    buffer.writeln('class Env {');

    final random = env.config.seed == null
        ? Random.secure()
        : Random(env.config.seed!.hashCode);

    final entries = env.entries.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i].value;
      if (i != 0) {
        buffer.writeln();
      }

      final key =
          (entry.annotations[EnvEntryAnnotation.name]?.value.toString() ??
                  entry.key)
              .toCamelCase();

      if (entry.annotations[EnvEntryAnnotation.obfuscate]?.value == true) {
        _generateObfuscatedEntry(buffer, random, key, entry.value);
      } else {
        buffer.writeln('  static const $key = ${_generateValue(entry.value)};');
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateValue(Object value) {
    if (value is String) {
      return "'$value'";
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
    Object rawValue,
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

      buffer.writeln('  // "$value"');
      buffer.writeln('  static const _$key = $obfuscatedValue;');
      buffer.writeln('  static const _$key\$ = $randomCodes;');
      buffer.writeln('  static ${rawValue.runtimeType} get $key {');
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
