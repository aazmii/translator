import 'package:flutter/material.dart';

class ExpandableSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onChanged;
  final String? title;
  const ExpandableSearchAppBar({super.key, this.onChanged, this.hintText, this.title});
  final String? hintText;
  @override
  State<ExpandableSearchAppBar> createState() => _ExpandableSearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ExpandableSearchAppBarState extends State<ExpandableSearchAppBar> {
  bool _isSearching = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  void _toggle() {
    setState(() => _isSearching = !_isSearching);
    if (_isSearching) {
      Future.delayed(
        const Duration(milliseconds: 150),
        () => _focusNode.requestFocus(),
      );
    } else {
      _focusNode.unfocus();
      _controller.clear();
      widget.onChanged?.call('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                border: InputBorder.none,
              ),
            )
          : Text(widget.title ?? ''),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggle,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
