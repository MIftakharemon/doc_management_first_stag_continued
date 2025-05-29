import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mutual_fund_app/app/modules/charts/controllers/charts_controller.dart';
import 'package:mutual_fund_app/app/widgets/loading_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartsView extends GetView<ChartsController> {
  const ChartsView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.selectedFund == null
            ? const Text('Charts')
            : Text(
                controller.selectedFund!.name,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
        bottom: TabBar(
          controller: controller.tabController,
          tabs: const [
            Tab(text: 'NAV'),
            Tab(text: 'Investment'),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.selectedFund == null) {
          return const Center(
            child: Text('Select a fund to view charts'),
          );
        }
        
        return TabBarView(
          controller: controller.tabController,
          children: [
            _buildNavChartTab(),
            _buildInvestmentChartTab(),
          ],
        );
      }),
    );
  }
  
  Widget _buildNavChartTab() {
    if (controller.selectedFund == null) {
      return const Center(child: Text('No fund selected'));
    }
    
    final fund = controller.selectedFund!;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFundHeader(fund),
            const SizedBox(height: 24),
            _buildNavChart(),
            const SizedBox(height: 16),
            _buildTimeRangeSelector(),
            const SizedBox(height: 24),
            _buildInvestmentCalculator(),
            const SizedBox(height: 24),
            _buildPastReturnsSection(fund),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInvestmentChartTab() {
    if (controller.selectedFund == null) {
      return const Center(child: Text('No fund selected'));
    }
    
    final fund = controller.selectedFund!;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFundHeader(fund),
            const SizedBox(height: 24),
            _buildInvestmentTypeSelector(),
            const SizedBox(height: 16),
            _buildInvestmentChart(),
            const SizedBox(height: 16),
            _buildTimeRangeSelector(),
            const SizedBox(height: 24),
            _buildInvestmentCalculator(),
            const SizedBox(height: 24),
            _buildPastReturnsSection(fund),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFundHeader(fund) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
      locale: 'en_IN',
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nav ${currencyFormat.format(fund.nav)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '1D ${fund.oneDay >= 0 ? '+' : ''}${fund.oneDay}%',
                  style: TextStyle(
                    color: fund.oneDay >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Invested',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Text(
                  '1.5k',
                  style: TextStyle(
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
                  'Current Value',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Text(
                  '1.28k',
                  style: TextStyle(
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
                  'Total Gain',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Text(
                  '-220.16 -14.7%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
                child: const Text(
                  'Your Investments -19.75%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Nifty Midcap 150 -12.97%',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildNavChart() {
    final navHistory = controller.getFilteredNavHistory();
    
    if (navHistory.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data available for the selected time range',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    final spots = navHistory.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final point = entry.value;
      return FlSpot(index, point.value);
    }).toList();
    
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= navHistory.length || value.toInt() < 0) {
                    return const SizedBox.shrink();
                  }
                  
                  if (navHistory.length <= 5) {
                    // Show all dates if there are 5 or fewer points
                    final date = navHistory[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('yyyy').format(date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    );
                  } else if (value.toInt() % (navHistory.length ~/ 5) == 0) {
                    // Show only 5 dates evenly distributed
                    final date = navHistory[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('yyyy').format(date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  if (index >= 0 && index < navHistory.length) {
                    final point = navHistory[index];
                    return LineTooltipItem(
                      '${DateFormat('dd-MM-yyyy').format(point.date)}\n₹${point.value.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
            touchCallback: (event, touchResponse) {
              if (event is FlTapUpEvent || event is FlPanEndEvent) {
                controller.selectDataPoint(null);
              } else if (touchResponse?.lineBarSpots != null && 
                         touchResponse!.lineBarSpots!.isNotEmpty) {
                final index = touchResponse.lineBarSpots![0].x.toInt();
                if (index >= 0 && index < navHistory.length) {
                  controller.selectDataPoint(navHistory[index]);
                }
              }
            },
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
  
  Widget _buildInvestmentChart() {
    final navHistory = controller.getFilteredNavHistory();
    
    if (navHistory.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data available for the selected time range',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    // Calculate investment growth
    final investmentType = controller.selectedInvestmentType.value;
    final firstNav = navHistory.first.value;
    
    // Prevent division by zero
    if (firstNav == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Invalid NAV data for calculations',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    List<FlSpot> investmentSpots = [];
    List<FlSpot> benchmarkSpots = [];
    
    if (investmentType == '1-Time') {
      // One-time investment
      final initialInvestment = controller.investmentAmount.value;
      
      investmentSpots = navHistory.asMap().entries.map((entry) {
        final index = entry.key.toDouble();
        final point = entry.value;
        final value = initialInvestment * (point.value / firstNav);
        return FlSpot(index, value);
      }).toList();
      
      // Benchmark (Nifty Midcap 150)
      benchmarkSpots = navHistory.asMap().entries.map((entry) {
        final index = entry.key.toDouble();
        // Simulate benchmark with slightly different performance
        final benchmarkValue = initialInvestment * 
            (1 + (entry.value.value / firstNav - 1) * 0.85); // 85% of fund performance
        return FlSpot(index, benchmarkValue);
      }).toList();
    } else {
      // Monthly SIP
      final monthlyAmount = controller.sipAmount.value;
      double totalInvestment = 0;
      double totalUnits = 0;
      
      investmentSpots = navHistory.asMap().entries.map((entry) {
        final index = entry.key.toDouble();
        final point = entry.value;
        
        if (index % 30 == 0) { // Approximate monthly intervals
          // Prevent division by zero
          if (point.value > 0) {
            final units = monthlyAmount / point.value;
            totalInvestment += monthlyAmount;
            totalUnits += units;
          }
        }
        
        final currentValue = totalUnits * point.value;
        return FlSpot(index, currentValue);
      }).toList();
      
      // Benchmark (Nifty Midcap 150)
      double benchmarkTotalInvestment = 0;
      double benchmarkTotalUnits = 0;
      
      benchmarkSpots = navHistory.asMap().entries.map((entry) {
        final index = entry.key.toDouble();
        final point = entry.value;
        
        if (index % 30 == 0) { // Approximate monthly intervals
          // Simulate benchmark with slightly different NAV
          final benchmarkNav = point.value * 0.95; // 95% of fund NAV
          
          // Prevent division by zero
          if (benchmarkNav > 0) {
            final units = monthlyAmount / benchmarkNav;
            benchmarkTotalInvestment += monthlyAmount;
            benchmarkTotalUnits += units;
          }
        }
        
        final currentValue = benchmarkTotalUnits * point.value * 0.95;
        return FlSpot(index, currentValue);
      }).toList();
    }
    
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= navHistory.length || value.toInt() < 0) {
                    return const SizedBox.shrink();
                  }
                  
                  if (navHistory.length <= 5) {
                    // Show all dates if there are 5 or fewer points
                    final date = navHistory[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('yyyy').format(date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    );
                  } else if (value.toInt() % (navHistory.length ~/ 5) == 0) {
                    // Show only 5 dates evenly distributed
                    final date = navHistory[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('yyyy').format(date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Your investment
            LineChartBarData(
              spots: investmentSpots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
            // Benchmark
            LineChartBarData(
              spots: benchmarkSpots,
              isCurved: true,
              color: Colors.grey,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5], // Dashed line
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  if (index >= 0 && index < navHistory.length) {
                    final point = navHistory[index];
                    final value = touchedSpot.y;
                    final currencyFormat = NumberFormat.currency(
                      symbol: '₹',
                      decimalDigits: 0,
                      locale: 'en_IN',
                    );
                    
                    return LineTooltipItem(
                      '${DateFormat('dd-MM-yyyy').format(point.date)}\n${currencyFormat.format(value)}',
                      const TextStyle(color: Colors.white),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
            touchCallback: (event, touchResponse) {
              if (event is FlTapUpEvent || event is FlPanEndEvent) {
                controller.selectDataPoint(null);
              } else if (touchResponse?.lineBarSpots != null && 
                         touchResponse!.lineBarSpots!.isNotEmpty) {
                final index = touchResponse.lineBarSpots![0].x.toInt();
                if (index >= 0 && index < navHistory.length) {
                  controller.selectDataPoint(navHistory[index]);
                }
              }
            },
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTimeRangeSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.timeRanges.length,
        itemBuilder: (context, index) {
          final range = controller.timeRanges[index];
          final isSelected = range == controller.selectedTimeRange.value;
          
          return GestureDetector(
            onTap: () => controller.setTimeRange(range),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInvestmentTypeSelector() {
    return Row(
      children: controller.investmentTypes.map((type) {
        final isSelected = type == controller.selectedInvestmentType.value;
        
        return GestureDetector(
          onTap: () => controller.setInvestmentType(type),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildInvestmentCalculator() {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    );
    
    final returns = controller.calculateInvestmentReturns();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.selectedInvestmentType.value == '1-Time'
              ? 'If you invested ${currencyFormat.format(controller.investmentAmount.value)}'
              : 'If you invested p.m ${currencyFormat.format(controller.sipAmount.value)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
                  'Saving A/C',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.selectedInvestmentType.value == '1-Time'
                      ? currencyFormat.format(controller.investmentAmount.value * 1.05) // 5% return
                      : currencyFormat.format(controller.sipAmount.value * 12 * 1.05), // 5% return
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Avg.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.selectedInvestmentType.value == '1-Time'
                      ? currencyFormat.format(controller.investmentAmount.value * 1.2) // 20% return
                      : currencyFormat.format(controller.sipAmount.value * 15), // Higher return
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Direct Plan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.selectedInvestmentType.value == '1-Time'
                      ? currencyFormat.format(returns.isNotEmpty && returns.containsKey('oneTime') ? returns['oneTime']['currentValue'] : 0)
                      : currencyFormat.format(returns.isNotEmpty && returns.containsKey('sip') ? returns['sip']['currentValue'] : 0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Sell action
                  Get.snackbar(
                    'Sell Order',
                    'This feature is not implemented yet',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Sell'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Invest more action
                  Get.snackbar(
                    'Invest More',
                    'This feature is not implemented yet',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Invest More ↑'),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPastReturnsSection(fund) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Fund\'s past returns',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Profit % (Absolute Return)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
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
}
