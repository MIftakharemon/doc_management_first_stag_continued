import 'package:get/get.dart';
import 'package:mutual_fund_app/app/data/providers/mutual_fund_provider.dart';
import 'package:mutual_fund_app/app/data/providers/watchlist_provider.dart';
import 'package:mutual_fund_app/app/modules/watchlist/controllers/watchlist_controller.dart';

class WatchlistBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure providers are registered
    if (!Get.isRegistered<MutualFundProvider>()) {
      Get.put<MutualFundProvider>(MutualFundProvider(), permanent: true);
    }
    
    if (!Get.isRegistered<WatchlistProvider>()) {
      Get.put<WatchlistProvider>(WatchlistProvider(), permanent: true);
    }
    
    Get.put<WatchlistController>(WatchlistController());
  }
}
