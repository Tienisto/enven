import 'dart:io';

import 'package:enven/src/generator/enven_generator.dart';
import 'package:enven/src/model/file.dart';
import 'package:enven/src/parser/env_parser.dart';
import 'package:enven/src/util/file_utils.dart';

void main() {
  final env = EnvParser().readFileSystem();
  printCandidates(env.candidates);

  final outputContent = EnvenGenerator().generate(env.content);

  // Create file and missing folders
  final outputPath = env.content.config.output ?? EnvenConfig.defaultOutput;
  FileUtils.createMissingFolders(filePath: outputPath);
  File(outputPath).writeAsStringSync(outputContent);

  print('Generated: $outputPath');
}

void printCandidates(List<String> candidates) {
  print(
    'Input: ${candidates.join(' < ')}${candidates.length > 1 ? ' (A overridden by B)' : ''}',
  );
}
