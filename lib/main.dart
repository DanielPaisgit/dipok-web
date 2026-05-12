import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ui/services/locale_service.dart';
import 'ui/setup_screen.dart';

void main() {
  runApp(const DipokApp());
}

/// InheritedWidget that exposes the locale-change callback down the tree.
class LocaleController extends InheritedWidget {
  final Locale? currentLocale;
  final void Function(Locale?) setLocale;

  const LocaleController({
    super.key,
    required this.currentLocale,
    required this.setLocale,
    required super.child,
  });

  static LocaleController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleController>();
  }

  @override
  bool updateShouldNotify(LocaleController old) =>
      currentLocale != old.currentLocale;
}

class DipokApp extends StatefulWidget {
  const DipokApp({super.key});

  @override
  State<DipokApp> createState() => _DipokAppState();
}

class _DipokAppState extends State<DipokApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await LocaleService.loadLocale();
    if (locale != null && mounted) {
      setState(() => _locale = locale);
    }
  }

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
    if (locale == null) {
      LocaleService.clearLocale();
    } else {
      LocaleService.saveLocale(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleController(
      currentLocale: _locale,
      setLocale: _setLocale,
      child: MaterialApp(
        title: 'Dice Poker',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1B5E20),
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF1B5E20),
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('pt', 'PT'),
          Locale('pt', 'BR'),
          Locale('pt'),
          Locale('es'),
          Locale('fr'),
          Locale('de'),
          Locale('it'),
        ],
        home: const SetupScreen(),
      ),
    );
  }
}

