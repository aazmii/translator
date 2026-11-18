import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/modules/bookmarks/data/model/bookmark.model.dart';

void main() {
  test('a bookmark saved before dates and languages existed still loads', () {
    final model = BookmarkModel.fromMap(
      jsonDecode('{"id":"1","sourceText":"hello","targetText":"bonjour"}') as Map<String, dynamic>,
    );

    expect(model.sourceText, 'hello');
    expect(model.targetText, 'bonjour');
    expect(model.savedAt, isNull);
    expect(model.sourceLanguageCode, isNull);
    expect(model.targetLanguageCode, isNull);
  });

  test('date and languages save and load back', () {
    final saved = BookmarkModel(
      id: '1',
      sourceText: 'hello',
      targetText: 'bonjour',
      savedAt: DateTime(2026, 11, 19, 10, 14),
      sourceLanguageCode: 'en',
      targetLanguageCode: 'fr',
    );

    final loaded = BookmarkModel.fromMap(
      jsonDecode(jsonEncode(saved.toMap())) as Map<String, dynamic>,
    );

    expect(loaded.savedAt, DateTime(2026, 11, 19, 10, 14));
    expect(loaded.sourceLanguageCode, 'en');
    expect(loaded.targetLanguageCode, 'fr');
  });

  test('unreadable values load as null instead of failing', () {
    final model = BookmarkModel.fromMap({
      'id': '1',
      'sourceText': 'hello',
      'savedAt': 'not a date',
      'sourceLanguageCode': 42,
      'targetLanguageCode': '',
    });

    expect(model.savedAt, isNull);
    expect(model.sourceLanguageCode, isNull);
    expect(model.targetLanguageCode, isNull);
  });
}
