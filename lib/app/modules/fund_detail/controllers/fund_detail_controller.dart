import 'package:get/get.dart';
import 'package:mutual_fund_app/app/data/models/mutual_fund.dart';
import 'package:mutual_fund_app/app/data/providers/watchlist_provider.dart';

class FundDetailController extends GetxController {
  final WatchlistProvider _watchlistProvider = Get.find<WatchlistProvider>();
  
  final Rx<MutualFund?> fund = Rx<MutualFund?>(null);
  final RxBool isInWatchlist = false.obs;
  final RxList<String> watchlistNames = <String>[].obs;
  final RxBool isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Get fund from arguments
    if (Get.arguments != null && Get.arguments is MutualFund) {
      fund.value = Get.arguments as MutualFund;
      checkWatchlistStatus();
    }
  }
  
  Future<void> checkWatchlistStatus() async {
    try {
      isLoading.value = true;
      
      if (fund.value == null) return;
      
      // Check if fund is in any watchlist
      final watchlists = await _watchlistProvider.getWatchlistsContainingFund(fund.value!.id);
      isInWatchlist.value = watchlists.isNotEmpty;
      
      // Get watchlist names
      watchlistNames.value = watchlists.map((w) => w.name).toList();
    } catch (e) {
      print('Error checking watchlist status: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> toggleWatchlist() async {
    try {
      if (fund.value == null) return;
      
      final watchlists = await _watchlistProvider.getWatchlists();
      
      if (watchlists.isEmpty) {
        // Create a default watchlist if none exists
        await _watchlistProvider.addWatchlist('My Watchlist');
        final updatedWatchlists = await _watchlistProvider.getWatchlists();
        
        if (updatedWatchlists.isNotEmpty) {
          await _watchlistProvider.addFundToWatchlist(
            updatedWatchlists[0].id, 
            fund.value!.id
          );
        }
      } else if (isInWatchlist.value) {
        // Remove from all watchlists
        for (final watchlist in watchlists) {
          if (watchlist.containsFund(fund.value!.id)) {
            await _watchlistProvider.removeFundFromWatchlist(
              watchlist.id, 
              fund.value!.id
            );
          }
        }
      } else {
        // Add to first watchlist
        await _watchlistProvider.addFundToWatchlist(
          watchlists[0].id, 
          fund.value!.id
        );
      }
      
      await checkWatchlistStatus();
    } catch (e) {
      print('Error toggling watchlist: $e');
    }
  }
}
