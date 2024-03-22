import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home': 'Home',
      'community': 'Community',
      'help': 'Help',
      'history': 'History',
      'profile': 'Profile',
      'logout': 'Logout',
      'language': 'Arabic Language',
    },
    'ar': {
      'home': 'الرئيسية',
      'community': 'المجتمع',
      'help': 'المساعدة',
      'history': 'التاريخ',
      'profile': 'الملف الشخصي',
      'logout': 'تسجيل خروج',
      'language': 'اللغة الإنجليزية',
    },
  };

  String get home {
    return _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  }

  String get community {
    return _localizedValues[locale.languageCode]?['community'] ?? 'Community';
  }

  String get help {
    return _localizedValues[locale.languageCode]?['help'] ?? 'Help';
  }

  String get history {
    return _localizedValues[locale.languageCode]?['history'] ?? 'History';
  }

  String get profile {
    return _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  }

  String get logout {
    return _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';
  }

  String get language {
    return _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
