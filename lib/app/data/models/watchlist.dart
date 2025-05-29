import 'package:mutual_fund_app/app/data/models/mutual_fund.dart';

class Watchlist {
  String id;
  String name;
  List<MutualFund> funds;

  Watchlist({
    required this.id,
    required this.name,
    required this.funds,
  });

  factory Watchlist.fromJson(Map<String, dynamic> json) {
    return Watchlist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      funds: [],  // Funds will be populated separately
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'funds': funds.map((e) => e.id).toList(),
    };
  }
  
  // Helper method to check if a fund is in this watchlist
  bool containsFund(String fundId) {
    return funds.any((fund) => fund.id == fundId);
  }
}
