import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/components/expandabe.search.app.bar.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

class OfflineLanguagesView extends ConsumerStatefulWidget {
  const OfflineLanguagesView({super.key, required this.title, this.selectionMode = false});

  final String title;
  final bool selectionMode;

  @override
  ConsumerState<OfflineLanguagesView> createState() => _OfflineLanguagesViewState();
}

enum _DownloadResult { done, failed, cancelled }

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
    final name = language.name.capitalize;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Download $name?'),
        content: Text(
          '$name needs to be downloaded before you can use it. '
          'This may use mobile data.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Download')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await _downloadWithLoader(language.code, name);
    if (!mounted) return;
    switch (result) {
      case _DownloadResult.done:
        Navigator.pop(context, language.code);
      case _DownloadResult.failed:
        _showDownloadFailed(name);
      case _DownloadResult.cancelled:
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
    final name = language.name.capitalize;
    final result = await _downloadWithLoader(language.code, name);
    if (mounted && result == _DownloadResult.failed) _showDownloadFailed(name);
  }

  void _showDownloadFailed(String name) {
    Fluttertoast.showToast(
      msg: "Couldn't download $name. Check your connection and try again.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Downloads over any connection behind a loader that only its Cancel
  /// button can close. ML Kit can't cancel a download, so after Cancel it may
  /// still finish in the background; [loaderOpen] stops that late result from
  /// popping a second route.
  Future<_DownloadResult> _downloadWithLoader(String code, String name) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    var loaderOpen = true;
    void close(_DownloadResult result) {
      if (!loaderOpen) return;
      loaderOpen = false;
      navigator.pop(result);
    }

    final loader = showDialog<_DownloadResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Downloading $name…'),
                    const SizedBox(height: 4),
                    Text('This can take a minute.', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          actions: [TextButton(onPressed: () => close(_DownloadResult.cancelled), child: const Text('Cancel'))],
        ),
      ),
    );
    ref
        .read(offlineLanguagesProvider.notifier)
        .downloadLanguage(code, wifiOnly: false)
        .then(
          (ok) => close(ok ? _DownloadResult.done : _DownloadResult.failed),
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Download of $code failed: $error\n$stackTrace');
            close(_DownloadResult.failed);
          },
        );
    return await loader ?? _DownloadResult.cancelled;
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
    final downloaded = languages?.where((l) => l.isDownloaded).toList();
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
            final language = languages[i];
            if (i == 0) {
              return Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text('Recent Languages', style: TextStyle(color: context.theme.colorScheme.primary)),
                  ListTile(
                    onTap: widget.selectionMode ? () => _onLanguageTapped(language) : null,
                    title: Text(language.name.capitalize),
                    trailing: _trailing(language),
                  ),
                ],
              );
            }
            if (i == downloaded!.length) {
              return Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text('Other Languages', style: TextStyle(color: context.theme.colorScheme.primary)),
                  ListTile(
                    onTap: widget.selectionMode ? () => _onLanguageTapped(language) : null,
                    title: Text(language.name.capitalize),
                    trailing: _trailing(language),
                  ),
                ],
              );
            }
            return ListTile(
              onTap: widget.selectionMode ? () => _onLanguageTapped(language) : null,
              title: Text(language.name.capitalize),
              trailing: _trailing(language),
            );
          },
        ),
      ),
    );
  }
}
