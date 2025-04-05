import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatefulWidget {
  final Future<Map<String, double>> Function(String timeRange) fetchCategorySpending;
  final String? selectedValue;

  PieChartWidget({required this.fetchCategorySpending, this.selectedValue});

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  String selectedTimeRange = 'All Time'; // Default selected option
  late Future<Map<String, double>> spendingFuture; // Hold the dynamic data

  final List<Color> pieColors = [Colors.purple, Colors.orange, Colors.blue, Colors.red, Colors.green];

  @override
  void initState() {
    super.initState();
    spendingFuture = widget.fetchCategorySpending(selectedTimeRange); // Initialize with 'All Time' data
  }

  void updateTimeRange(String newRange) {
    setState(() {
      selectedTimeRange = newRange;
      spendingFuture = widget.fetchCategorySpending(selectedTimeRange); // Fetch new data
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: spendingFuture, // Dynamic future based on selectedTimeRange
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading data"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final data = snapshot.data!;
          final total = data.values.reduce((a, b) => a + b); // Calculate total for % and display

          // Build PieChart sections
          final sections = data.entries.map((entry) {
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            final index = data.keys.toList().indexOf(entry.key);

            return PieChartSectionData(
              value: entry.value,
              color: pieColors[index % pieColors.length],
              radius: 60,
              title: '$percentage%',
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time-range selector
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'Daily',
                        label: Text('Daily'),
                        icon: Icon(Icons.calendar_view_day),
                      ),
                      ButtonSegment<String>(
                        value: 'Weekly',
                        label: Text('Weekly'),
                        icon: Icon(Icons.calendar_view_week),
                      ),
                      ButtonSegment<String>(
                        value: 'All Time',
                        label: Text('Monthly'),
                        icon: Icon(Icons.timeline),
                      ),
                    ],
                    selected: <String>{selectedTimeRange},
                    onSelectionChanged: (Set<String> newSelection) {
                      updateTimeRange(newSelection.first);
                    },
                    showSelectedIcon: true,
                  ),
                ),
              ),

              // Display total spent
              
              // Pie Chart and Legend
              Expanded(
                flex: 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Pie Chart
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 40,
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    // Legend
                    Container(
                      width: 150,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: data.keys.map((key) {
                            final index = data.keys.toList().indexOf(key);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: pieColors[index % pieColors.length],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(key, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Center(
                  child: Text(
                    'Total Spent: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            ],
          );
        } else {
          return const Center(child: Text("No spending data available"));
        }
      },
    );
  }
}
