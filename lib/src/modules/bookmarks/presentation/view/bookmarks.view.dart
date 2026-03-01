import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/modules/bookmarks/presentation/providers/bookmarks.controller.dart';

class BookmarksView extends ConsumerWidget {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return const Center(child: Text('No bookmarks yet'));
          }

          return ListView.separated(
            itemCount: bookmarks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final bookmark = bookmarks[index];
              return ListTile(
                title: Text(bookmark.sourceText),
                subtitle: bookmark.targetText?.isNotEmpty == true ? Text(bookmark.targetText!) : null,
              );
            },
          );
        },
        error: (_, __) => const Center(child: Text('Failed to load bookmarks')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
