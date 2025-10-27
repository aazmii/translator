// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Translator)
const translatorProvider = TranslatorProvider._();

final class TranslatorProvider
    extends $NotifierProvider<Translator, TranslaorModel> {
  const TranslatorProvider._()
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TranslaorModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TranslaorModel>(value),
    );
  }
}

String _$translatorHash() => r'6fb30793f449c7cb23ad37a3e4f8c4ea7739650f';

abstract class _$Translator extends $Notifier<TranslaorModel> {
  TranslaorModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TranslaorModel, TranslaorModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TranslaorModel, TranslaorModel>,
        TranslaorModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
