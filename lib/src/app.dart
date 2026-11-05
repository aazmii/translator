import 'package:flutter/material.dart'
    show BuildContext, MaterialApp, MediaQuery, Placeholder, State, StatefulWidget, TextScaler, Widget;
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:go_translator/src/config/localization/app_localizations.dart';
import 'core/constants/constants.dart' show appName;
import 'core/extensions/extensions.dart' show BuildContextExtension;
import 'config/localization/loalization.dart' show localizationsDelegates, onGenerateTitle, supportedLocales, t;
import 'config/router/view/router.dart' show AppRouter;
import 'theme/model/theme.model.dart' show ThemeProfileExtension;
import 'theme/provider/theme.provider.dart' show themeProvider;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      localizationsDelegates: localizationsDelegates,
      theme: ref.watch(themeProvider).theme,
      supportedLocales: supportedLocales,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: onGenerateTitle,
      restorationScopeId: appName,
      home: const AppRouter(),
      builder: (context, child) {
        t = AppLocalizations.of(context)!;
        return MediaQuery(
          data: context.mq.copyWith(textScaler: const TextScaler.linear(1)),
          child: child ?? const AppRouter(),
        );
      },
    );
  }
}

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
