import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/setting.entity.dart';

/// Picks the source / translation text size on a wheel, with a preview.
///
/// Tapping outside or Back closes with the picked size; Cancel closes with
/// null (keep the old size).
class TextSizeDialog extends StatefulWidget {
  const TextSizeDialog({super.key, required this.current, required this.previewText});

  final double current;
  final String previewText;

  @override
  State<TextSizeDialog> createState() => _TextSizeDialogState();
}

class _TextSizeDialogState extends State<TextSizeDialog> {
  static const _sizes = AppSettings.textSizes;
  static const _itemExtent = 44.0;

  late double _size = _sizes.contains(widget.current) ? widget.current : AppSettings.defaultTextSize;
  late final _wheel = FixedExtentScrollController(initialItem: _sizes.indexOf(_size));

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // canPop false routes the barrier tap and Back here, so they can close
    // with the picked size. Cancel pops directly with null.
    return PopScope<double>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _size);
      },
      child: AlertDialog(
        title: const Text('Text size'),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fixed height so the dialog doesn't jump as the size changes.
              Container(
                key: const Key('textSizePreview'),
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(widget.previewText, style: theme.textTheme.bodyLarge?.copyWith(fontSize: _size)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: _itemExtent * 3,
                child: Stack(
                  children: [
                    // Marks the selected row.
                    Center(
                      child: Container(
                        height: _itemExtent,
                        width: 96,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      controller: _wheel,
                      itemExtent: _itemExtent,
                      diameterRatio: 1.6,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() => _size = _sizes[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _sizes.length,
                        builder: (context, index) {
                          final selected = _sizes[index] == _size;
                          return Center(
                            child: Text(
                              _sizes[index].toStringAsFixed(0),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                color: selected ? theme.colorScheme.onSecondaryContainer : theme.hintColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
