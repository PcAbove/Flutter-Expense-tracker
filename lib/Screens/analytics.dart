import 'package:flutter/material.dart';
import 'package:expense_tracker/Database/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<StatisticsData> _statsFuture;

  bool _hideNumbers = true; // 🔹 Toggle for hiding numbers

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStatistics();
  }

  Future<StatisticsData> _loadStatistics() async {
    final dailyAvg = await _dbHelper.getDailyAverageSpending();
    final weeklyTotal = await _dbHelper.getWeeklyTotal();
    final monthlyTotal = await _dbHelper.getTotalExpenses();
    final monthlyIncome = await _dbHelper.getTotalIncome();
    final categories = await _dbHelper.getAllCategoriesTotal2();

    return StatisticsData(
      dailyAvg: dailyAvg,
      weeklyTotal: weeklyTotal,
      monthlyTotal: monthlyTotal,
      monthlyIncome: monthlyIncome,
      categories: categories,
      netSavings: monthlyIncome - monthlyTotal,
    );
  }

  String _formatValue(double value) {
    return _hideNumbers ? '****' : '\$${value.toStringAsFixed(2)}';
  }

  Widget _buildSummaryCard(String title, double value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Text(
              _formatValue(value),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetProgress(double current, double target, String label) {
    final progress = current / target;
    final percent = (progress * 100).clamp(0, 100).toInt();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 20,
              backgroundColor: Colors.grey[200],
              color: progress > 1 ? Colors.red : Colors.green,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent: ${_formatValue(current)}'),
                Text('Target: ${_formatValue(target)}'),
              ],
            ),
            SizedBox(height: 5),
            Text(
              _hideNumbers ? '' : '$percent% of target',
              style: TextStyle(color: progress > 1 ? Colors.red : Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, double> categories) {
    if (_hideNumbers) {
      // Show placeholder chart if hidden
      return Card(
        elevation: 4,
        child: Container(
          height: 250,
          alignment: Alignment.center,
          child: Text('Data hidden', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final total = categories.values.fold(0.0, (sum, value) => sum + value);
    final chartData = categories.entries
        .map((e) => _ChartData(e.key, e.value, e.value / total))
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Spending by Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 250,
              child: SfCircularChart(
                legend: Legend(
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap,
                    position: LegendPosition.bottom),
                series: <CircularSeries>[
                  PieSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.category,
                    yValueMapper: (_ChartData data, _) => data.amount,
                    dataLabelMapper: (_ChartData data, _) =>
                        '\$${data.amount.toStringAsFixed(2)} (${(data.percent * 100).toStringAsFixed(1)}%)',
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    pointColorMapper: (_ChartData data, _) =>
                        _getCategoryColor(data.category),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> categories) {
    if (_hideNumbers) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text('Data hidden', style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    final total = categories.values.fold(0.0, (sum, value) => sum + value);
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...sorted.map((entry) {
              final percent = entry.value / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                            '\$${entry.value.toStringAsFixed(2)} (${(percent * 100).toStringAsFixed(1)}%)'),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      color: _getCategoryColor(entry.key),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': Colors.amber,
      'Transport': Colors.blue,
      'Entertainment': Colors.purple,
      'Shopping': Colors.pink,
      'Utilities': Colors.teal,
      'Rent': Colors.brown,
      'Healthcare': Colors.red,
      'Income': Colors.green,
    };
    return colors[category] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Statistics'),
        actions: [
          IconButton(
            icon: Icon(_hideNumbers ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _hideNumbers = !_hideNumbers);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() => _statsFuture = _loadStatistics()),
          ),
        ],
      ),
      body: FutureBuilder<StatisticsData>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final categories = data.categories;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                          'Daily Avg', data.dailyAvg, Icons.today, Colors.blue),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildSummaryCard('Weekly Total', data.weeklyTotal,
                          Icons.calendar_view_week, Colors.purple),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard('Monthly Spending',
                          data.monthlyTotal, Icons.money_off, Colors.red),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildSummaryCard(
                          'Net Savings',
                          data.netSavings,
                          Icons.savings,
                          data.netSavings >= 0 ? Colors.green : Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Budget Targets Section
                Text('Budget Targets'),
                SizedBox(height: 10),
                _buildTargetProgress(data.monthlyTotal, 1500, 'Monthly'),
                SizedBox(height: 10),
                _buildTargetProgress(data.weeklyTotal, 400, 'Weekly'),
                SizedBox(height: 20),

                // Category Breakdown
                Text('Category Analysis'),
                SizedBox(height: 10),
                if (categories.isNotEmpty) ...[
                  _buildCategoryChart(categories),
                  SizedBox(height: 20),
                  _buildCategoryList(categories),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text('No spending data available')),
                    ),
                  )
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChartData {
  final String category;
  final double amount;
  final double percent;

  _ChartData(this.category, this.amount, this.percent);
}

class StatisticsData {
  final double dailyAvg;
  final double weeklyTotal;
  final double monthlyTotal;
  final double monthlyIncome;
  final Map<String, double> categories;
  final double netSavings;

  StatisticsData({
    required this.dailyAvg,
    required this.weeklyTotal,
    required this.monthlyTotal,
    required this.monthlyIncome,
    required this.categories,
    required this.netSavings,
  });
}
