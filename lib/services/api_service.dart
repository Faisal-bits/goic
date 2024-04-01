import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'https://mobile.goic.org.qa/api';

  Future<List<dynamic>> fetchCountries() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/countries/?format=json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Future<List<dynamic>> fetchCompanyStatuses() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/companystatuses/?format=json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load company statuses');
    }
  }

  Future<List<dynamic>> fetchISICCodes() async {
    final response = await http.get(Uri.parse('$_baseUrl/isic/?format=json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load ISIC codes');
    }
  }

  Future<List<dynamic>> fetchGIDStats(
      {int? year, int? countryId, int? isicCode}) async {
    String url = '$_baseUrl/gidstats/?format=json';
    if (year != null) {
      url += '&year=$year';
    }
    if (countryId != null) {
      url += '&countryid=$countryId';
    }
    if (isicCode != null) {
      url += '&isiccode__isiccode=$isicCode';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load GID stats');
    }
  }
}