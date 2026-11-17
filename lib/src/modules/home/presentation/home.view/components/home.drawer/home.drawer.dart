import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/router/provider/route.provider.dart';
import 'package:go_translator/src/modules/bookmarks/presentation/view/bookmarks.view.dart';
import 'package:go_translator/src/modules/languages/presentation/view/offline.languages.view.dart';
import 'package:go_translator/src/modules/setting/presentation/view/setting_view.dart';

import '../../providers/translator.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translation = ref.watch(translatorProvider).value;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(child: Text('Go Translator')),
          ListTile(
            onTap: () => fadePush(context, const BookmarksView()),
            title: Text('Bookmarks'),
          ),
          ListTile(
            onTap: () => fadePush(
              context,
              OfflineLanguagesView(
                title: 'Offline Languages',
                sourceLanguageCode: translation?.sourceLanguageCode,
                targetLanguageCode: translation?.targetLanguageCode,
              ),
            ),
            title: Text('Offline Languages'),
          ),
          ListTile(
            onTap: () => fadePush(context, const SettingView()),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
