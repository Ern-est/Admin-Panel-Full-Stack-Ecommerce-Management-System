import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StockPieChart extends StatelessWidget {
  final int available;
  final int limited;
  final int outOfStock;

  const StockPieChart({
    super.key,
    required this.available,
    required this.limited,
    required this.outOfStock,
  });

  @override
  Widget build(BuildContext context) {
    final total = available + limited + outOfStock;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: available.toDouble(),
            color: Colors.green,
            title: '${((available / total) * 100).toStringAsFixed(1)}%',
          ),
          PieChartSectionData(
            value: limited.toDouble(),
            color: Colors.orange,
            title: '${((limited / total) * 100).toStringAsFixed(1)}%',
          ),
          PieChartSectionData(
            value: outOfStock.toDouble(),
            color: Colors.red,
            title: '${((outOfStock / total) * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}
