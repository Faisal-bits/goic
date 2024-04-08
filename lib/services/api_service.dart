import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'https://mobile.goic.org.qa/api';
  static const String baseApiKey = 'goic-api-key';

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

  Future<List<dynamic>> fetchFtradeNumbers({
    required int year,
    required String id,
    required int import,
    required int reexport,
    required int export,
  }) async {
    String url = '$_baseUrl/ftrade/?format=json';
    if (year != null) {
      url += '&year=$year';
    }
    if (id != null) {
      url += '&product_type=$id';
    }
    if (import != null) {
      url += '&imports=$import';
    }
    if (reexport != null) {
    url += '&re_exports=$reexport';
  }
    if (export != null) {
      url += '&exports=$export';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Ftrade ');
    }
  }

  Future<List<dynamic>> fetchSocioEconNumbers({
    required String economicIndicator,
    required String industrialIndicator,
    required String countryId,
  }) async {
    String url = '$_baseUrl/soecdata/?format=json';
    if (economicIndicator != null) {
      url += '&soecid=$economicIndicator';
    }
    if (industrialIndicator != null) {
      url += '&value=$industrialIndicator';
    }
    if (countryId != null) {
      url += '&countryid=$countryId';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Soecdata');
    }
  }

}
