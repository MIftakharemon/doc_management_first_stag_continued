import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mutual_fund_app/app/data/models/mutual_fund.dart';
import 'package:mutual_fund_app/app/data/models/watchlist.dart';
import 'package:mutual_fund_app/app/data/providers/mutual_fund_provider.dart';
import 'package:mutual_fund_app/app/data/providers/watchlist_provider.dart';
import 'package:mutual_fund_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class WatchlistController extends GetxController {
  final MutualFundProvider _fundProvider = Get.find<MutualFundProvider>();
  final WatchlistProvider _watchlistProvider = Get.find<WatchlistProvider>();
  
  final RxList<Watchlist> watchlists = <Watchlist>[].obs;
  final RxList<MutualFund> allFunds = <MutualFund>[].obs;
  final RxList<MutualFund> filteredFunds = <MutualFund>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isAddingFunds = false.obs;
  final RxString selectedWatchlistId = ''.obs;
  
  final TextEditingController watchlistNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    loadData();
    
    // Listen to search query changes
    debounce(
      searchQuery,
      (_) => filterFunds(),
      time: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void onClose() {
    watchlistNameController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Load all mutual funds from mock data
      allFunds.value = await _fundProvider.getAllFunds();
      filteredFunds.value = allFunds;
      
      // Load watchlists from local storage
      watchlists.value = await _watchlistProvider.getWatchlists();
      
      // Set default selected watchlist if available
      if (watchlists.isNotEmpty && selectedWatchlistId.value.isEmpty) {
        selectedWatchlistId.value = watchlists[0].id;
      }
    } catch (e) {
      print('Error loading watchlist data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void filterFunds() {
    if (searchQuery.value.isEmpty) {
      filteredFunds.value = allFunds;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredFunds.value = allFunds.where((fund) {
        return fund.name.toLowerCase().contains(query) ||
               fund.category.toLowerCase().contains(query) ||
               fund.subcategory.toLowerCase().contains(query);
      }).toList();
    }
  }
  
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void selectWatchlist(String id) {
    selectedWatchlistId.value = id;
  }
  
  Future<void> createWatchlist() async {
    if (watchlistNameController.text.isEmpty) return;
    
    await _watchlistProvider.addWatchlist(watchlistNameController.text);
    watchlistNameController.clear();
    await loadData();
    
    // Refresh dashboard data
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
  }
  
  Future<void> renameWatchlist(String id, String newName) async {
    if (newName.isEmpty) return;
    
    await _watchlistProvider.renameWatchlist(id, newName);
    await loadData();
    
    // Refresh dashboard data
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
  }
  
  Future<void> deleteWatchlist(String id) async {
    await _watchlistProvider.deleteWatchlist(id);
    
    // Update selected watchlist if needed
    if (selectedWatchlistId.value == id) {
      if (watchlists.isNotEmpty) {
        selectedWatchlistId.value = watchlists[0].id;
      } else {
        selectedWatchlistId.value = '';
      }
    }
    
    await loadData();
    
    // Refresh dashboard data
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
  }
  
  Future<void> addFundToWatchlist(String fundId) async {
    if (selectedWatchlistId.value.isEmpty) return;
    
    await _watchlistProvider.addFundToWatchlist(selectedWatchlistId.value, fundId);
    await loadData();
    
    // Refresh dashboard data
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
  }
  
  Future<void> removeFundFromWatchlist(String fundId) async {
    if (selectedWatchlistId.value.isEmpty) return;
    
    await _watchlistProvider.removeFundFromWatchlist(selectedWatchlistId.value, fundId);
    await loadData();
    
    // Refresh dashboard data
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
  }
  
  void toggleAddFundsMode() {
    isAddingFunds.value = !isAddingFunds.value;
    searchQuery.value = '';
    searchController.clear();
  }
  
  Watchlist? getSelectedWatchlist() {
    if (selectedWatchlistId.value.isEmpty) return null;
    
    try {
      return watchlists.firstWhereOrNull((w) => w.id == selectedWatchlistId.value);
    } catch (e) {
      print('Error getting selected watchlist: $e');
      return null;
    }
  }
  
  // Check if a fund is in the selected watchlist
  bool isFundInSelectedWatchlist(String fundId) {
    final watchlist = getSelectedWatchlist();
    if (watchlist == null) return false;
    
    return watchlist.funds.any((fund) => fund.id == fundId);
  }
}
