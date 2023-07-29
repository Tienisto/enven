import 'package:enven/parser/env_parser.dart';
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
  });

  group('parseValue', () {
    test('Should parse a boolean', () {
      expect(parser.parseValue('true', null), true);
      expect(parser.parseValue('false', null), false);
    });

    test('Should parse a string', () {
      expect(parser.parseValue('hello', null), 'hello');
    });

    test('Should parse an int', () {
      expect(parser.parseValue('123', null), 123);
    });

    test('Should parse a double', () {
      expect(parser.parseValue('123.456', null), 123.456);
    });

    test('Should parse a string with double quotes', () {
      expect(parser.parseValue('"hello"', null), 'hello');
    });

    test('Should parse a string with single quotes', () {
      expect(parser.parseValue("'hello'", null), 'hello');
    });

    test('Should parse a string with double quotes and spaces', () {
      expect(parser.parseValue('"hello world"', null), 'hello world');
    });

    test('Should parse a string ignoring comments', () {
      expect(parser.parseValue('hello #world', null), 'hello');
    });

    test('Should parse an string with type hint', () {
      expect(parser.parseValue('123', 'String'), '123');
    });
  });
}
