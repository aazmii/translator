// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks.controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookmarksController)
final bookmarksControllerProvider = BookmarksControllerProvider._();

final class BookmarksControllerProvider
    extends $AsyncNotifierProvider<BookmarksController, List<BookmarkEntity>> {
  BookmarksControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarksControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarksControllerHash();

  @$internal
  @override
  BookmarksController create() => BookmarksController();
}

String _$bookmarksControllerHash() =>
    r'ed15d8aff5d02ca8bf18431b89605d05dd93e3a9';

abstract class _$BookmarksController
    extends $AsyncNotifier<List<BookmarkEntity>> {
  FutureOr<List<BookmarkEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<BookmarkEntity>>, List<BookmarkEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<BookmarkEntity>>,
                List<BookmarkEntity>
              >,
              AsyncValue<List<BookmarkEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
