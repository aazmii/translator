// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ondevice.translator.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnDeviceTranslatorP)
const onDeviceTranslatorPProvider = OnDeviceTranslatorPProvider._();

final class OnDeviceTranslatorPProvider
    extends $NotifierProvider<OnDeviceTranslatorP, OnDeviceTranslator> {
  const OnDeviceTranslatorPProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'onDeviceTranslatorPProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$onDeviceTranslatorPHash();

  @$internal
  @override
  OnDeviceTranslatorP create() => OnDeviceTranslatorP();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnDeviceTranslator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnDeviceTranslator>(value),
    );
  }
}

String _$onDeviceTranslatorPHash() =>
    r'4117810777fe783cb894956f8c42ad03f10a26c1';

abstract class _$OnDeviceTranslatorP extends $Notifier<OnDeviceTranslator> {
  OnDeviceTranslator build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OnDeviceTranslator, OnDeviceTranslator>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OnDeviceTranslator, OnDeviceTranslator>,
        OnDeviceTranslator,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
