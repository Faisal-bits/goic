class SearchConfig {
  final String date;
  final int year;
  String? isic;
  String? status;
  String? country;
  String? economicIndicator;
  String? industrialIndicator;
  String? product;
  String? comparisonMode;

  SearchConfig({
    required this.date,
    required this.year,
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
