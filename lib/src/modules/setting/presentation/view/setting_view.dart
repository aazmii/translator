import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/provider/theme.provider.dart';
import '../../domain/entities/theme_profile.dart';
import '../providers/settings_provider.dart';

class SettingView extends ConsumerWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.read(settingsProvider.notifier).toggleTheme(),
          child: Text(
            theme == ThemeProfile.dark
                ? 'Change Theme to Light'
                : 'Change Theme to Dark',
          ),
        ),
      ),
    );
  }
}
