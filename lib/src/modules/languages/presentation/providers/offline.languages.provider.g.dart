// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline.languages.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OfflineLanguages)
final offlineLanguagesProvider = OfflineLanguagesProvider._();

final class OfflineLanguagesProvider
    extends $AsyncNotifierProvider<OfflineLanguages, List<LanguageEntity>> {
  OfflineLanguagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineLanguagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineLanguagesHash();

  @$internal
  @override
  OfflineLanguages create() => OfflineLanguages();
}

String _$offlineLanguagesHash() => r'10bb93a241207477e18fb9f2301c71b6b5d06f78';

abstract class _$OfflineLanguages extends $AsyncNotifier<List<LanguageEntity>> {
  FutureOr<List<LanguageEntity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<LanguageEntity>>, List<LanguageEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<LanguageEntity>>,
                List<LanguageEntity>
              >,
              AsyncValue<List<LanguageEntity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
