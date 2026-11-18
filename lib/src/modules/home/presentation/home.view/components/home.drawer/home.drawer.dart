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

/// The pages that have the drawer.
enum DrawerPage { translate, settings }

/// The navigation drawer (Teal Meridian, from Stitch's drawer screen), on the
/// translator page and on Settings. [current] is the highlighted tile.
///
/// From the translator page, destinations are pushed on top of it. From
/// Settings, Translate goes back to the translator page, and Offline
/// Languages / Bookmarks replace Settings, so Back from them returns to the
/// translator page.
class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key, this.current = DrawerPage.translate});

  final DrawerPage current;

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
      if (current == DrawerPage.translate) {
        fadePush(context, page);
      } else {
        fadeReplace(context, page);
      }
    }

    void openTranslate() {
      close();
      if (current != DrawerPage.translate) Navigator.popUntil(context, (route) => route.isFirst);
    }

    void openSettings() => current == DrawerPage.settings ? close() : open(const SettingView());

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
                      icon: Icons.translate,
                      label: 'Translate',
                      subtitle: 'Real-time instant text',
                      selected: current == DrawerPage.translate,
                      onTap: openTranslate,
                    ),
                    const SizedBox(height: 4),
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
                      selected: current == DrawerPage.settings,
                      showChevron: true,
                      onTap: openSettings,
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
/// right a count badge or a chevron (an arrow when [selected]).
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.badgeHighlighted = false,
    this.selected = false,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final bool badgeHighlighted;
  final bool selected;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final foreground = selected ? colors.onPrimaryContainer : colors.onSurfaceVariant;

    Widget? trailing;
    if (selected) {
      trailing = Icon(Icons.arrow_forward_ios, size: 16, color: foreground);
    } else if (badge != null) {
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
      color: selected ? colors.primaryContainer : Colors.transparent,
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
                Icon(icon, size: 22, color: foreground, fill: selected ? 1 : 0),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelLarge?.copyWith(
                          color: selected ? foreground : colors.onSurface,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
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
