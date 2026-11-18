import 'package:flutter/material.dart';

/// The translator page's app bar: menu (from the Scaffold's drawer), the app
/// icon and the title. The languages live in the LanguageBar below it.
class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      titleSpacing: 4,
      title: Row(
        children: [
          Image.asset(
            'assets/icons/app_icon.png',
            height: 32,
            width: 32,
            errorBuilder: (_, _, _) => const SizedBox.square(dimension: 32),
          ),
          const SizedBox(width: 8),
          const Flexible(child: Text('Translator', overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
