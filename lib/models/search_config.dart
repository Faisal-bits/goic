class SearchConfig {
  final String date;
  final int year;
  int? countryId;
  int? economicIndicatorId;
  int? industrialIndicatorId;
  int? comparisonCountryId;
  String? isic;
  String? status;
  String? country;
  String? economicIndicator;
  String? industrialIndicator;
  String? product;
  bool? comparisonMode;

  SearchConfig({
    required this.date,
    required this.year,
    this.countryId,
    this.economicIndicatorId,
    this.industrialIndicatorId,
    this.comparisonCountryId,
    this.isic,
    this.status,
    this.country,
    this.economicIndicator,
    this.industrialIndicator,
    this.product,
    this.comparisonMode,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'year': year,
        'isic': isic,
        'status': status,
        'country': country,
        'economicIndicator': economicIndicator,
        'industrialIndicator': industrialIndicator,
        'product': product,
        'comparisonMode': comparisonMode,
      };

  factory SearchConfig.fromJson(Map<String, dynamic> json) => SearchConfig(
        date: json['date'],
        year: json['year'],
        isic: json['isic'],
        status: json['status'],
        country: json['country'],
        economicIndicator: json['economicIndicator'],
        industrialIndicator: json['industrialIndicator'],
        product: json['product'],
        comparisonMode: json['comparisonMode'],
      );
}

class FTradeSearchConfig {
  final String date;
  final int year;
  final String tradeType;

  FTradeSearchConfig({
    required this.date,
    required this.year,
    required this.tradeType,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'year': year,
        'tradeType': tradeType,
      };

  factory FTradeSearchConfig.fromJson(Map<String, dynamic> json) {
    return FTradeSearchConfig(
      date: json['date'],
      year: json['year'],
      tradeType: json['tradeType'],
    );
  }
}

class SOESearchConfig {
  final String date;
  final int countryId;
  final int? comparisonCountryId;
  final int economicIndicatorId;
  final bool comparisonMode;

  SOESearchConfig({
    required this.date,
    required this.countryId,
    this.comparisonCountryId,
    required this.economicIndicatorId,
    required this.comparisonMode,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'countryId': countryId,
        'comparisonCountryId': comparisonCountryId,
        'economicIndicatorId': economicIndicatorId,
        'comparisonMode': comparisonMode,
      };

  factory SOESearchConfig.fromJson(Map<String, dynamic> json) {
    return SOESearchConfig(
      date: json['date'],
      countryId: json['countryId'],
      comparisonCountryId: json['comparisonCountryId'],
      economicIndicatorId: json['economicIndicatorId'],
      comparisonMode: json['comparisonMode'],
    );
  }
}
