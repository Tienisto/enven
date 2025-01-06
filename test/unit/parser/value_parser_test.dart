import 'package:enven/src/parser/value_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = ValueParser();

  group('parseValue', () {
    test('Should parse a boolean', () {
      expect(parser.parseValue(value: 'true'), true);
      expect(parser.parseValue(value: 'false'), false);
    });

    test('Should parse a boolean ignoring comments', () {
      expect(parser.parseValue(value: 'true # false'), true);
      expect(parser.parseValue(value: 'true#false'), true);
      expect(parser.parseValue(value: 'false # true'), false);
    });

    test('Should parse an int', () {
      expect(parser.parseValue(value: '123'), 123);
    });

    test('Should parse an int ignoring comments', () {
      expect(parser.parseValue(value: '123 #456'), 123);
    });

    test('Should parse a double', () {
      expect(parser.parseValue(value: '123.456'), 123.456);
    });

    test('Should parse a double ignoring comments', () {
      expect(parser.parseValue(value: '123.456 #789'), 123.456);
    });

    test('Should parse a string', () {
      expect(parser.parseValue(value: 'hello'), 'hello');
    });

    test('Should parse a string ignoring comments', () {
      expect(parser.parseValue(value: 'hello #world'), 'hello');
    });

    test('Should parse a string with double quotes', () {
      expect(parser.parseValue(value: '"hello"'), 'hello');
    });

    test('Should parse a string with double quotes and comments', () {
      expect(parser.parseValue(value: '"hello" #world'), 'hello');
    });

    test('Should parse a string with single quotes', () {
      expect(parser.parseValue(value: "'hello'"), 'hello');
    });

    test('Should parse a string with single quotes and comments', () {
      expect(parser.parseValue(value: "'hello' #world"), 'hello');
    });

    test('Should parse a string with double quotes and spaces', () {
      expect(parser.parseValue(value: '"hello world"'), 'hello world');
    });

    test('Should parse a string with type hint', () {
      expect(parser.parseValue(value: '123', type: 'String'), '123');
    });

    test('Should parse a string with a nullable hint', () {
      expect(parser.parseValue(value: 'null', type: 'String?'), null);
      expect(parser.parseValue(value: '123', type: 'String?'), '123');
    });

    test('Should parse a string with a nullable hint and comment', () {
      expect(parser.parseValue(value: 'null #comment', type: 'String?'), null);
    });
  });
}
