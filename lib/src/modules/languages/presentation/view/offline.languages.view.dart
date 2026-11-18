import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/components/language.card.dart';
import 'package:go_translator/src/modules/languages/presentation/components/language.download.dialogs.dart';
import 'package:go_translator/src/modules/languages/presentation/components/language.native.names.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

class OfflineLanguagesView extends ConsumerStatefulWidget {
  const OfflineLanguagesView({
    super.key,
    required this.title,
    this.selectionMode = false,
    this.sourceLanguageCode,
    this.targetLanguageCode,
  });

  final String title;
  final bool selectionMode;

  /// The languages selected on the home screen, so deleting one can say so.
  /// Passed in rather than read here, so this module doesn't depend on home.
  final String? sourceLanguageCode;
  final String? targetLanguageCode;

  @override
  ConsumerState<OfflineLanguagesView> createState() => _OfflineLanguagesViewState();
}

/// ML Kit's built-in model, which can't be deleted.
const _builtInLanguageCode = 'en';

class _OfflineLanguagesViewState extends ConsumerState<OfflineLanguagesView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  /// Row tap. In selection mode it selects (see [_onLanguageTapped]). On the
  /// Offline Languages screen it downloads a missing language, like the
  /// download button, and does nothing for a downloaded one.
  VoidCallback? _onRowTap(Language language) {
    if (widget.selectionMode) return () => _onLanguageTapped(language);
    if (language.isDownloaded || language.code == _builtInLanguageCode) return null;
    return () => _download(language);
  }

  /// Delete for a downloaded language, download for a missing one. English
  /// gets a "System" chip instead: it's built into ML Kit, and deleting it did
  /// nothing when tried on a device (2026-11-17).
  Widget _trailing(Language language) {
    final scheme = context.theme.colorScheme;
    if (language.code == _builtInLanguageCode) {
      return Chip(
        avatar: Icon(Icons.verified_outlined, size: 15, color: scheme.onSecondaryContainer),
        label: const Text('System'),
        labelStyle: context.text.labelSmall?.copyWith(color: scheme.onSecondaryContainer),
        backgroundColor: scheme.secondaryContainer,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    if (language.isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Offline ready',
            child: CircleAvatar(
              radius: 14,
              backgroundColor: scheme.secondaryContainer,
              child: Icon(Icons.check, size: 16, color: scheme.onSecondaryContainer),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Delete ${language.name.capitalize}',
            icon: const Icon(Icons.delete_outline, size: 20),
            color: scheme.outline,
            onPressed: () => _confirmAndDelete(language),
          ),
        ],
      );
    }
    return IconButton.filled(
      tooltip: 'Download ${language.name.capitalize}',
      icon: const Icon(Icons.download, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.primary,
        disabledBackgroundColor: scheme.surfaceContainerHigh,
        disabledForegroundColor: scheme.outline,
      ),
      onPressed: () => _download(language),
    );
  }

  /// Downloads a missing language behind the loader without asking. Never
  /// selects the language.
  Future<void> _download(Language language) async {
    final result = await downloadLanguagesWithLoader(context, ref, [language]);
    if (!mounted) return;
    switch (result) {
      case LanguageDownloadResult.done:
        _showMessage('${language.name.capitalize} downloaded');
      case LanguageDownloadResult.failed:
        showLanguageDownloadFailed([language]);
      case LanguageDownloadResult.cancelled:
        break;
    }
  }

  /// Asks before deleting, mentioning it when the language is selected. A
  /// selected language stays selected; translating later offers the download.
  Future<void> _confirmAndDelete(Language language) async {
    final name = language.name.capitalize;
    final role = language.code == widget.targetLanguageCode
        ? 'target'
        : language.code == widget.sourceLanguageCode
        ? 'source'
        : null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          icon: CircleAvatar(
            radius: 24,
            backgroundColor: scheme.errorContainer,
            child: Icon(Icons.delete, color: scheme.onErrorContainer),
          ),
          title: Text('Delete $name?'),
          content: Text(
            [
              if (role != null) '$name is your current $role language.',
              "You won't be able to translate $name offline until you download it again.",
            ].join(' '),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
                disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    bool deleted;
    try {
      deleted = await ref.read(offlineLanguagesProvider.notifier).deleteLanguage(language.code);
    } catch (error, stackTrace) {
      debugPrint('Delete of ${language.code} failed: $error\n$stackTrace');
      deleted = false;
    }
    if (!mounted) return;
    _showMessage(deleted ? '$name removed' : "Couldn't delete $name. Please try again.");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: context.theme.colorScheme.secondaryFixed),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
  }

  bool _matches(Language language) {
    if (_query.isEmpty) return true;
    final native = nativeLanguageNames[language.code]?.toLowerCase() ?? '';
    return language.name.toLowerCase().contains(_query) || native.contains(_query);
  }

  Widget _searchField() {
    final scheme = context.theme.colorScheme;
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search languages...',
        hintStyle: TextStyle(color: scheme.outline),
        prefixIcon: Icon(Icons.search, color: scheme.outline),
        suffixIcon: _query.isEmpty && _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: Icon(Icons.close, size: 18, color: scheme.outline),
                onPressed: () => setState(() {
                  _searchController.clear();
                  _query = '';
                }),
              ),
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _sectionHeader(String title, int count, String hint) {
    final scheme = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(color: scheme.onSurface),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$count', style: context.text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(hint, style: context.text.labelSmall?.copyWith(color: scheme.outline)),
        ],
      ),
    );
  }

  Widget _card(Language language) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: LanguageCard(
      language: language,
      subtitle: language.code == _builtInLanguageCode ? 'Built into the app' : null,
      trailing: _trailing(language),
      onTap: _onRowTap(language),
    ),
  );

  Widget _emptySearch() {
    final scheme = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.surfaceContainerHigh,
            child: Icon(Icons.search_off, color: scheme.outline),
          ),
          const SizedBox(height: 8),
          Text('No languages found', style: context.text.titleMedium?.copyWith(color: scheme.onSurface)),
          const SizedBox(height: 4),
          Text(
            'Check your spelling or try searching another name',
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languages = ref.watch(offlineLanguagesProvider).value;
    final appBar = AppBar(title: Text(widget.title));
    if (languages == null) {
      return Scaffold(appBar: appBar, body: const Center(child: CircularProgressIndicator()));
    }

    // The provider lists downloaded languages first; split them for the two
    // sections. A section with no matches is left out.
    final downloaded = languages.where((l) => l.isDownloaded && _matches(l)).toList();
    final available = languages.where((l) => !l.isDownloaded && _matches(l)).toList();

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: _searchField()),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                if (downloaded.isNotEmpty) ...[
                  _sectionHeader('Downloaded Languages', downloaded.length, 'Offline ready'),
                  ...downloaded.map(_card),
                  const SizedBox(height: 20),
                ],
                if (available.isNotEmpty) ...[
                  _sectionHeader(
                    'Available',
                    available.length,
                    widget.selectionMode ? 'Tap to download and use' : 'Tap to save offline',
                  ),
                  ...available.map(_card),
                ],
                if (downloaded.isEmpty && available.isEmpty) _emptySearch(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
