import 'dart:io';

import 'package:enven/generator/enven_generator.dart';
import 'package:enven/model/enven_file.dart';
import 'package:enven/parser/env_parser.dart';
import 'package:enven/util/file_utils.dart';

void main() {
  final env = EnvParser().fromFileSystem();
  final outputContent = EnvenGenerator().generate(env);
  final outputPath = env.config.output ?? EnvenConfig.defaultOutput;
  FileUtils.createMissingFolders(filePath: outputPath);
  File(outputPath).writeAsStringSync(outputContent);
  print('Generated: $outputPath');
}
