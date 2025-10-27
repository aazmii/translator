import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    // this.initialValue,
    this.readOnly,
    this.showLoader = false,
    this.onChanged,
    this.controller,
    this.autofocus = false,
    this.focusNode
  });
  // final String? initialValue;
  final bool? readOnly, showLoader;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool? autofocus;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Stack(
        children: [
          TextFormField(
            focusNode: focusNode,
            controller: controller,
            autofocus: autofocus!,
            // key: ValueKey(initialValue),
            // initialValue: initialValue,
            expands: true,
            maxLines: null,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(8, 18, 0, 0),
            ),
          ),
          if (showLoader!) const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
