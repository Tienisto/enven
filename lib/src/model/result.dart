import 'package:enven/src/model/file.dart';

class EnvResult {
  /// The list of .env file candidates.
  /// From lowest to highest priority.
  final List<String> candidates;

  /// The parsed .env file.
  final EnvFile content;

  EnvResult({
    required this.candidates,
    required this.content,
  });
}
