import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../setting/domain/entities/setting.entity.dart';
import '../../../../setting/presentation/providers/settings_provider.dart';

/// The source / translation text field. Its font size is the Text size
/// setting.
class CustomTextField extends ConsumerWidget {
  const CustomTextField({
    super.key,
    // this.initialValue,
    this.readOnly,
    this.showLoader = false,
    // this.onChanged,
    this.controller,
    this.autofocus = false,
    this.focusNode,
    this.hintText,
    this.contentPadding = const EdgeInsets.fromLTRB(8, 18, 0, 0),
  });
  final EdgeInsetsGeometry contentPadding;
  // final String? initialValue;
  final bool? readOnly, showLoader;
  // final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool? autofocus;
  final FocusNode? focusNode;
  final String? hintText;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textSize = ref.watch(settingsProvider.select((s) => s.value?.textSize)) ?? AppSettings.defaultTextSize;
    return Scrollbar(
      child: Stack(
        children: [
          TextFormField(
            focusNode: focusNode,
            controller: controller,
            readOnly: readOnly ?? false,
            autofocus: autofocus!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: textSize),
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(contentPadding: contentPadding, hintText: hintText),
          ),
          if (showLoader!) const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
