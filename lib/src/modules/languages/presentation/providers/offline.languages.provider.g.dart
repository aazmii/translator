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

String _$offlineLanguagesHash() => r'68e84bf9f9bca6092332e7911641c9342abe3a3d';

abstract class _$OfflineLanguages extends $AsyncNotifier<List<LanguageEntity>> {
  FutureOr<List<LanguageEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
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
    element.handleCreate(ref, build);
  }
}
