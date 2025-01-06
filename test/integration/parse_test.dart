import 'package:enven/src/model/file.dart';
import 'package:enven/src/parser/env_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = EnvParser();

  test('Should parse empty string', () {
    final env = parser.parseContent('');
    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, isEmpty);
  });

  test('Should parse only output', () {
    final env = parser.parseContent('#enven:output=hi.dart');
    expect(env.config.output, 'hi.dart');
    expect(env.config.seed, isNull);
    expect(env.entries, isEmpty);
  });

  test('Should parse only seed', () {
    final env = parser.parseContent('#enven:seed=123');
    expect(env.config.output, isNull);
    expect(env.config.seed, '123');
    expect(env.entries, isEmpty);
  });

  test('Should parse single key-value', () {
    final env = parser.parseContent('aa=bb');
    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final e = env.entries['aa']!;
    expect(e.key, 'aa');
    expect(e.value, 'bb');
    expect(e.annotations, isEmpty);
  });

  test('Should parse single key-value with quotes', () {
    final env = parser.parseContent('aa="bb"');
    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final e = env.entries['aa']!;
    expect(e.key, 'aa');
    expect(e.value, 'bb');
    expect(e.annotations, isEmpty);
  });

  test('Should parse single key-value with annotation', () {
    final env = parser.parseContent('''
#enven:obfuscate
aa=bb
''');
    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final e = env.entries['aa']!;
    expect(e.key, 'aa');
    expect(e.value, 'bb');
    expect(e.annotations, hasLength(1));
    expect(e.annotations[EnvEntryAnnotation.obfuscate]!.value, true);
  });

  test('Should parse value with equals sign', () {
    final env = parser.parseContent('''aa=bb=cc''');
    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final e = env.entries['aa']!;
    expect(e.key, 'aa');
    expect(e.value, 'bb=cc');
    expect(e.annotations, isEmpty);
  });

  test('Should ignore ordinary comments', () {
    final env = parser.parseContent('''
#enven:obfuscate
# this is a comment
aa=bb
''');

    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final e = env.entries['aa']!;
    expect(e.key, 'aa');
    expect(e.value, 'bb');
    expect(e.annotations, hasLength(1));
    expect(e.annotations[EnvEntryAnnotation.obfuscate]!.value, true);
  });

  test('Should skip empty line during parsing', () {
    final env = parser.parseContent('''
#enven:obfuscate

aa=bb
''');
    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final e = env.entries['aa']!;
    expect(e.key, 'aa');
    expect(e.value, 'bb');
    expect(e.annotations, hasLength(1));
    expect(e.annotations[EnvEntryAnnotation.obfuscate]!.value, true);
  });

  test('Should parse multiline string', () {
    final env = parser.parseContent('''
#enven:obfuscate
aa="hello
world" # some comment
''');

    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final e = env.entries['aa']!;
    expect(e.key, 'aa');
    expect(e.value, 'hello\nworld');
    expect(e.annotations[EnvEntryAnnotation.obfuscate]!.value, true);
  });

  test('Should parse CRLF', () {
    final env = parser.parseContent('''
#enven:obfuscate\r\naa=1\r\nbb="hello\r\nworld" # some comment\r\ncc=hello
''');

    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(3));

    final a = env.entries['aa']!;
    expect(a.key, 'aa');
    expect(a.value, 1);
    expect(a.annotations[EnvEntryAnnotation.obfuscate]!.value, true);

    final b = env.entries['bb']!;
    expect(b.key, 'bb');
    expect(b.value, 'hello\nworld');
    expect(b.annotations, isEmpty);

    final c = env.entries['cc']!;
    expect(c.key, 'cc');
    expect(c.value, 'hello');
    expect(c.annotations, isEmpty);
  });

  test('Should parse multiple key-value', () {
    final env = parser.parseContent('''
aa=bb
cc=dd
''');

    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(2));

    final aa = env.entries['aa']!;
    expect(aa.key, 'aa');
    expect(aa.value, 'bb');
    expect(aa.annotations, isEmpty);

    final cc = env.entries['cc']!;
    expect(cc.key, 'cc');
    expect(cc.value, 'dd');
    expect(cc.annotations, isEmpty);
  });

  test('Should parse multiple key-value with annotation', () {
    final env = parser.parseContent('''
#enven:obfuscate
aa=bb

#enven:type=String
cc=123
''');

    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(2));

    final aa = env.entries['aa']!;
    expect(aa.key, 'aa');
    expect(aa.value, 'bb');
    expect(aa.annotations, hasLength(1));
    expect(aa.annotations[EnvEntryAnnotation.obfuscate]!.value, true);

    final cc = env.entries['cc']!;
    expect(cc.key, 'cc');
    expect(cc.value, '123');
    expect(cc.annotations, hasLength(1));
    expect(cc.annotations[EnvEntryAnnotation.type]!.value, 'String');
  });

  test('Should respect base type hint', () {
    final env = parser.parseContentList([
      '''
#enven:type=String?
aa=hello  
''',
      '''
aa=123
''',
    ]);

    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final aa = env.entries['aa']!;
    expect(aa.key, 'aa');
    expect(aa.value, '123');
    expect(aa.annotations, hasLength(1));
    expect(aa.annotations[EnvEntryAnnotation.type]!.value, 'String?');
  });
}
