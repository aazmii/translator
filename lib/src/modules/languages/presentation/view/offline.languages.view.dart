import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/components/expandabe.search.app.bar.dart';
import 'package:go_translator/src/modules/languages/presentation/components/language.download.dialogs.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

class OfflineLanguagesView extends ConsumerStatefulWidget {
  const OfflineLanguagesView({super.key, required this.title, this.selectionMode = false});

  final String title;
  final bool selectionMode;

  @override
  ConsumerState<OfflineLanguagesView> createState() => _OfflineLanguagesViewState();
}

/// ML Kit's built-in model, which can't be deleted.
const _builtInLanguageCode = 'en';

class _OfflineLanguagesViewState extends ConsumerState<OfflineLanguagesView> {
  String? searchText = '';

  /// Selection mode: returns a downloaded language straight away. A missing
  /// one is offered for download first, and returned once it's downloaded.
  Future<void> _onLanguageTapped(Language language) async {
    if (language.isDownloaded) {
      Navigator.pop(context, language.code);
      return;
    }
    if (!await confirmLanguageDownload(context, [language]) || !mounted) return;

    final result = await downloadLanguagesWithLoader(context, ref, [language]);
    if (!mounted) return;
    switch (result) {
      case LanguageDownloadResult.done:
        Navigator.pop(context, language.code);
      case LanguageDownloadResult.failed:
        showLanguageDownloadFailed([language]);
      case LanguageDownloadResult.cancelled:
        break;
    }
  }

  /// Delete for a downloaded language, download for a missing one. English
  /// gets none: it's built into ML Kit, and deleting it did nothing when
  /// tried on a device (2026-11-17).
  Widget? _trailing(Language language) {
    if (language.code == _builtInLanguageCode) return null;
    return IconButton(
      icon: Icon(language.isDownloaded ? Icons.delete : Icons.download),
      onPressed: () => _onTrailingTapped(language),
    );
  }

  /// Trailing icon: deletes a downloaded language, or downloads a missing one
  /// behind the loader without asking. Never selects the language.
  Future<void> _onTrailingTapped(Language language) async {
    final notifier = ref.read(offlineLanguagesProvider.notifier);
    if (language.isDownloaded) {
      notifier.deleteLanguage(language.code);
      return;
    }
    final result = await downloadLanguagesWithLoader(context, ref, [language]);
    if (mounted && result == LanguageDownloadResult.failed) showLanguageDownloadFailed([language]);
  }

  /// One language row, with a section [header] above it when given.
  Widget _languageTile(Language language, String? header) {
    final tile = ListTile(
      onTap: widget.selectionMode ? () => _onLanguageTapped(language) : null,
      title: Text(language.name.capitalize),
      trailing: _trailing(language),
    );
    if (header == null) return tile;
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text(header, style: TextStyle(color: context.theme.colorScheme.primary)),
        tile,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: optimize, it's causing spike
    final languages = ref
        .watch(offlineLanguagesProvider)
        .value
        ?.where((l) => l.name.toLowerCase().contains(searchText!.toLowerCase()))
        .toList();
    // final languages = ref.watch(offlineLanguagesProvider).value;
    if (languages == null) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: ExpandableSearchAppBar(
        title: widget.title,
        onChanged: (value) {
          setState(() => searchText = value);
          // _controller.text = value;
        },
        hintText: '${widget.title}...',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: languages.length,
          itemBuilder: (context, i) {
            // The list is downloaded-first, so each section starts at its
            // first language. Decided per row, so a list with no downloaded
            // languages (e.g. while searching) gets only "Other Languages".
            final language = languages[i];
            final previous = i == 0 ? null : languages[i - 1];
            final String? header;
            if (language.isDownloaded) {
              header = previous == null ? 'Downloaded' : null;
            } else {
              header = previous == null || previous.isDownloaded ? 'Other Languages' : null;
            }
            return _languageTile(language, header);
          },
        ),
      ),
    );
  }
}
