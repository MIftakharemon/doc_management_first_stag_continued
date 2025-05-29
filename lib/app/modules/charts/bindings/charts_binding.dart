import 'package:get/get.dart';
import 'package:mutual_fund_app/app/modules/charts/controllers/charts_controller.dart';
import 'package:mutual_fund_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class ChartsBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DashboardController is registered
    if (!Get.isRegistered<DashboardController>()) {
      Get.put<DashboardController>(DashboardController());
    }
    
    Get.put<ChartsController>(ChartsController());
  }
}
