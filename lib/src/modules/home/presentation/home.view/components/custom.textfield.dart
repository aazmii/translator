import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, this.text, this.readOnly, this.showLoader = false});
  final String? text;
  final bool? readOnly, showLoader;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Stack(
        children: [
          TextFormField(
            initialValue: text,
            expands: true,
            maxLines: null,
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
