class MutualFund {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final double nav;
  final double oneDay;
  final double oneYear;
  final double threeYear;
  final double fiveYear;
  final double expenseRatio;
  final List<NavPoint> navHistory;

  MutualFund({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.nav,
    required this.oneDay,
    required this.oneYear,
    required this.threeYear,
    required this.fiveYear,
    required this.expenseRatio,
    required this.navHistory,
  });

  factory MutualFund.fromJson(Map<String, dynamic> json) {
    return MutualFund(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      nav: (json['nav'] ?? 0).toDouble(),
      oneDay: (json['one_day'] ?? 0).toDouble(),
      oneYear: (json['one_year'] ?? 0).toDouble(),
      threeYear: (json['three_year'] ?? 0).toDouble(),
      fiveYear: (json['five_year'] ?? 0).toDouble(),
      expenseRatio: (json['expense_ratio'] ?? 0).toDouble(),
      navHistory: json['nav_history'] != null 
          ? (json['nav_history'] as List).map((e) => NavPoint.fromJson(e)).toList()
          : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'nav': nav,
      'one_day': oneDay,
      'one_year': oneYear,
      'three_year': threeYear,
      'five_year': fiveYear,
      'expense_ratio': expenseRatio,
      'nav_history': navHistory.map((e) => e.toJson()).toList(),
    };
  }
  
  // Helper method to get color-coded performance
  bool get isPositiveDay => oneDay >= 0;
  bool get isPositiveYear => oneYear >= 0;
  bool get isPositiveThreeYear => threeYear >= 0;
  bool get isPositiveFiveYear => fiveYear >= 0;
}

class NavPoint {
  final DateTime date;
  final double value;

  NavPoint({
    required this.date,
    required this.value,
  });

  factory NavPoint.fromJson(Map<String, dynamic> json) {
    return NavPoint(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      value: (json['value'] ?? 0).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }
}
