import 'package:flutter/material.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/components/language.native.names.dart';

/// One language row in the Teal Meridian style: a rounded white card with the
/// code in a circle, the name, its native name under it, and [trailing].
class LanguageCard extends StatelessWidget {
  const LanguageCard({super.key, required this.language, this.subtitle, this.trailing, this.onTap});

  final Language language;

  /// Shown under the name instead of the native name.
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final text = context.text;
    final name = language.name.capitalize;
    final native = subtitle ?? nativeLanguageNames[language.code];
    final radius = BorderRadius.circular(12);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [BoxShadow(color: scheme.shadow.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: language.isDownloaded ? scheme.surfaceContainer : scheme.surfaceContainerHigh,
                  child: Text(
                    language.code.toUpperCase(),
                    style: text.titleMedium?.copyWith(
                      color: language.isDownloaded ? scheme.secondary : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(color: scheme.onSurface),
                      ),
                      if (native != null && native != name)
                        Text(
                          native,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
