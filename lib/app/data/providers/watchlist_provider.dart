import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mutual_fund_app/app/data/models/watchlist.dart';
import 'package:mutual_fund_app/app/data/models/mutual_fund.dart';
import 'package:mutual_fund_app/app/data/providers/mutual_fund_provider.dart';

class WatchlistProvider extends GetxService {
  final GetStorage _box = GetStorage();
  final String _watchlistsKey = 'watchlists';
  final RxBool isLoading = false.obs;
  
  // Use local storage (GetStorage) for watchlist persistence
  Future<List<Watchlist>> getWatchlists() async {
    try {
      isLoading.value = true;
      
      final MutualFundProvider fundProvider = Get.find<MutualFundProvider>();
      final String? watchlistsJson = _box.read<String>(_watchlistsKey);
      
      if (watchlistsJson == null || watchlistsJson.isEmpty) return [];
      
      final List<dynamic> watchlistsData = json.decode(watchlistsJson);
      final List<Watchlist> watchlists = [];
      
      for (var watchlistData in watchlistsData) {
        final watchlist = Watchlist.fromJson(watchlistData);
        final funds = <MutualFund>[];
        
        for (var fundId in watchlistData['funds']) {
          final fund = await fundProvider.getFundById(fundId);
          if (fund != null) {
            funds.add(fund);
          }
        }
        
        watchlist.funds = funds;
        watchlists.add(watchlist);
      }
      
      return watchlists;
    } catch (e) {
      print('Error getting watchlists: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    try {
      final watchlistsData = watchlists.map((w) => w.toJson()).toList();
      await _box.write(_watchlistsKey, json.encode(watchlistsData));
    } catch (e) {
      print('Error saving watchlists: $e');
    }
  }
  
  Future<void> addWatchlist(String name) async {
    try {
      if (name.isEmpty) return;
      
      final watchlists = await getWatchlists();
      final newWatchlist = Watchlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        funds: [],
      );
      
      watchlists.add(newWatchlist);
      await saveWatchlists(watchlists);
    } catch (e) {
      print('Error adding watchlist: $e');
    }
  }
  
  Future<void> deleteWatchlist(String id) async {
    try {
      if (id.isEmpty) return;
      
      final watchlists = await getWatchlists();
      watchlists.removeWhere((w) => w.id == id);
      await saveWatchlists(watchlists);
    } catch (e) {
      print('Error deleting watchlist: $e');
    }
  }
  
  Future<void> renameWatchlist(String id, String newName) async {
    try {
      if (id.isEmpty || newName.isEmpty) return;
      
      final watchlists = await getWatchlists();
      final index = watchlists.indexWhere((w) => w.id == id);
      
      if (index != -1) {
        watchlists[index].name = newName;
        await saveWatchlists(watchlists);
      }
    } catch (e) {
      print('Error renaming watchlist: $e');
    }
  }
  
  Future<void> addFundToWatchlist(String watchlistId, String fundId) async {
    try {
      if (watchlistId.isEmpty || fundId.isEmpty) return;
      
      final MutualFundProvider fundProvider = Get.find<MutualFundProvider>();
      final watchlists = await getWatchlists();
      final index = watchlists.indexWhere((w) => w.id == watchlistId);
      
      if (index != -1) {
        // Check if fund already exists in watchlist
        final alreadyExists = watchlists[index].funds.any((f) => f.id == fundId);
        if (alreadyExists) return;
        
        final fund = await fundProvider.getFundById(fundId);
        if (fund != null) {
          watchlists[index].funds.add(fund);
          await saveWatchlists(watchlists);
        }
      }
    } catch (e) {
      print('Error adding fund to watchlist: $e');
    }
  }
  
  Future<void> removeFundFromWatchlist(String watchlistId, String fundId) async {
    try {
      if (watchlistId.isEmpty || fundId.isEmpty) return;
      
      final watchlists = await getWatchlists();
      final index = watchlists.indexWhere((w) => w.id == watchlistId);
      
      if (index != -1) {
        watchlists[index].funds.removeWhere((f) => f.id == fundId);
        await saveWatchlists(watchlists);
      }
    } catch (e) {
      print('Error removing fund from watchlist: $e');
    }
  }
  
  // Check if a fund is in any watchlist
  Future<bool> isFundInAnyWatchlist(String fundId) async {
    try {
      final watchlists = await getWatchlists();
      return watchlists.any((watchlist) => 
        watchlist.funds.any((fund) => fund.id == fundId)
      );
    } catch (e) {
      print('Error checking if fund is in any watchlist: $e');
      return false;
    }
  }
  
  // Get all watchlists containing a specific fund
  Future<List<Watchlist>> getWatchlistsContainingFund(String fundId) async {
    try {
      final watchlists = await getWatchlists();
      return watchlists.where((watchlist) => 
        watchlist.funds.any((fund) => fund.id == fundId)
      ).toList();
    } catch (e) {
      print('Error getting watchlists containing fund: $e');
      return [];
    }
  }
}
