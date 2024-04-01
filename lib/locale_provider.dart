import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale.languageCode);
  }

  void loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }
}

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('ar'),
  ];
}
