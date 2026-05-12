import 'package:flutter/material.dart';

import 'i18n/app_strings.dart';

/// A supported language entry shown in the language picker.
class _LanguageOption {
  final Locale locale;
  final String flag;
  final String nativeName;

  const _LanguageOption({
    required this.locale,
    required this.flag,
    required this.nativeName,
  });
}

/// Language selection screen, accessible from the setup screen AppBar.
///
/// Calls [onLocaleSelected] with the chosen locale (or null for system default).
class LanguageScreen extends StatelessWidget {
  final Locale? currentLocale;
  final void Function(Locale?) onLocaleSelected;

  const LanguageScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleSelected,
  });

  static const List<_LanguageOption> _options = [
    _LanguageOption(locale: Locale('en'), flag: '🇬🇧', nativeName: 'English'),
    _LanguageOption(locale: Locale('pt', 'PT'), flag: '🇵🇹', nativeName: 'Português (Portugal)'),
    _LanguageOption(locale: Locale('pt', 'BR'), flag: '🇧🇷', nativeName: 'Português (Brasil)'),
    _LanguageOption(locale: Locale('es'), flag: '🇪🇸', nativeName: 'Español'),
    _LanguageOption(locale: Locale('fr'), flag: '🇫🇷', nativeName: 'Français'),
    _LanguageOption(locale: Locale('de'), flag: '🇩🇪', nativeName: 'Deutsch'),
    _LanguageOption(locale: Locale('it'), flag: '🇮🇹', nativeName: 'Italiano'),
  ];

  bool _isSelected(_LanguageOption opt) {
    if (currentLocale == null) return false;
    if (opt.locale.languageCode != currentLocale!.languageCode) return false;
    // If the option has a country code, it must match.
    if (opt.locale.countryCode != null && opt.locale.countryCode!.isNotEmpty) {
      return opt.locale.countryCode == (currentLocale!.countryCode ?? '');
    }
    // Option has no country code — matches if selected locale also has no
    // country code, or has a different one than any other option (fallback).
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.languageScreenTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // System default option
          ListTile(
            leading: const Text('🌐', style: TextStyle(fontSize: 24)),
            title: Text(strings.languageSystemDefault),
            trailing: currentLocale == null
                ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                : null,
            onTap: () {
              onLocaleSelected(null);
              Navigator.of(context).pop();
            },
          ),
          const Divider(height: 1),
          for (final opt in _options)
            ListTile(
              leading: Text(opt.flag, style: const TextStyle(fontSize: 24)),
              title: Text(opt.nativeName),
              trailing: _isSelected(opt)
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                onLocaleSelected(opt.locale);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
