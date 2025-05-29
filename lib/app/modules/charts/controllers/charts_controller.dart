import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mutual_fund_app/app/data/models/mutual_fund.dart';
import 'package:mutual_fund_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class ChartsController extends GetxController with GetSingleTickerProviderStateMixin {
  final DashboardController _dashboardController = Get.find<DashboardController>();
  
  late TabController tabController;
  final RxString selectedTimeRange = '1Y'.obs;
  final RxString selectedChartType = 'NAV'.obs;
  final RxString selectedInvestmentType = '1-Time'.obs;
  final RxDouble investmentAmount = 100000.0.obs; // 1L default
  final RxDouble sipAmount = 1000.0.obs; // 1k default
  final RxBool showTooltip = false.obs;
  final Rx<NavPoint?> selectedPoint = Rx<NavPoint?>(null);
  
  final List<String> timeRanges = ['1M', '3M', '6M', '1Y', '3Y', 'MAX'];
  final List<String> chartTypes = ['NAV', 'Investment'];
  final List<String> investmentTypes = ['1-Time', 'Monthly SIP'];
  
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        if (tabController.index == 0) {
          selectedChartType.value = 'NAV';
        } else {
          selectedChartType.value = 'Investment';
        }
      }
    });
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
  
  MutualFund? get selectedFund => _dashboardController.selectedFund.value;
  
  void setTimeRange(String range) {
    selectedTimeRange.value = range;
  }
  
  void setChartType(String type) {
    selectedChartType.value = type;
    if (type == 'NAV') {
      tabController.animateTo(0);
    } else {
      tabController.animateTo(1);
    }
  }
  
  void setInvestmentType(String type) {
    selectedInvestmentType.value = type;
  }
  
  void setInvestmentAmount(double amount) {
    investmentAmount.value = amount;
  }
  
  void setSipAmount(double amount) {
    sipAmount.value = amount;
  }
  
  void selectDataPoint(NavPoint? point) {
    selectedPoint.value = point;
    showTooltip.value = point != null;
  }
  
  List<NavPoint> getFilteredNavHistory() {
    if (selectedFund == null) return [];
    
    final now = DateTime.now();
    final navHistory = selectedFund!.navHistory;
    
    switch (selectedTimeRange.value) {
      case '1M':
        final oneMonthAgo = now.subtract(const Duration(days: 30));
        return navHistory.where((point) => point.date.isAfter(oneMonthAgo)).toList();
      case '3M':
        final threeMonthsAgo = now.subtract(const Duration(days: 90));
        return navHistory.where((point) => point.date.isAfter(threeMonthsAgo)).toList();
      case '6M':
        final sixMonthsAgo = now.subtract(const Duration(days: 180));
        return navHistory.where((point) => point.date.isAfter(sixMonthsAgo)).toList();
      case '1Y':
        final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
        return navHistory.where((point) => point.date.isAfter(oneYearAgo)).toList();
      case '3Y':
        final threeYearsAgo = DateTime(now.year - 3, now.month, now.day);
        return navHistory.where((point) => point.date.isAfter(threeYearsAgo)).toList();
      case 'MAX':
      default:
        return navHistory;
    }
  }
  
  // Calculate investment returns based on NAV history
  Map<String, dynamic> calculateInvestmentReturns() {
    if (selectedFund == null) return {};
    
    final navHistory = getFilteredNavHistory();
    if (navHistory.isEmpty) return {};
    
    final firstNav = navHistory.first.value;
    final lastNav = navHistory.last.value;
    
    // Prevent division by zero
    if (firstNav == 0) return {};
    
    final navGrowth = lastNav / firstNav;
    
    // For one-time investment
    final oneTimeInvestment = investmentAmount.value;
    final oneTimeCurrentValue = oneTimeInvestment * navGrowth;
    final oneTimeGain = oneTimeCurrentValue - oneTimeInvestment;
    final oneTimeGainPercent = oneTimeInvestment > 0 ? (oneTimeGain / oneTimeInvestment) * 100 : 0;
    
    // For SIP investment
    double totalSipInvestment = 0;
    double sipCurrentValue = 0;
    
    if (selectedInvestmentType.value == 'Monthly SIP' && navHistory.length > 1) {
      final monthlyAmount = sipAmount.value;
      
      for (int i = 0; i < navHistory.length; i++) {
        if (i % 30 == 0) { // Approximate monthly intervals
          final navPoint = navHistory[i];
          
          // Prevent division by zero
          if (navPoint.value > 0) {
            final navRatio = lastNav / navPoint.value;
            totalSipInvestment += monthlyAmount;
            sipCurrentValue += monthlyAmount * navRatio;
          }
        }
      }
    }
    
    final sipGain = sipCurrentValue - totalSipInvestment;
    final sipGainPercent = totalSipInvestment > 0 ? (sipGain / totalSipInvestment) * 100 : 0;
    
    return {
      'oneTime': {
        'investment': oneTimeInvestment,
        'currentValue': oneTimeCurrentValue,
        'gain': oneTimeGain,
        'gainPercent': oneTimeGainPercent,
      },
      'sip': {
        'investment': totalSipInvestment,
        'currentValue': sipCurrentValue,
        'gain': sipGain,
        'gainPercent': sipGainPercent,
      },
    };
  }
}
