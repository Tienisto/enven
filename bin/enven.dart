import 'dart:io';

import 'package:enven/src/generator/enven_generator.dart';
import 'package:enven/src/model/enven_file.dart';
import 'package:enven/src/parser/env_parser.dart';
import 'package:enven/src/util/file_utils.dart';

void main() {
  final env = EnvParser().readFileSystem();
  final outputContent = EnvenGenerator().generate(env);
  final outputPath = env.config.output ?? EnvenConfig.defaultOutput;
  FileUtils.createMissingFolders(filePath: outputPath);
  File(outputPath).writeAsStringSync(outputContent);
  print('Generated: $outputPath');
}
