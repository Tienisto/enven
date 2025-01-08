## 1.2.1

- style: format code
- docs: update README

## 1.2.0

- feat: print detected environment files
- fix: parse CRLF encoded environment files

## 1.1.0

- feat: handle multiline strings that start with a quote (`'` or `"`)
- fix: correctly type values as bool, int, or double if they contain a comment (e.g. `VAR=1 # comment`)

## 1.0.1

- fix: parse values with equals sign

## 1.0.0

- mark as stable

## 0.3.0

- feat: make variables mockable
- feat: add `#enven:const` annotation to generate as `const` variables
- feat: support nullable types (e.g. `#enven:type=String?`)

## 0.2.0

- feat: add `#enven:seed=<seed>` for consistent obfuscation

## 0.1.0

- Initial version.
