// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline.languages.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OfflineLanguages)
const offlineLanguagesProvider = OfflineLanguagesProvider._();

final class OfflineLanguagesProvider
    extends $AsyncNotifierProvider<OfflineLanguages, List<LanguageEntity>> {
  const OfflineLanguagesProvider._()
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

String _$offlineLanguagesHash() => r'859b2e9c938d9cf111a56d3186e93f9ae4116bd1';

abstract class _$OfflineLanguages extends $AsyncNotifier<List<LanguageEntity>> {
  FutureOr<List<LanguageEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<List<LanguageEntity>>, List<LanguageEntity>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<LanguageEntity>>, List<LanguageEntity>>,
        AsyncValue<List<LanguageEntity>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
