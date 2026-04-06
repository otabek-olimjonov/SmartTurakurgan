import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('uz')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code != null) {
      state = _parse(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, _encode(locale));
  }

  static Locale _parse(String code) {
    final parts = code.split('_');
    if (parts.length == 1) return Locale(parts[0]);
    return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
  }

  static String _encode(Locale locale) {
    if (locale.scriptCode != null) {
      return '${locale.languageCode}_${locale.scriptCode}';
    }
    return locale.languageCode;
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());

/// Returns the translations map key for a given locale.
/// Uzbek Cyrillic → 'uz_Cyrl'; all others → languageCode.
String localeKey(Locale locale) {
  if (locale.scriptCode != null) return '${locale.languageCode}_${locale.scriptCode}';
  return locale.languageCode;
}

/// Human-readable locale names for the picker UI
const localeNames = [
  (Locale('uz'), "O'zbek (Lotin)"),
  (Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'), 'Ўзбек (Кирил)'),
  (Locale('ru'), 'Русский'),
  (Locale('en'), 'English'),
];
