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

- [x] Handle errors in `translate()` and show a message instead of failing silently (shows a toast and clears the old translation; not yet checked on a device)
- [x] Check that a language is downloaded before translating (2026-11-17). Otherwise the plugin calls `downloadModelIfNeeded()` first: online it downloads silently over any connection, offline it never returns. Missing models now show a toast pointing to Offline Languages; not yet checked on a device
- [x] Stop `translate()` overwriting state changes made while it waits (if the text or a language changed meanwhile, the outcome is now dropped silently; covered by tests, hard to trigger by hand)

### Languages

- [x] Swap the text as well as the languages, because the old text was translated as the wrong language (with a translation, swap exchanges the texts and doesn't translate again; without one, it swaps languages only, and the swap button then translates in the new direction; not yet checked on a device)

### Action panels

- [x] Use a copy icon on the source panel's copy button (it showed the paste icon; not yet checked on a device)
- [x] Decide whether bookmarking should be allowed before a translation exists (decided 2026-11-17: keep as is; a bookmark can be saved without a translation)

### Offline Languages screen

- [x] Show progress while a language downloads (a spinner with Cancel, from both the row and the download icon, over any connection; ML Kit reports no real progress; not yet checked on a device)
- [x] Show a message when a download or delete fails (toasts for both; not yet checked on a device)
- [x] Confirm before deleting a language, and say so when it's the selected source or target (it stays selected; translating later offers the download; not yet checked on a device)
- [x] Rename "Recent Languages", or add real recent-language tracking (renamed to "Downloaded", which is what the section lists)
- [x] Fix the section headers when no languages are downloaded (most visible when searching, e.g. "afr" showed Afrikaans under the first header; headers are now decided per row; not yet checked on a device)
- [x] Hide the delete button for English (built into ML Kit; tapping it did nothing on a device, 2026-11-17). Hidden by the code `en`, not by anything ML Kit reports; not yet checked on a device
- [ ] Resolve the performance TODO in `offline.languages.view.dart`

## Phase 2: Dependable offline use

- [ ] First-run setup for choosing and downloading languages (`firstRun` is stored, but no setup screen uses it yet)
- [ ] Show the model size before download (roughly 30 MB per language)
- [ ] Add a Wi-Fi-only download option
- [ ] Mark which languages are ready to use offline
- [x] Offer a download when a selected language is missing (in the Translate From / To picker: asks, downloads over any connection behind a loader with Cancel, then selects it; not yet checked on a device)
- [x] Offer a download when translating with a missing language (home screen: send, paste and swap ask to download, then translate; covers deleted languages, first-run defaults and older saved settings; prompt, download and translate confirmed working on a device 2026-11-17; paste, swap, offline Cancel and the keyboard not separately confirmed)

## Phase 3: Everyday features

- [ ] Translation history
- [ ] Confirm when text is copied
- [ ] "Translate" option in Android's text-selection menu
- [ ] Accept text shared from other apps
- [x] Voice input as a draft dialog (2026-11-17): nothing is written to the source box until Insert; Try again discards the last phrase and waits for the mic; the mic adds phrases; readable errors; Insert appends and translates; the language is matched to a device speech locale. Not yet checked on a device
- [x] Android: use the Google speech dialog first (2026-11-18): the mic opens the system "Try saying something" screen in the app bar's source language; the text goes straight into the source box and translates. If the Google dialog fails (no network, nothing heard), without the Google app, and on iOS/web, the draft dialog above opens instead; closing the Google dialog does nothing. We ask it to finish after 2 s of silence (the Google app may ignore that). Confirmed working on a device 2026-11-18
- [x] Settings: a Theme tile (2026-11-18) showing the current theme; tapping it opens a dialog with Device theme, Light and Dark (tap applies and saves) and Cancel. New installs follow the device; themes saved before keep working. Confirmed working on a device 2026-11-18
- [x] Settings: a Keyboard tile (2026-11-18) with a checkbox for "Show the keyboard at startup", on by default (also for settings saved before). The home screen waits for the settings before focusing the source field; a change applies from the next start. Confirmed working on a device 2026-11-18
- [x] Settings: a Text size tile (2026-11-18) for the source and translation text only (14–32 in steps of 2, default 18; the rest of the app is unchanged). The dialog has a preview (the current source text, or a sample) and a wheel; tapping outside or Back applies, Cancel keeps the old size. Missing or invalid saved values load as 18. Confirmed working on a device 2026-11-18
  - Decision (2026-11-18): the app keeps ignoring the phone's own font size (`TextScaler.linear(1)` in `app.dart`), so system font scaling can't break the app bar, drawer or dialogs.
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
