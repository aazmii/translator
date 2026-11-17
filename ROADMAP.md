# Go Translator Roadmap

Tracks progress and proposed features for Go Translator, an offline translator app built with Flutter and ML Kit.

Last updated: 2026-11-05

**Status key:** `[ ]` to do, `[~]` in progress, `[x]` done

## Current status

- `dev` includes merge commit `da0b2a6` and matches `origin/dev`.
- `flutter analyze` reports 0 errors and 1 warning (the unused `nose` variable).
- All 10 tests pass.
- A release APK was built just before the merge commit.
- Not yet checked: running the merged app on a device.

## Done

### Toolchain upgrade (2026-11-05)

- [x] Fix the dependency conflict that stopped packages resolving
- [x] Update `flutter_riverpod` to ^3.4.3, `riverpod_annotation` to ^4.0.7 and `riverpod_generator` to ^4.0.9
- [x] Remove `custom_lint`, which conflicts with the analyzer version `riverpod_generator` needs
- [x] Update Gradle to 8.14, AGP to 8.11.1 and Kotlin to 2.2.20

### Merged from `origin/dev` (2026-11-05)

These are in the code, but haven't been tested on a device since the merge.

- [x] Replace Isar with Hive for local storage
- [x] Move to a clean-architecture structure, with tests for the dependency rules
- [x] Bookmarks: save from the source panel, then view and delete them in a Bookmarks screen
- [x] Share translations
- [x] Voice input screen (online only for now, see Phase 3)
- [x] App icon

### Bugs fixed by the merge

- [x] Close each translator after use, and stop creating one on every state change
- [x] Swap languages instead of allowing the same source and target
- [x] Use the correct speech language for the source and target panels
- [x] Refresh the Offline Languages list after a download or delete
- [x] Stop rows on the Offline Languages screen from changing the source language

## Next up: verify the merge

- [ ] Run the app on a device
- [ ] Test bookmarks, share, speech and language downloads
- [ ] Confirm the app handles the move to Hive cleanly (there is no Isar migration, so saved settings and languages reset once)

## Phase 1: Bug fixes

### Translation

- [ ] Handle errors in `translate()` and show a message instead of failing silently
- [ ] Stop `translate()` overwriting state changes made while it waits (it applies the result to the state it read before the call, so a swap or edit during translation is lost)
- [ ] Check that a language is downloaded before translating, because the plugin otherwise downloads it silently, with no progress or Wi-Fi check

### Languages

- [x] Swap the text as well as the languages, because the old text was translated as the wrong language (with a translation, swap exchanges the texts and doesn't translate again; without one, it swaps languages only; not yet checked on a device)

### Action panels

- [x] Use a copy icon on the source panel's copy button (it showed the paste icon; not yet checked on a device)
- [ ] Decide whether bookmarking should be allowed before a translation exists

### Offline Languages screen

- [ ] Show progress while a language downloads
- [ ] Show a message when a download or delete fails
- [ ] Rename "Recent Languages", or add real recent-language tracking
- [ ] Fix the section headers when no languages are downloaded
- [ ] Resolve the performance TODO in `offline.languages.view.dart`

## Phase 2: Dependable offline use

- [ ] First-run setup for choosing and downloading languages (`firstRun` is stored, but no setup screen uses it yet)
- [ ] Show the model size before download (roughly 30 MB per language)
- [ ] Add a Wi-Fi-only download option
- [ ] Mark which languages are ready to use offline
- [ ] Offer a download when a selected language is missing

## Phase 3: Everyday features

- [ ] Translation history
- [ ] Confirm when text is copied
- [ ] "Translate" option in Android's text-selection menu
- [ ] Accept text shared from other apps
- [ ] Offline voice input (`onDevice` is currently `false`; offline support also depends on the device's speech packs)
- [ ] Right-to-left display for Arabic, Hebrew and Urdu (the text fields don't set a direction yet)

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
- [ ] Decide whether to restore `flutter_lints`, which the merge removed from the project
- [ ] Stop tracking `android/build/reports/problems/problems-report.html` in git
- [ ] Remove the `MyApp2`, `InheritedNose` and `HelloWidget` experiments if they are no longer needed
- [ ] Delete `meaning.display.widget.dart`: nothing uses its `TranslationDisplayWidget`
- [ ] Keep the project and pub cache on the same drive if Kotlin builds stay slow
