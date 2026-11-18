import 'package:flutter/material.dart';
import 'package:go_translator/src/core/widgets/app_mark.dart';

/// The app bar of the pages with the drawer (translator, settings): menu
/// (from the Scaffold's drawer), the app icon and [title]. On the translator
/// page the languages live in the LanguageBar below it.
class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key, this.title = 'Translator'});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      titleSpacing: 4,
      title: Row(
        children: [
          const AppMark(size: 32),
          const SizedBox(width: 8),
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
