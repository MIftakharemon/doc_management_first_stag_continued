import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mutual_fund_app/app/modules/fund_detail/controllers/fund_detail_controller.dart';
import 'package:mutual_fund_app/app/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

class FundDetailView extends GetView<FundDetailController> {
  const FundDetailView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.fund.value == null
            ? const Text('Fund Details')
            : Text(
                controller.fund.value!.name,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
        actions: [
          Obx(() => controller.isLoading.value
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(
                    controller.isInWatchlist.value
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: controller.isInWatchlist.value ? Colors.blue : null,
                  ),
                  onPressed: controller.toggleWatchlist,
                  tooltip: controller.isInWatchlist.value
                      ? 'Remove from Watchlist'
                      : 'Add to Watchlist',
                )),
        ],
      ),
      body: Obx(() {
        if (controller.fund.value == null) {
          return const Center(
            child: Text('Fund not found'),
          );
        }
        
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }
        
        final fund = controller.fund.value!;
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFundHeader(fund),
                const SizedBox(height: 24),
                _buildWatchlistStatus(),
                const SizedBox(height: 24),
                _buildFundDetails(fund),
                const SizedBox(height: 24),
                _buildPastReturnsSection(fund),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildFundHeader(fund) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
      locale: 'en_IN',
    );
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fund.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${fund.category} | ${fund.subcategory}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NAV',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      currencyFormat.format(fund.nav),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '1 Day',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${fund.oneDay >= 0 ? '+' : ''}${fund.oneDay}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: fund.oneDay >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Expense Ratio',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${fund.expenseRatio}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWatchlistStatus() {
    return Obx(() {
      if (!controller.isInWatchlist.value) {
        return const SizedBox.shrink();
      }
      
      return Card(
        color: Colors.blue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(
                Icons.bookmark,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'In watchlist${controller.watchlistNames.isNotEmpty ? ': ${controller.watchlistNames.join(", ")}' : ''}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  
  Widget _buildFundDetails(fund) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fund Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Category', fund.category),
            _buildDetailRow('Subcategory', fund.subcategory),
            _buildDetailRow('Expense Ratio', '${fund.expenseRatio}%'),
            _buildDetailRow('NAV', '₹${fund.nav}'),
            _buildDetailRow('1 Day Return', '${fund.oneDay}%', 
              valueColor: fund.oneDay >= 0 ? Colors.green : Colors.red),
            _buildDetailRow('1 Year Return', '${fund.oneYear}%', 
              valueColor: fund.oneYear >= 0 ? Colors.green : Colors.red),
            _buildDetailRow('3 Year Return', '${fund.threeYear}%', 
              valueColor: fund.threeYear >= 0 ? Colors.green : Colors.red),
            _buildDetailRow('5 Year Return', '${fund.fiveYear}%', 
              valueColor: fund.fiveYear >= 0 ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPastReturnsSection(fund) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Past Returns',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildReturnCard('1Y', fund.oneYear),
                _buildReturnCard('3Y', fund.threeYear),
                _buildReturnCard('5Y', fund.fiveYear),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReturnCard(String period, double returnValue) {
    final isPositive = returnValue >= 0;
    
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            period,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${returnValue.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.snackbar(
                'Invest',
                'This feature is not implemented yet',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Invest'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('View Charts'),
          ),
        ),
      ],
    );
  }
}
