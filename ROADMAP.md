# Go Translator Roadmap

Tracks progress and proposed features for Go Translator, an offline translator app built with Flutter and ML Kit.

Last updated: 2026-11-05

**Status key:** `[ ]` to do, `[~]` in progress, `[x]` done

## Current status

- Packages resolve, and `flutter analyze` reports 0 errors.
- The debug APK builds.
- Not yet checked: running the app on a device, and a release build.

## Done

### Toolchain upgrade (2026-11-05)

- [x] Fix the dependency conflict between the Isar and Riverpod generators
- [x] Update `isar_community` and its generator to 3.4.1
- [x] Update `flutter_riverpod` to ^3.4.3, `riverpod_annotation` to ^4.0.7 and `riverpod_generator` to ^4.0.9
- [x] Remove `custom_lint`, which conflicts with the analyzer version `riverpod_generator` needs
- [x] Regenerate the `*.g.dart` files
- [x] Update Gradle to 8.14, AGP to 8.11.1 and Kotlin to 2.2.20

## Next up: verify the upgrade

- [ ] Run the app on a device
- [ ] Confirm the saved language choice survives the upgrade
- [ ] Run a release build
- [ ] Commit the upgrade

## Phase 1: Bug fixes

### Translation

- [ ] Handle translation errors and show a message instead of failing silently
- [ ] Stop models downloading silently during translation, with no progress or Wi-Fi check
- [ ] Reuse `OnDeviceTranslator` instead of creating one on every state change
- [ ] Close translators when they are no longer needed

### Languages

- [ ] Fix `setTargetLanguage`, which compares against the target instead of the source
- [ ] Prevent source and target from being the same language
- [ ] Swap the text as well as the languages when the user presses swap

### Speech

- [ ] Use the correct speech language for the source and target panels

### Offline Languages screen

- [ ] Refresh the list after a download or delete
- [ ] Show progress while a language downloads
- [ ] Stop rows on this screen from changing the source language and closing it
- [ ] Rename "Recent Languages", or add real recent-language tracking
- [ ] Fix the section headers when no languages are downloaded
- [ ] Resolve the performance TODO in `offline.languages.view.dart`

## Phase 2: Dependable offline use

- [ ] First-run setup for choosing and downloading languages
- [ ] Show the model size before download (roughly 30 MB per language)
- [ ] Add a Wi-Fi-only download option
- [ ] Mark which languages are ready to use offline
- [ ] Offer a download when a selected language is missing

## Phase 3: Everyday features

- [ ] Translation history
- [ ] Favourites (connect the disabled bookmark buttons)
- [ ] Share translations (connect the disabled share button)
- [ ] Confirm when text is copied
- [ ] "Translate" option in Android's text-selection menu
- [ ] Accept text shared from other apps
- [ ] Voice input (connect the mic button; offline support depends on the device's speech packs)
- [ ] Check right-to-left display for Arabic, Hebrew and Urdu

## Phase 4: Standout features

- [ ] Camera translation (ML Kit text recognition doesn't support every script, including Arabic)
- [ ] Automatic language detection
- [ ] Conversation mode
- [ ] Phrasebook grouped by situation

## Before publishing

- [ ] Replace the `com.example.translator` package name
- [ ] Add a release signing key
- [ ] Check ML Kit's attribution requirements
- [ ] Tell users that on-device translation is less accurate than cloud services
- [ ] Replace the default app description in `pubspec.yaml`

## Maintenance

- [ ] Plan the upgrade to Gradle 9.1+ and AGP 9.0.1+, because Flutter will soon drop support for the current versions
- [ ] Stop tracking `android/build/reports/problems/problems-report.html` in git
- [ ] Remove the `MyApp2`, `InheritedNose` and `HelloWidget` experiments if they are no longer needed
- [ ] Keep the project and pub cache on the same drive if Kotlin builds stay slow
