import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/router/provider/route.provider.dart';
import 'package:go_translator/src/modules/bookmarks/presentation/providers/bookmarks.controller.dart';
import 'package:go_translator/src/modules/bookmarks/presentation/view/bookmarks.view.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';
import 'package:go_translator/src/modules/languages/presentation/view/offline.languages.view.dart';
import 'package:go_translator/src/modules/setting/presentation/view/setting_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/translator.dart';

/// The app's version from the platform (pubspec `version`, without the build
/// number). Read once; it can't change while the app runs.
final _appVersionProvider = FutureProvider<String>(
  (ref) async => (await PackageInfo.fromPlatform()).version,
);

/// The translator page's navigation drawer (Teal Meridian, from Stitch's
/// drawer screen). Only the translator page has it, so there is no Translate
/// tile; each destination opens on top of the translator page, and Back
/// returns to it (decision 2026-11-19).
class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translation = ref.watch(translatorProvider).value;
    // Counts show only once loaded; while loading or on error, no badge.
    final installed = ref.watch(offlineLanguagesProvider).value?.where((l) => l.isDownloaded).length;
    final saved = ref.watch(bookmarksControllerProvider).value?.length;
    final version = ref.watch(_appVersionProvider).value;

    void close() => Scaffold.of(context).closeDrawer();

    // Close the drawer first, so it isn't still open on return.
    void open(Widget page) {
      close();
      fadePush(context, page);
    }

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _Header(onClose: close),
                    const _DrawerDivider(),
                    _NavTile(
                      icon: Icons.download_for_offline_outlined,
                      label: 'Offline Languages',
                      badge: installed == null ? null : '$installed installed',
                      badgeHighlighted: true,
                      onTap: () => open(
                        OfflineLanguagesView(
                          title: 'Offline Languages',
                          sourceLanguageCode: translation?.sourceLanguageCode,
                          targetLanguageCode: translation?.targetLanguageCode,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.bookmarks_outlined,
                      label: 'Bookmarks',
                      badge: saved == null ? null : '$saved saved',
                      onTap: () => open(const BookmarksView()),
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      subtitle: 'Theme, Keyboard, Text size',
                      showChevron: true,
                      onTap: () => open(const SettingView()),
                    ),
                    const _DrawerDivider(),
                    const _PrivacyCard(),
                  ],
                ),
              ),
              if (version != null) _Footer(version: version),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.g_translate, size: 24, color: colors.onPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Go Translator', style: text.titleLarge?.copyWith(color: colors.primary)),
                Text(
                  'Offline translator',
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close menu',
            onPressed: onClose,
            icon: Icon(Icons.close, size: 20, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest),
    );
  }
}

/// A pill-shaped destination: icon, label, optional subtitle, and on the
/// right a count badge or a chevron.
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.badgeHighlighted = false,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final bool badgeHighlighted;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final foreground = colors.onSurfaceVariant;

    Widget? trailing;
    if (badge != null) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: colors.surfaceContainerHigh),
        child: Text(
          badge!,
          style: text.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: badgeHighlighted ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      );
    } else if (showChevron) {
      trailing = Icon(Icons.chevron_right, size: 20, color: colors.outline);
    }

    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: subtitle == null ? 48 : 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(icon, size: 22, color: foreground),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelLarge?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w500),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelSmall?.copyWith(color: foreground.withValues(alpha: 0.8)),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: colors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: colors.secondaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.lock_outline, size: 16, color: colors.onSecondaryContainer),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Translated on your device', style: text.labelMedium?.copyWith(color: colors.onSurface)),
                Text(
                  'Text you translate is not sent to a server.',
                  style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            'Version $version',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
