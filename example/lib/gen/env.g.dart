/// Generated file. Do not edit.
///
/// To regenerate, run: `dart run enven`
class Env {
  /// Override this instance to mock the environment.
  /// Example: `Env.instance = MockEnvData();`
  static EnvData instance = EnvData();

  static String get apiEndpoint => instance.apiEndpoint;
  static String get apiKey => instance.apiKey;
}

class EnvData {
  final apiEndpoint = 'https://prod.example.com';

  // "my-prod-key"
  static const _apiKey = [53360, 40714, 8618, 13313, 8208, 52813, 4456, 26436, 43212, 33059, 16374];
  static const _apiKey$ = [53277, 40819, 8583, 13425, 8290, 52770, 4364, 26473, 43175, 33094, 16271];
  String get apiKey {
    return String.fromCharCodes([
      for (int i = 0; i < _apiKey.length; i++)
        _apiKey[i] ^ _apiKey$[i],
    ]);
  }
}
