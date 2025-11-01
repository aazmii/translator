import 'package:flutter/material.dart';
import 'package:go_translator/src/config/router/provider/route.provider.dart';
import 'package:go_translator/src/modules/languages/presentation/view/offline.languages.view.dart';
import 'package:go_translator/src/modules/setting/view/setting.view.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(child: Text('Go Translator')),
          ListTile(
              onTap: () => fadePush(context, OfflineLanguagesView(title: 'Offline Languages')),
              title: Text('Offline Languages')),
          ListTile(onTap: () => fadePush(context, const SettingView()), title: Text('Settings')),
        ],
      ),
    );
  }
}
