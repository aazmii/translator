import 'package:flutter/material.dart' show BuildContext, Locale;

import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalMaterialLocalizations, GlobalWidgetsLocalizations;
import 'package:go_translator/src/config/localization/app_localizations.dart' show AppLocalizations;

AppLocalizations? t;

const localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const supportedLocales = [Locale('en', '')];

String onGenerateTitle(BuildContext context) => AppLocalizations.of(context)!.appTitle;
