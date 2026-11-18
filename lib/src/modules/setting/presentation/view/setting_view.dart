import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../theme/model/theme.model.dart' show ThemeProfileExtension;
import '../../../../theme/provider/theme.provider.dart';
import '../../../home/presentation/home.view/components/home.app.bar/home.app.bar.dart';
import '../../../home/presentation/home.view/components/home.drawer/home.drawer.dart';
import '../../../home/presentation/home.view/providers/translator.dart';
import '../../domain/entities/setting.entity.dart';
import '../../domain/entities/theme_profile.dart';
import '../providers/settings_provider.dart';
import 'text_size_dialog.dart';

/// Settings, laid out as Stitch's settings screen: a PREFERENCES group
/// (theme, keyboard, text size) and an ABOUT group (version, licences).
class SettingView extends ConsumerWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final theme = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider).value;
    final showKeyboard = settings?.showKeyboardAtStartup ?? true;
    final textSize = settings?.textSize ?? AppSettings.defaultTextSize;
    return Scaffold(
      // Same app bar and drawer as the translator page; the menu replaces the
      // back arrow (Android Back still returns).
      appBar: const HomeAppbar(title: 'Settings'),
      drawer: const HomeDrawer(current: DrawerPage.settings),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _SectionHeader('Preferences'),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.palette,
                iconBackground: scheme.secondaryContainer,
                iconColor: scheme.onSecondaryContainer,
                title: 'Theme',
                subtitle: theme.label,
                trailing: const _Chevron(),
                onTap: () => _chooseTheme(context, ref, theme),
              ),
              _SettingsTile(
                icon: Icons.keyboard_outlined,
                title: 'Show the keyboard at startup',
                subtitle: 'Automatically focus text input when app opens',
                trailing: Checkbox(
                  value: showKeyboard,
                  onChanged: (value) => _setKeyboard(ref, value ?? !showKeyboard),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide.none,
                  fillColor: WidgetStateProperty.resolveWith(
                    (states) =>
                        states.contains(WidgetState.selected) ? scheme.primary : scheme.surfaceContainerHighest,
                  ),
                ),
                onTap: () => _setKeyboard(ref, !showKeyboard),
              ),
              _SettingsTile(
                icon: Icons.format_size,
                title: 'Translation text size',
                subtitle: '${textSize.toStringAsFixed(0)} sp',
                trailing: const _Chevron(),
                onTap: () => _chooseTextSize(context, ref, textSize),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionHeader('About'),
          _SettingsGroup(
            children: [
              const _VersionTile(),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Open source licences',
                subtitle: 'Third-party notices for packages and fonts',
                trailing: const _Chevron(),
                onTap: () => _showLicences(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLicences(BuildContext context) async {
    String? version;
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (error) {
      debugPrint('Reading the app version failed: $error');
    }
    if (!context.mounted) return;
    showLicensePage(context: context, applicationName: 'Go Translator', applicationVersion: version);
  }

  Future<void> _setKeyboard(WidgetRef ref, bool show) async {
    try {
      await ref.read(settingsProvider.notifier).setKeyboardAtStartup(show);
    } catch (error, stackTrace) {
      debugPrint('Saving the keyboard setting failed: $error\n$stackTrace');
      _showToast("Couldn't save the setting");
    }
  }

  Future<void> _chooseTextSize(BuildContext context, WidgetRef ref, double current) async {
    final sourceText = ref.read(translatorProvider).value?.sourceText?.trim() ?? '';
    final picked = await showDialog<double>(
      context: context,
      builder: (context) => TextSizeDialog(
        current: current,
        previewText: sourceText.isEmpty ? 'Hello, how are you today?' : sourceText,
      ),
    );
    if (picked == null || picked == current) return;
    try {
      await ref.read(settingsProvider.notifier).setTextSize(picked);
    } catch (error, stackTrace) {
      debugPrint('Saving the text size failed: $error\n$stackTrace');
      _showToast("Couldn't save the text size");
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _chooseTheme(BuildContext context, WidgetRef ref, ThemeProfile current) async {
    final picked = await showDialog<ThemeProfile>(
      context: context,
      builder: (context) => ThemeDialog(current: current),
    );
    if (picked == null || picked == current) return;
    try {
      await ref.read(settingsProvider.notifier).changeTheme(picked);
    } catch (error, stackTrace) {
      debugPrint('Saving the theme failed: $error\n$stackTrace');
      _showToast("Couldn't save the theme");
    }
  }
}

/// Teal, uppercase, tracked section label (label-md, bold).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// A rounded (16px) group of tiles with thin inset dividers. Light mode has a
/// small shadow; dark mode a thin outline instead.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final light = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: light ? null : Border.all(color: scheme.outlineVariant),
        boxShadow: light ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))] : null,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: scheme.surfaceContainerHighest),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A settings row: a 40px round icon, title and subtitle, and an optional
/// trailing widget. Not tappable when [onTap] is null.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBackground,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color? iconBackground, iconColor;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconBackground ?? scheme.surfaceContainerHigh,
              child: Icon(icon, size: 20, color: iconColor ?? scheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurface)),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

/// "App version" with the installed version, read once when the tile appears.
class _VersionTile extends StatefulWidget {
  const _VersionTile();

  @override
  State<_VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends State<_VersionTile> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snapshot) => _SettingsTile(
        icon: Icons.info_outline,
        title: 'App version',
        subtitle: switch (snapshot) {
          AsyncSnapshot(:final data?) => 'Go Translator ${data.version}',
          AsyncSnapshot(hasError: true) => 'Unknown',
          _ => '…',
        },
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant);
}

/// "Choose theme": the themes with a short description and a radio on the
/// right, the [current] one tinted. Tapping one closes the dialog with it;
/// Cancel closes with null.
class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key, required this.current});

  final ThemeProfile current;

  static const _descriptions = {
    ThemeProfile.system: 'Follow system defaults',
    ThemeProfile.light: 'Standard high clarity view',
    ThemeProfile.dark: 'Deep contrast for night use',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.secondaryContainer,
            child: Icon(Icons.palette, size: 20, color: scheme.onSecondaryContainer),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('Choose theme', style: theme.textTheme.headlineSmall)),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      content: RadioGroup<ThemeProfile>(
        groupValue: current,
        onChanged: (picked) => Navigator.pop(context, picked),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in ThemeProfile.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: option == current ? scheme.surfaceContainer.withValues(alpha: 0.6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context, option),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.label,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: option == current ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _descriptions[option]!,
                                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Radio<ThemeProfile>(value: option),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
    );
  }
}
