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