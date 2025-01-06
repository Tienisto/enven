import 'package:enven/src/parser/multiline_string_parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  const parser = MultilineStringParser();

  test('Should parse multiline string', () {
    final value = parser.start('MY_KEY="hello')!;
    expect(value.key, 'MY_KEY');
    expect(value.convertToSingleLine(), 'MY_KEY="hello"');
    expect(value.isFinished, false);

    parser.append(value, ' nice');
    expect(value.convertToSingleLine(), 'MY_KEY="hello\n nice"');
    expect(value.isFinished, false);

    parser.append(value, ' world"');
    expect(value.convertToSingleLine(), 'MY_KEY="hello\n nice\n world"');
    expect(value.isFinished, true);
  });
}
