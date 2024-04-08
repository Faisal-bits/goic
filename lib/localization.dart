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
      'language': 'اللغة العربية',
      'welcome': 'Welcome, {name}',
      'trending': 'Trending 🔥',
      'gid': 'GCC Industrial Data',
      'fTrade': 'Foreign Trade Statistics',
      'socioEconomic': 'Socioeconomic Insights',
      'searchHistory': 'Search History',
      'todaysSearches': "Today's Searches",
      'yesterdaysSearches': "Yesterday's Searches",
      'searchesOn': "Searches on",
      'noRecentSearches': 'No recent searches',
      'delete': 'Delete',
      'info': 'Info',
      'chatBot': 'ChatBot',
      'typeYourMessage': 'Type your message here...',
      'whatIsThisApp': 'What is this app?',
      'howDoIUseIt': 'How do I use it?',
      'whatIsGID': 'What is GID?',
      'appExplanation':
          "This app is a mobile platform designed to make the Gulf Organization for Industrial Consulting (GOIC)'s rich databases on industrial development, economic information, and market trends in the GCC region accessible and user-friendly. It aims to promote entrepreneurship by providing real-time data on market and sector performance to both seasoned and novice investors.",
      'usageInstructions':
          'You can use it by registering and logging in with Firebase via Google, Apple, or email. Navigate through the app to access key widgets displaying GID, F Trade, and Socio-economic status. Utilize the history page to track past queries and interactions, and employ the help page for FAQs about the app and data systems.',
      'gidExplanation':
          'GID stands for Gulf Industrial Data, which includes comprehensive market analysis, investment opportunities, and industrial studies across the GCC. This data helps organizations and investors to make informed decisions by providing insights into more than 20 different market sectors in the region.',
      'typeYourMessageHere': 'Type your message here...',
      'communities': 'Communities',
      'createPost': 'Create Post',
      'whatsOnYourMind': "What's on your mind?",
      'submitPost': 'Submit Post',
      'likesReplies': '@likes Likes, @replies Replies',
      'error': 'Error',
      'loading': 'Loading...',
      'export': 'Export',
      'import': 'Import',
      'reExport': 'Re-Export',
      'Qatar': 'Qatar',
      'Saudi': 'Saudi',
      'UAE': 'UAE',
      'Bahrain': 'Bahrain',
      'Oman': 'Oman',
      'Kuwait': 'Kuwait',
      'upFrom': 'up from',
      'downFrom': 'down from',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'updateProfile': 'Update Profile',
      'saveChanges': 'Save Changes',
      'edit': 'Edit',
      'cancel': 'Cancel',
      'deleteAll': 'Delete All',
      'deleteTodays': 'Delete Today\'s',
    },
    'ar': {
      'home': 'الرئيسية',
      'community': 'المجتمع',
      'help': 'المساعدة',
      'history': 'التاريخ',
      'profile': 'الملف الشخصي',
      'logout': 'تسجيل خروج',
      'language': 'English Language',
      'welcome': 'مرحبًا، {name}',
      'trending': 'الأكثر رواجًا 🔥',
      'gid': 'بيانات الصناعة بدول مجلس التعاون',
      'fTrade': 'إحصاءات التجارة الخارجية',
      'socioEconomic': 'الرؤى الاقتصادية والاجتماعية',
      'searchHistory': 'سجل البحث',
      'todaysSearches': "بحوث اليوم",
      'yesterdaysSearches': "بحوث الأمس",
      'searchesOn': "بحوث في",
      'noRecentSearches': 'لا يوجد بحوث حديثة',
      'delete': 'حذف',
      'info': 'معلومات',
      'chatBot': 'روبوت الدردشة',
      'typeYourMessage': 'اكتب رسالتك هنا...',
      'whatIsThisApp': 'ما هذا التطبيق؟',
      'howDoIUseIt': 'كيف أستخدمه؟',
      'whatIsGID': 'ما هو GID؟',
      'appExplanation':
          'هذا التطبيق هو منصة متنقلة مصممة لجعل قواعد البيانات الغنية لمنظمة الخليج للاستشارات الصناعية (GOIC) حول التنمية الصناعية، المعلومات الاقتصادية، واتجاهات السوق في منطقة الخليج سهلة الوصول وودية للمستخدم. يهدف إلى تعزيز ريادة الأعمال من خلال توفير بيانات في الوقت الفعلي عن أداء السوق والقطاع لكل من المستثمرين المتمرسين والجدد.',
      'usageInstructions':
          'يمكنك استخدامه بالتسجيل والدخول عبر Firebase باستخدام Google، Apple، أو البريد الإلكتروني. تنقل عبر التطبيق للوصول إلى الأدوات الرئيسية التي تعرض GID، F Trade، والحالة الاقتصادية الاجتماعية. استخدم صفحة السجل لتتبع الاستعلامات والتفاعلات السابقة، واستفد من صفحة المساعدة للأسئلة الشائعة حول التطبيق وأنظمة البيانات.',
      'gidExplanation':
          'GID يعني بيانات الصناعة بالخليج، والتي تشمل تحليلات السوق الشاملة، فرص الاستثمار، والدراسات الصناعية عبر دول مجلس التعاون الخليجي. تساعد هذه البيانات المنظمات والمستثمرين على اتخاذ قرارات مستنيرة من خلال توفير رؤى حول أكثر من 20 قطاع سوق مختلف في المنطقة.',
      'typeYourMessageHere': 'اكتب رسالتك هنا...',
      'communities': 'المجتمعات',
      'createPost': 'إنشاء منشور',
      'whatsOnYourMind': 'ماذا يدور في ذهنك؟',
      'submitPost': 'إرسال المنشور',
      'likesReplies': '@likes إعجابات، @replies ردود',
      'error': 'خطأ',
      'loading': 'جار التحميل...',
      'export': 'تصدير',
      'import': 'استيراد',
      'reExport': 'إعادة التصدير',
      'Qatar': 'قطر',
      'Saudi': 'السعودية',
      'UAE': 'الإمارات',
      'Bahrain': 'البحرين',
      'Oman': 'عمان',
      'Kuwait': 'الكويت',
      'upFrom': 'زيادة من',
      'downFrom': 'انخفاض من',
      'firstName': 'الاسم الأول',
      'lastName': 'اسم العائلة',
      'updateProfile': 'تحديث الملف الشخصي',
      'saveChanges': 'حفظ التغييرات',
      'edit': 'تعديل',
      'cancel': 'إلغاء',
      'deleteAll': 'حذف الكل',
      'deleteTodays': 'حذف بحوث اليوم',
    },
  };

  String trendingItemDescription(
      String country, int year, String type, String change) {
    final String countryTranslation = getCountryName(country);
    final String typeTranslation = getTypeDescription(type);
    final String changeTranslation = translateChange(change);

    return "$countryTranslation $year $typeTranslation, $changeTranslation";
  }

  String translateChange(String change) {
    // Assuming 'change' comes in a format like "23% up from 2022"
    final RegExp regex = RegExp(r'(\d+%)( up from| down from) (\d+)');
    final match = regex.firstMatch(change);

    if (match != null) {
      final percentage = match.group(1)!;
      final direction =
          match.group(2)! == ' up from' ? getUpFrom() : getDownFrom();
      final year = match.group(3)!;

      return "$percentage $direction $year";
    }
    return change; // Fallback if the format does not match
  }

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

  String get trending =>
      _localizedValues[locale.languageCode]?['trending'] ?? 'Trending';
  String get gid =>
      _localizedValues[locale.languageCode]?['gid'] ?? 'GCC Industrial Data';
  String get fTrade =>
      _localizedValues[locale.languageCode]?['fTrade'] ??
      'Foreign Trade Statistics';
  String get socioEconomic =>
      _localizedValues[locale.languageCode]?['socioEconomic'] ??
      'Socioeconomic Insights';

  String welcome(String name) {
    return _localizedValues[locale.languageCode]?['welcome']
            ?.replaceAll('{name}', name) ??
        'Welcome, $name';
  }

  String get searchHistory {
    return _localizedValues[locale.languageCode]?['searchHistory'] ??
        'Search History';
  }

  String get todaysSearches {
    return _localizedValues[locale.languageCode]?['todaysSearches'] ??
        "Today's Searches";
  }

  String get yesterdaysSearches {
    return _localizedValues[locale.languageCode]?['yesterdaysSearches'] ??
        "Yesterday's Searches";
  }

  String get searchesOn {
    return _localizedValues[locale.languageCode]?['searchesOn'] ??
        "Searches on";
  }

  String get noRecentSearches {
    return _localizedValues[locale.languageCode]?['noRecentSearches'] ??
        'No recent searches';
  }

  String get delete {
    return _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  }

  String get info => _localizedValues[locale.languageCode]?['info'] ?? 'Info';
  String get chatBot =>
      _localizedValues[locale.languageCode]?['chatBot'] ?? 'ChatBot';
  String get typeYourMessage =>
      _localizedValues[locale.languageCode]?['typeYourMessage'] ??
      'Type your message here...';

  String get whatIsThisApp {
    return _localizedValues[locale.languageCode]?['whatIsThisApp'] ??
        'What is this app?';
  }

  String get howDoIUseIt {
    return _localizedValues[locale.languageCode]?['howDoIUseIt'] ??
        'How do I use it?';
  }

  String get whatIsGID {
    return _localizedValues[locale.languageCode]?['whatIsGID'] ??
        'What is GID?';
  }

  String get appExplanation {
    return _localizedValues[locale.languageCode]?['appExplanation'] ??
        'This app is...';
  }

  String get usageInstructions {
    return _localizedValues[locale.languageCode]?['usageInstructions'] ??
        'You can use it by...';
  }

  String get gidExplanation {
    return _localizedValues[locale.languageCode]?['gidExplanation'] ??
        'GID stands for...';
  }

  String get typeYourMessageHere {
    return _localizedValues[locale.languageCode]?['typeYourMessageHere'] ??
        'Type your message here...';
  }

  String get communities =>
      _localizedValues[locale.languageCode]?['communities'] ?? 'Communities';
  String get createPost =>
      _localizedValues[locale.languageCode]?['createPost'] ?? 'Create Post';
  String get whatsOnYourMind =>
      _localizedValues[locale.languageCode]?['whatsOnYourMind'] ??
      "What's on your mind?";
  String get submitPost =>
      _localizedValues[locale.languageCode]?['submitPost'] ?? 'Submit Post';

  String getCountryName(String countryKey) {
    return _localizedValues[locale.languageCode]?[countryKey] ?? countryKey;
  }

  String getTypeDescription(String typeKey) {
    return _localizedValues[locale.languageCode]?[typeKey.toLowerCase()] ??
        typeKey;
  }

  String getUpFrom() =>
      _localizedValues[locale.languageCode]?['upFrom'] ?? 'up from';

  String getDownFrom() =>
      _localizedValues[locale.languageCode]?['downFrom'] ?? 'down from';

  String get firstName {
    return _localizedValues[locale.languageCode]?['firstName'] ?? 'First Name';
  }

  String get lastName {
    return _localizedValues[locale.languageCode]?['lastName'] ?? 'Last Name';
  }

  String get saveChanges {
    return _localizedValues[locale.languageCode]?['saveChanges'] ??
        'Save Changes';
  }

  String get edit {
    return _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  }

  String get cancel {
    return _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  }

  String get deleteAll =>
      _localizedValues[locale.languageCode]?['deleteAll'] ?? 'Delete All';

  String get deleteTodays =>
      _localizedValues[locale.languageCode]?['deleteTodays'] ??
      'Delete Today\'s';
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
