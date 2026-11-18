import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/presentation/providers/bookmarks.controller.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/tts.helper.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:share_plus/share_plus.dart';

/// Saved bookmarks (Teal Meridian, from Stitch's bookmarks screen): a search
/// field, then one card per bookmark, newest first. Delete (button or swipe)
/// removes at once; the SnackBar offers Undo.
class BookmarksView extends ConsumerStatefulWidget {
  const BookmarksView({super.key});

  @override
  ConsumerState<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends ConsumerState<BookmarksView> {
  final _search = TextEditingController();
  final _tts = FlutterTts();

  /// Ids deleted on screen but maybe not yet gone from the provider. A swiped
  /// Dismissible must leave the tree at once, before the delete completes.
  final _hidden = <String>{};

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    // Not awaited; a failure to stop speech is only logged.
    _tts.stop().catchError((Object error) => debugPrint('Stopping speech failed: $error'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarksControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: SafeArea(
        top: false,
        child: switch (bookmarksAsync) {
          AsyncData(:final value) => _buildList(value.where((b) => !_hidden.contains(b.id)).toList()),
          AsyncError() => const _Message(icon: Icons.error_outline, text: "Couldn't load your bookmarks"),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _buildList(List<BookmarkEntity> bookmarks) {
    if (bookmarks.isEmpty) {
      return const SingleChildScrollView(padding: EdgeInsets.all(16), child: _EmptyState());
    }
    final query = _search.text.trim().toLowerCase();
    final shown = query.isEmpty
        ? bookmarks
        : bookmarks
              .where(
                (b) =>
                    b.sourceText.toLowerCase().contains(query) ||
                    (b.targetText?.toLowerCase().contains(query) ?? false),
              )
              .toList();
    final anyDated = bookmarks.any((b) => b.savedAt != null);
    return Column(
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 8), child: _SearchField(controller: _search)),
        Expanded(
          child: shown.isEmpty
              ? const _Message(icon: Icons.search_off, text: 'No bookmarks match')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: shown.length + 1,
                  separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 8 : 16),
                  itemBuilder: (context, index) {
                    if (index == 0) return _SectionHeader(sortedByDate: anyDated);
                    final bookmark = shown[index - 1];
                    return _BookmarkCard(
                      key: ValueKey(bookmark.id),
                      bookmark: bookmark,
                      onListen: () => _listen(bookmark),
                      onDelete: () => _delete(bookmark),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _listen(BookmarkEntity bookmark) async {
    final text = bookmark.targetText;
    final code = bookmark.targetLanguageCode;
    if (text == null || code == null) return;
    try {
      await setTtsLanguage(_tts, code);
      await _tts.speak(text);
    } catch (error) {
      debugPrint('Bookmark speech failed: $error');
    }
  }

  Future<void> _delete(BookmarkEntity bookmark) async {
    setState(() => _hidden.add(bookmark.id));
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(bookmarksControllerProvider.notifier);
    try {
      await controller.removeBookmark(bookmark.id);
    } catch (error) {
      debugPrint('Deleting a bookmark failed: $error');
      if (mounted) setState(() => _hidden.remove(bookmark.id));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("Couldn't delete the bookmark")));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Bookmark deleted'),
          // With an action, SnackBars stay until tapped by default; this one
          // goes after the usual timeout.
          persist: false,
          action: SnackBarAction(label: 'Undo', onPressed: () => _undo(bookmark, controller, messenger)),
        ),
      );
  }

  Future<void> _undo(BookmarkEntity bookmark, BookmarksController controller, ScaffoldMessengerState messenger) async {
    try {
      await controller.restoreBookmark(bookmark);
      if (mounted) setState(() => _hidden.remove(bookmark.id));
    } catch (error) {
      debugPrint('Restoring a bookmark failed: $error');
      messenger.showSnackBar(const SnackBar(content: Text("Couldn't restore the bookmark")));
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: ShapeDecoration(shape: const StadiumBorder(), color: scheme.surfaceContainer),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, size: 20, color: scheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search saved translations…',
                hintStyle: TextStyle(color: scheme.outline),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              onPressed: controller.clear,
              icon: Icon(Icons.close, size: 16, color: scheme.outline),
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.sortedByDate});

  final bool sortedByDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'SAVED',
              style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1.2),
            ),
          ),
          if (sortedByDate)
            Text(
              'Newest first',
              style: theme.textTheme.labelSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

/// One bookmark: date, the source and translation with their language codes,
/// and Listen · Copy · Share · Delete. Swipe left to delete.
class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({super.key, required this.bookmark, required this.onListen, required this.onDelete});

  final BookmarkEntity bookmark;
  final VoidCallback onListen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    final target = bookmark.targetText;
    final hasTarget = target != null && target.isNotEmpty;
    // Copy and Share use the translation, or the text when there is none.
    final mainText = hasTarget ? target : bookmark.sourceText;
    final canListen = hasTarget && bookmark.targetLanguageCode != null;
    final savedAt = bookmark.savedAt;
    final radius = BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: radius,
      child: Dismissible(
        key: ValueKey('dismiss-${bookmark.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          color: scheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: scheme.onError),
              Text('Delete', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onError)),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: radius,
            border: light ? null : Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (savedAt != null) ...[
                Text(_formatDate(savedAt), style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline)),
                const SizedBox(height: 8),
              ],
              _TextLine(
                code: bookmark.sourceLanguageCode,
                text: bookmark.sourceText,
                codeColor: scheme.outline,
                style: hasTarget
                    ? theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)
                    : theme.textTheme.titleMedium?.copyWith(color: scheme.onSurface),
              ),
              if (hasTarget) ...[
                const SizedBox(height: 6),
                _TextLine(
                  code: bookmark.targetLanguageCode,
                  text: target,
                  codeColor: scheme.primary,
                  codeBold: true,
                  style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurface),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (canListen) ...[
                    _ListenButton(onPressed: onListen),
                    const SizedBox(width: 4),
                  ],
                  _RoundButton(
                    tooltip: 'Copy',
                    icon: Icons.content_copy_outlined,
                    onPressed: () => Clipboard.setData(ClipboardData(text: mainText)),
                  ),
                  const SizedBox(width: 4),
                  _RoundButton(
                    tooltip: 'Share',
                    icon: Icons.share_outlined,
                    onPressed: () => SharePlus.instance.share(ShareParams(text: mainText)),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    color: scheme.outline,
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Today, 10:14 AM", "Yesterday", or "12 Nov 2026".
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final days = today.difference(day).inDays;
    if (days == 0) return 'Today, ${DateFormat.jm().format(date)}';
    if (days == 1) return 'Yesterday';
    return DateFormat('d MMM yyyy').format(date);
  }
}

/// A text with its language code in a narrow column on the left. Without a
/// code, the text alone.
class _TextLine extends StatelessWidget {
  const _TextLine({
    required this.code,
    required this.text,
    required this.codeColor,
    required this.style,
    this.codeBold = false,
  });

  final String? code;
  final String text;
  final Color codeColor;
  final TextStyle? style;
  final bool codeBold;

  @override
  Widget build(BuildContext context) {
    final body = Text(text, style: style);
    if (code == null) return body;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              code!.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: codeColor,
                fontWeight: codeBold ? FontWeight.w700 : null,
              ),
            ),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Listen',
      child: Material(
        color: scheme.surfaceContainer,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: SizedBox(
            height: 36,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Listen',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.tooltip, required this.icon, required this.onPressed});

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: scheme.surfaceContainer,
        foregroundColor: scheme.onSurfaceVariant,
        fixedSize: const Size.square(36),
        minimumSize: const Size.square(36),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: scheme.secondaryContainer,
            child: Icon(Icons.star, size: 40, color: scheme.onSecondaryContainer),
          ),
          const SizedBox(height: 16),
          Text('No bookmarks yet', style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurface)),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              'Tap the star on the translator page to save a phrase here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: scheme.outline),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
