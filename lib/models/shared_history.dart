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
