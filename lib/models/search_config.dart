class SearchConfig {
  final String date;
  final int year;
  final String isic;
  final String status;

  SearchConfig(
      {required this.date,
      required this.year,
      required this.isic,
      required this.status});

  Map<String, dynamic> toJson() => {
        'date': date,
        'year': year,
        'isic': isic,
        'status': status,
      };

  factory SearchConfig.fromJson(Map<String, dynamic> json) => SearchConfig(
        date: json['date'],
        year: json['year'],
        isic: json['isic'],
        status: json['status'],
      );
}
