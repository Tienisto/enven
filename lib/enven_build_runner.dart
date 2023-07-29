import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:enven/generator/enven_generator.dart';
import 'package:enven/model/enven_file.dart';
import 'package:enven/parser/env_parser.dart';
import 'package:enven/util/file_utils.dart';

/// Static entry point for build_runner
Builder envBuilder(BuilderOptions options) {
  return EnvBuilder();
}

class EnvBuilder implements Builder {
  bool _generated = false;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // only generate once
    if (_generated) return;

    _generated = true;

    final env = EnvParser().fromFileSystem();
    final outputContent = EnvenGenerator().generate(env);
    final outputPath = env.config.output ?? EnvenConfig.defaultOutput;
    FileUtils.createMissingFolders(filePath: outputPath);
    File(outputPath).writeAsStringSync(outputContent);
  }

  @override
  get buildExtensions => {
        r'$lib$': ['.g.dart'],
      };
}
