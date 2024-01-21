import 'package:enven/src/model/enven_file.dart';
import 'package:enven/src/parser/env_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = EnvParser();

  test('Should parse empty string', () {
    final env = parser.parse('');
    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, isEmpty);
  });

  test('Should parse only output', () {
    final env = parser.parse('#enven:output=hi.dart');
    expect(env.config.output, 'hi.dart');
    expect(env.config.seed, isNull);
    expect(env.entries, isEmpty);
  });

  test('Should parse only seed', () {
    final env = parser.parse('#enven:seed=123');
    expect(env.config.output, isNull);
    expect(env.config.seed, '123');
    expect(env.entries, isEmpty);
  });

  test('Should parse single key-value', () {
    final env = parser.parse('aa=bb');
    expect(env.config.output, isNull);
    expect(env.config.seed, isNull);
    expect(env.entries, hasLength(1));

    final e = env.entries['aa']!;
    expect(e.key, 'aa');
    expect(e.value, 'bb');
    expect(e.annotations, isEmpty);
  });

  test('Should parse single key-value with annotation', () {
    final env = parser.parse('''
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

  test('Should ignore ordinary comments', () {
    final env = parser.parse('''
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
    final env = parser.parse('''
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

  test('Should parse multiple key-value', () {
    final env = parser.parse('''
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
    final env = parser.parse('''
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
}
