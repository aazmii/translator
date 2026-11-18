import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/core/widgets/app_mark.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/home.app.bar/home.app.bar.dart';
import 'package:go_translator/src/theme/themes/dark/dark.theme.dart';
import 'package:go_translator/src/theme/themes/light/light.theme.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child, {ThemeData? theme}) =>
      tester.pumpWidget(MaterialApp(theme: theme ?? lightTheme, home: Scaffold(body: Center(child: child))));

  testWidgets('the mark is a teal rounded square with the neutral translate glyph', (tester) async {
    await pump(tester, const AppMark());
    final box = tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration;
    expect(box.color, lightColorScheme.primary);
    expect(box.borderRadius, BorderRadius.circular(12));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.translate, reason: 'not g_translate, which resembles Google Translate\'s logo');
    expect(icon.size, 24);
    expect(icon.color, lightColorScheme.onPrimary);
    expect(tester.getSize(find.byType(AppMark)), const Size(40, 40));
  });

  testWidgets('it follows the theme (dark primary in dark mode)', (tester) async {
    await pump(tester, const AppMark(), theme: darkTheme);
    final box = tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration;
    expect(box.color, darkColorScheme.primary);
  });

  testWidgets('the app bar shows the mark at 32px instead of the old picture', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: lightTheme, home: const Scaffold(appBar: HomeAppbar())));
    expect(find.byType(AppMark), findsOneWidget);
    expect(tester.getSize(find.byType(AppMark)), const Size(32, 32));
    expect(find.byType(Image), findsNothing);
    expect(find.text('Translator'), findsOneWidget);
  });
}
