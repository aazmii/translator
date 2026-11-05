# Architecture

This application uses feature-first Clean Architecture.

## Dependency rule

Dependencies point inward:

```text
presentation -> domain <- data
                     ^
                     |
             config/di (composition root)
```

- `domain` is pure Dart. It owns entities, repository contracts, and use cases.
- `data` implements domain repository contracts and contains models and data
  sources for Hive, ML Kit, and other external services.
- `presentation` contains Flutter views and Riverpod controllers. Controllers
  invoke use cases; they do not construct or import data implementations.
- `config/di/providers.dart` is the only composition root. It wires concrete
  data implementations to domain contracts and exposes use cases to Riverpod.
- `core` contains only feature-independent utilities and abstractions.

These rules are enforced by `test/architecture/dependency_rule_test.dart`.

## Source layout

```text
lib/
|-- main.dart
`-- src/
    |-- app.dart
    |-- config/
    |   |-- di/
    |   |   `-- providers.dart
    |   |-- localization/
    |   `-- router/
    |-- core/
    |   |-- constants.dart
    |   |-- db/
    |   |-- extensions/
    |   |-- usecase.dart
    |   `-- utils/
    |-- modules/
    |   |-- bookmarks/
    |   |   |-- data/
    |   |   |-- domain/
    |   |   `-- presentation/
    |   |-- home/
    |   |   |-- data/
    |   |   |-- domain/
    |   |   `-- presentation/
    |   |-- languages/
    |   |   |-- data/
    |   |   |-- domain/
    |   |   `-- presentation/
    |   `-- setting/
    |       |-- data/
    |       |-- domain/
    |       `-- presentation/
    `-- theme/
```

## Adding a feature

1. Define entities, repository contracts, and use cases in `domain`.
2. Add external-service and persistence adapters in `data`.
3. Implement views and controllers in `presentation` using only domain types
   and use cases.
4. Wire the feature in the composition root.
5. Add domain unit tests and keep the architecture tests passing.
