// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Translator)
final translatorProvider = TranslatorProvider._();

final class TranslatorProvider
    extends $AsyncNotifierProvider<Translator, TranslationSettingEntity?> {
  TranslatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'translatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$translatorHash();

  @$internal
  @override
  Translator create() => Translator();
}

String _$translatorHash() => r'6c2fe562fae61baa8fc3ac46c5c98a8e9bfbf6f6';

abstract class _$Translator extends $AsyncNotifier<TranslationSettingEntity?> {
  FutureOr<TranslationSettingEntity?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<TranslationSettingEntity?>,
              TranslationSettingEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TranslationSettingEntity?>,
                TranslationSettingEntity?
              >,
              AsyncValue<TranslationSettingEntity?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
