import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'search_config.dart';

Future<void> saveSearchHistory(List<SearchConfig> history) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> stringList =
      history.map((config) => jsonEncode(config.toJson())).toList();
  await prefs.setStringList('searchHistory', stringList);
}

Future<List<SearchConfig>> loadSearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? stringList = prefs.getStringList('searchHistory');
  if (stringList == null) return [];
  return stringList
      .map((stringConfig) => SearchConfig.fromJson(jsonDecode(stringConfig)))
      .toList();
}

Future<void> deleteSearchFromHistory(SearchConfig configToDelete) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? stringList = prefs.getStringList('searchHistory');
  if (stringList != null) {
    // Find the index of the config to delete based on its attributes
    int indexToDelete = stringList.indexWhere((stringConfig) {
      SearchConfig config = SearchConfig.fromJson(jsonDecode(stringConfig));
      // Because 'date', 'year', 'isic', and 'status' combined can uniquely identify a search config
      return config.date == configToDelete.date &&
          config.year == configToDelete.year &&
          config.isic == configToDelete.isic &&
          config.status == configToDelete.status;
    });

    // If found, remove the config from the list
    if (indexToDelete != -1) {
      stringList.removeAt(indexToDelete);
      // Save the updated list back to shared preferences
      await prefs.setStringList('searchHistory', stringList);
    }
  }
}

// New functions for FTradeSearchConfig

Future<void> saveFTradeSearchHistory(List<FTradeSearchConfig> history) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> stringList =
      history.map((config) => jsonEncode(config.toJson())).toList();
  await prefs.setStringList('fTradeSearchHistory', stringList);
}

Future<List<FTradeSearchConfig>> loadFTradeSearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? stringList = prefs.getStringList('fTradeSearchHistory');
  if (stringList == null) return [];
  return stringList
      .map((stringConfig) =>
          FTradeSearchConfig.fromJson(jsonDecode(stringConfig)))
      .toList();
}

Future<void> deleteFTradeSearchFromHistory(
    FTradeSearchConfig configToDelete) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? stringList = prefs.getStringList('fTradeSearchHistory');
  if (stringList != null) {
    // Find the index of the config to delete based on its attributes
    int indexToDelete = stringList.indexWhere((stringConfig) {
      FTradeSearchConfig config =
          FTradeSearchConfig.fromJson(jsonDecode(stringConfig));
      return config.date == configToDelete.date &&
          config.year == configToDelete.year &&
          config.tradeType == configToDelete.tradeType;
    });

    // If found, remove the config from the list
    if (indexToDelete != -1) {
      stringList.removeAt(indexToDelete);
      // Save the updated list back to shared preferences
      await prefs.setStringList('fTradeSearchHistory', stringList);
    }
  }
}

Future<void> saveSOESearchHistory(List<SOESearchConfig> history) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> stringList =
      history.map((config) => jsonEncode(config.toJson())).toList();
  await prefs.setStringList('soeSearchHistory', stringList);
}

Future<List<SOESearchConfig>> loadSOESearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? stringList = prefs.getStringList('soeSearchHistory');
  if (stringList == null) return [];
  return stringList
      .map((stringConfig) => SOESearchConfig.fromJson(jsonDecode(stringConfig)))
      .toList();
}

Future<void> deleteSOESearchFromHistory(SOESearchConfig configToDelete) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? stringList = prefs.getStringList('soeSearchHistory');
  if (stringList != null) {
    int indexToDelete = stringList.indexWhere((stringConfig) {
      SOESearchConfig config =
          SOESearchConfig.fromJson(jsonDecode(stringConfig));
      return config.date == configToDelete.date &&
          config.countryId == configToDelete.countryId &&
          config.comparisonCountryId == configToDelete.comparisonCountryId &&
          config.economicIndicatorId == configToDelete.economicIndicatorId &&
          config.comparisonMode == configToDelete.comparisonMode;
    });

    if (indexToDelete != -1) {
      stringList.removeAt(indexToDelete);
      await prefs.setStringList('soeSearchHistory', stringList);
    }
  }
}
