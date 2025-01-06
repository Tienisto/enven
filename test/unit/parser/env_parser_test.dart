import 'package:enven/src/parser/env_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = EnvParser();

  group('parseAnnotation', () {
    test('Should parse implicit boolean annotation', () {
      final annotation = parser.parseAnnotation('#enven:hello');
      expect(annotation, isNotNull);
      expect(annotation!.key, 'hello');
      expect(annotation.value, true);
    });

    test('Should parse explicit boolean annotation', () {
      final annotation = parser.parseAnnotation('#enven:hello=false');
      expect(annotation, isNotNull);
      expect(annotation!.key, 'hello');
      expect(annotation.value, false);
    });

    test('Should parse string annotation', () {
      final annotation = parser.parseAnnotation('#enven:hello=world');
      expect(annotation, isNotNull);
      expect(annotation!.key, 'hello');
      expect(annotation.value, 'world');
    });
  });

  group('parseEntry', () {
    test('Should parse a boolean', () {
      final entry = parser.parseEntry('key=true', {});
      expect(entry, isNotNull);
      expect(entry!.key, 'key');
      expect(entry.value, true);
    });

    test('Should return null if entry is invalid', () {
      final entry = parser.parseEntry('key', {});
      expect(entry, isNull);
    });

    test('Should parse with equals sign', () {
      final entry = parser.parseEntry('key=hello=world', {});
      expect(entry, isNotNull);
      expect(entry!.key, 'key');
      expect(entry.value, 'hello=world');
    });

    test('Should parse 2 consecutive equals sign', () {
      final entry = parser.parseEntry('key=hello==world', {});
      expect(entry, isNotNull);
      expect(entry!.key, 'key');
      expect(entry.value, 'hello==world');
    });

    test('Should parse ending with equals sign', () {
      final entry = parser.parseEntry('key=hello=', {});
      expect(entry, isNotNull);
      expect(entry!.key, 'key');
      expect(entry.value, 'hello=');
    });
  });
}
