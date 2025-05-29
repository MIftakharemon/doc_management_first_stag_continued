import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mutual_fund_app/app/data/models/mutual_fund.dart';

class MutualFundProvider extends GetxService {
  // Cache for funds to avoid repeated asset loading
  final RxList<MutualFund> _cachedFunds = <MutualFund>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Preload funds when the app starts
    getAllFunds();
  }
  
  // Load mock data from assets for mutual funds
  Future<List<MutualFund>> getAllFunds() async {
    try {
      // Return cached funds if available
      if (_cachedFunds.isNotEmpty) {
        return _cachedFunds;
      }
      
      isLoading.value = true;
      
      // Load mock data from assets
      final String response = await rootBundle.loadString('assets/data/mutual_funds.json');
      final data = await json.decode(response);
      
      final funds = (data['funds'] as List)
          .map((fund) => MutualFund.fromJson(fund))
          .toList();
      
      _cachedFunds.assignAll(funds);
      
      return _cachedFunds;
    } catch (e) {
      print('Error loading mutual funds: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<MutualFund?> getFundById(String id) async {
    try {
      if (_cachedFunds.isEmpty) {
        await getAllFunds();
      }
      
      return _cachedFunds.firstWhereOrNull((fund) => fund.id == id);
    } catch (e) {
      print('Error getting fund by ID: $e');
      return null;
    }
  }
  
  // Get funds by category
  Future<List<MutualFund>> getFundsByCategory(String category) async {
    try {
      final funds = await getAllFunds();
      return funds.where((fund) => fund.category == category).toList();
    } catch (e) {
      print('Error getting funds by category: $e');
      return [];
    }
  }
  
  // Search funds by name or category
  Future<List<MutualFund>> searchFunds(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllFunds();
      }
      
      final funds = await getAllFunds();
      final lowerQuery = query.toLowerCase();
      
      return funds.where((fund) => 
        fund.name.toLowerCase().contains(lowerQuery) ||
        fund.category.toLowerCase().contains(lowerQuery) ||
        fund.subcategory.toLowerCase().contains(lowerQuery)
      ).toList();
    } catch (e) {
      print('Error searching funds: $e');
      return [];
    }
  }
}
