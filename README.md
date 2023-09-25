# enven

[![pub package](https://img.shields.io/pub/v/enven.svg)](https://pub.dev/packages/enven)
![ci](https://github.com/Tienisto/enven/actions/workflows/ci.yml/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Generate environment variables from a .env file at compile time with optional obfuscation.

## Motivation

Sometimes, it is necessary to have secrets embedded in your app to avoid your API being abused.

While [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) is great, it puts the environment variables in the assets folder in clear text which is too easy to reverse engineer.

The solution by [envied](https://pub.dev/packages/envied) requires you to write a verbose `env.dart` file which is not very DRY.

With enven, you just need to write a `.env` file and run `dart run enven` to generate a `env.g.dart` file.

## Getting Started

**Step 1: Add dependency**

```yaml
# pubspec.yaml
dev_dependencies:
  enven: <version>
  build_runner: <version> # OPTIONAL
```

**Step 2: Write a .env file in the project root directory.**

```bash
API_KEY=1234567890
API_ENDPOINT=https://example.com
```

**Step 3: Generate dart file**

```bash
dart run enven
```

If you just check out the project, you can also run `build_runner`.

Be careful because it only works once. (Subsequent runs won't notice changes.)

```bash
dart run build_runner build -d
```

**Step 4: Access**

```dart
import 'package:your_package/gen/env.g.dart';

int apiKey = Env.apiKey; // 1234567890
String apiEndpoint = Env.apiEndpoint; // https://example.com
```

## Configuration

Comments starting with `#enven:` are treated as configuration.

```bash
#enven:output=lib/gen/env.g.dart

#enven:obfuscate
#enven:type=String
API_KEY=1234567890

#enven:obfuscate
#enven:name=endpoint
API_ENDPOINT=https://example.com
```

| Key         | Applies to | Type                              | Usage                               | Default              |
|-------------|------------|-----------------------------------|-------------------------------------|----------------------|
| `output`    | file       | `String`                          | Specify output file path            | `lib/gen/env.g.dart` |
| `seed`      | file       | `String`                          | Specify seed for obfuscation        | (random)             |
| `obfuscate` | variable   | `boolean`                         | Obfuscate the environment variable. | `false`              |
| `type`      | variable   | `String`, `int`, `double`, `bool` | Specify exact type                  | (inferred)           |
| `name`      | variable   | `String`                          | Specify variable name               | (inferred)           |

## Overrides

You may want to have default values. In this case, you should commit `.env` to your repository.

For production, you can override the values by creating a `.env.prod` file.

```bash
# File: .env
API_KEY=abcdefg
API_ENDPOINT=https://dev.example.com
APP_NAME=My App
```

```bash
# File: .env.prod
API_KEY=my-secret-key
API_ENDPOINT=https://prod.example.com
```

```dart
// Production
String apiKey = Env.apiKey; // my-secret-key
String apiEndpoint = Env.apiEndpoint; // https://prod.example.com
String appName = Env.appName; // My App <-- from .env
```

Here is the precedence:

1. `.env.production`
2. `.env.prod`
3. `.env.development`
4. `.env.dev`
5. `.env`

## License

MIT License

Copyright (c) 2023 Tien Do Nam

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
