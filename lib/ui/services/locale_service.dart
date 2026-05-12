import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and restores the user-chosen app locale.
class LocaleService {
  static const _key = 'app.locale.v1';

  /// Returns the stored locale, or null if no override has been set.
  static Future<Locale?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final tag = prefs.getString(_key);
    if (tag == null) return null;
    final parts = tag.split('_');
    return parts.length == 2
        ? Locale(parts[0], parts[1])
        : Locale(parts[0]);
  }

  /// Persists the chosen locale.
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final tag = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await prefs.setString(_key, tag);
  }

  /// Clears the override; app will fall back to device locale.
  static Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
