import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/setting.entity.dart';

/// Picks the source / translation text size on a wheel, with a preview.
/// Styled after Stitch's text size dialog (size badge, preview card, note),
/// but keeps the wheel and the 2026-11-18 behaviour: tapping outside or Back
/// closes with the picked size; Cancel closes with null (keep the old size).
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
    final scheme = theme.colorScheme;
    // canPop false routes the barrier tap and Back here, so they can close
    // with the picked size. Cancel pops directly with null.
    return PopScope<double>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _size);
      },
      child: AlertDialog(
        // Short screens (e.g. 320 x 568) can't fit the whole dialog: scroll.
        scrollable: true,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: Row(
          children: [
            Icon(Icons.format_size, size: 22, color: scheme.primary),
            const SizedBox(width: 4),
            Expanded(child: Text('Text size', style: theme.textTheme.headlineSmall)),
            Container(
              key: const Key('textSizeBadge'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: ShapeDecoration(shape: const StadiumBorder(), color: scheme.primary),
              child: Text(
                '${_size.toStringAsFixed(0)} sp',
                style: theme.textTheme.labelMedium?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 312,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview card. Fixed height so the dialog doesn't jump as the
              // size changes.
              Container(
                height: 132,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 13, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'OUTPUT PREVIEW',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: SingleChildScrollView(
                        key: const Key('textSizePreview'),
                        child: Text(
                          widget.previewText,
                          style: theme.textTheme.bodyLarge?.copyWith(fontSize: _size, color: scheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // The wheel, between a small and a large "A" (14 and 32).
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    _SizeHint(letterSize: 13, value: _sizes.first),
                    Expanded(child: _buildWheel(theme)),
                    _SizeHint(letterSize: 18, value: _sizes.last),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Changes translation text size only. System UI will remain standard.',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }

  Widget _buildWheel(ThemeData theme) {
    final scheme = theme.colorScheme;
    return SizedBox(
      height: _itemExtent * 3,
      child: Stack(
        children: [
          // Marks the selected row.
          Center(
            child: Container(
              height: _itemExtent,
              width: 88,
              decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
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
                      color: selected ? scheme.onSecondaryContainer : theme.hintColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "A" with its size underneath, marking the wheel's small and large ends.
class _SizeHint extends StatelessWidget {
  const _SizeHint({required this.letterSize, required this.value});

  final double letterSize;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('A', style: theme.textTheme.titleLarge?.copyWith(fontSize: letterSize, color: color)),
          Text('(${value.toStringAsFixed(0)})', style: theme.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
