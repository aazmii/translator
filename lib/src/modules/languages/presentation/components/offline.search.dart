import 'package:flutter/material.dart';

class ExpandableSearchBox extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  const ExpandableSearchBox({super.key, this.onChanged, this.controller});

  @override
  State<ExpandableSearchBox> createState() => _ExpandableSearchBoxState();
}

class _ExpandableSearchBoxState extends State<ExpandableSearchBox> with SingleTickerProviderStateMixin {
  // bool _isExpanded = false;
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);

    if (_isExpanded) {
      Future.delayed(
        const Duration(milliseconds: 200),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: _isExpanded ? 200 : 50,
      curve: Curves.easeIn,
      height: 58,
      // padding: const EdgeInsets.symmetric(horizontal: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isExpanded)
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                decoration: InputDecoration(fillColor: Colors.red, filled: true),
              ),
            ),
          IconButton(
            splashRadius: 30,
            icon: Icon(_isExpanded ? Icons.close : Icons.search, color: Theme.of(context).colorScheme.primary),
            onPressed: _toggle,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
