import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'l10n/strings.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const SchalkeApp());
}

class SchalkeApp extends StatelessWidget {
  const SchalkeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app when either the language or the theme changes.
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, dark, __) {
        return ValueListenableBuilder<AppLocale>(
          valueListenable: localeNotifier,
          builder: (context, _, ___) {
            return MaterialApp(
              title: 'FC Schalke 04',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              locale: currentLocale,
              supportedLocales: const [Locale('de'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
