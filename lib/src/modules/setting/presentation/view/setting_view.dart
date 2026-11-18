import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;

import '../../../../theme/model/theme.model.dart' show ThemeProfileExtension;
import '../../../../theme/provider/theme.provider.dart';
import '../../domain/entities/theme_profile.dart';
import '../providers/settings_provider.dart';

class SettingView extends ConsumerWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final showKeyboard = ref.watch(settingsProvider).value?.showKeyboardAtStartup ?? true;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(theme.label),
            onTap: () => _chooseTheme(context, ref, theme),
          ),
          ListTile(
            leading: const Icon(Icons.keyboard),
            title: const Text('Keyboard'),
            subtitle: const Text('Show the keyboard at startup'),
            trailing: Checkbox(
              value: showKeyboard,
              onChanged: (value) => _setKeyboard(ref, value ?? !showKeyboard),
            ),
            onTap: () => _setKeyboard(ref, !showKeyboard),
          ),
        ],
      ),
    );
  }

  Future<void> _setKeyboard(WidgetRef ref, bool show) async {
    try {
      await ref.read(settingsProvider.notifier).setKeyboardAtStartup(show);
    } catch (error, stackTrace) {
      debugPrint('Saving the keyboard setting failed: $error\n$stackTrace');
      _showToast("Couldn't save the setting");
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

/// Lists the themes with the [current] one marked. Tapping one closes the
/// dialog with it; Cancel closes with null.
class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key, required this.current});

  final ThemeProfile current;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Theme'),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: RadioGroup<ThemeProfile>(
        groupValue: current,
        onChanged: (theme) => Navigator.pop(context, theme),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final theme in ThemeProfile.values)
              RadioListTile<ThemeProfile>(value: theme, title: Text(theme.label)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }
}
