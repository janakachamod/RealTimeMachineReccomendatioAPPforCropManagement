import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'mongodb.dart'; // Import the MongoDB class to fetch data

class WaterDataGraph extends StatefulWidget {
  @override
  _WaterDataGraphState createState() => _WaterDataGraphState();
}

class _WaterDataGraphState extends State<WaterDataGraph> {
  List<double> waterData = [];
  double totalWaterLiters = 0.0; // Variable to hold the total sum in liters

  @override
  void initState() {
    super.initState();
    _fetchRecentWaterData();
  }

  Future<void> _fetchRecentWaterData() async {
    final data = await MongoDatabase.fetchWaterData();

    // Safely convert the 'value' to double, whether it's an int or already a double
    List<double> recentData = [];
    double total = 0.0; // Initialize total sum
    for (var entry in data.take(5)) {
      var value = entry['value'];
      if (value is int) {
        recentData.add(value.toDouble());
        total += value.toDouble(); // Add value to total
      } else if (value is double) {
        recentData.add(value);
        total += value; // Add value to total
      }
    }

    setState(() {
      waterData = recentData.reversed.toList(); // Reverse and set recent data
      totalWaterLiters = total; // Set the total sum in liters
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recent Water Data Graph")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total Water: ${totalWaterLiters.toStringAsFixed(2)} liters', // Display total sum in liters
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: waterData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: waterData.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value);
                            }).toList(),
                            isCurved: true,
                            barWidth: 3,
                            colors: [Colors.blue],
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        titlesData: FlTitlesData(show: true),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
