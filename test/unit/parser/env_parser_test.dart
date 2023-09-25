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
      expect(parser.parseValue(value: 'true'), true);
      expect(parser.parseValue(value: 'false'), false);
    });

    test('Should parse a string', () {
      expect(parser.parseValue(value: 'hello'), 'hello');
    });

    test('Should parse an int', () {
      expect(parser.parseValue(value: '123'), 123);
    });

    test('Should parse a double', () {
      expect(parser.parseValue(value: '123.456'), 123.456);
    });

    test('Should parse a string with double quotes', () {
      expect(parser.parseValue(value: '"hello"'), 'hello');
    });

    test('Should parse a string with single quotes', () {
      expect(parser.parseValue(value: "'hello'"), 'hello');
    });

    test('Should parse a string with double quotes and spaces', () {
      expect(parser.parseValue(value: '"hello world"'), 'hello world');
    });

    test('Should parse a string ignoring comments', () {
      expect(parser.parseValue(value: 'hello #world'), 'hello');
    });

    test('Should parse an string with type hint', () {
      expect(parser.parseValue(value: '123', type: 'String'), '123');
    });
  });
}
