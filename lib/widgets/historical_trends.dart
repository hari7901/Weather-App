import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../models/models.dart';

class HistoricalTrendsWidget extends StatelessWidget {
  final List<DailySummary> historicalSummaries;

  HistoricalTrendsWidget({required this.historicalSummaries});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<DailySummary, DateTime>> series = [
      charts.Series(
        id: 'Average Temperature',
        data: historicalSummaries,
        domainFn: (DailySummary summary, _) => summary.updateTime,
        measureFn: (DailySummary summary, _) => summary.averageTemp,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
      charts.Series(
        id: 'Max Temperature',
        data: historicalSummaries,
        domainFn: (DailySummary summary, _) => summary.updateTime,
        measureFn: (DailySummary summary, _) => summary.maxTemp,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
      charts.Series(
        id: 'Min Temperature',
        data: historicalSummaries,
        domainFn: (DailySummary summary, _) => summary.updateTime,
        measureFn: (DailySummary summary, _) => summary.minTemp,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
    ];

    return Container(
      height: 300,
      padding: EdgeInsets.all(10),
      child: charts.TimeSeriesChart(
        series,
        animate: true,
        behaviors: [
          charts.SeriesLegend(),
          charts.ChartTitle('Historical Temperature Trends',
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
        ],
      ),
    );
  }
}
