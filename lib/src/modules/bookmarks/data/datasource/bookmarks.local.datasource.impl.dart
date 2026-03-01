import 'dart:convert';

import 'package:hive/hive.dart' show Box;

import '../model/bookmark.model.dart';
import 'bookmark.local.datasource.dart';

class BookmarksLocalDataSourceImpl implements BookmarksLocalDataSource {
  final Box<String> box;
  final String keyPrefix;

  BookmarksLocalDataSourceImpl(this.box, {this.keyPrefix = 'bookmark_'});

  @override
  Future<List<BookmarkModel>> getAll() async {
    final result = <BookmarkModel>[];
    for (final key in box.keys) {
      final asString = key.toString();
      if (!asString.startsWith(keyPrefix)) {
        continue;
      }
      final raw = box.get(asString);
      if (raw == null) {
        continue;
      }
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        result.add(BookmarkModel.fromMap(data));
      } else if (data is Map) {
        result.add(BookmarkModel.fromMap(Map<String, dynamic>.from(data)));
      }
    }
    return result;
  }

  @override
  Future<void> save(BookmarkModel model) {
    return box.put('$keyPrefix${model.id}', jsonEncode(model.toMap()));
  }

  @override
  Future<void> remove(String id) {
    return box.delete('$keyPrefix$id');
  }
}
