import 'package:flutter/material.dart';
import '../models/models.dart'; // Adjust path to where your models are

class VisualizationWidget extends StatelessWidget {
  final List<DailySummary> dailySummaries;
  final List<Alert> alerts;

  VisualizationWidget({
    required this.dailySummaries,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          dailySummaries.isEmpty
              ? Text("No daily summaries available")
              : _buildDailySummariesList(),
          SizedBox(height: 20),
          _buildAlertsSection(),
        ],
      ),
    );
  }

  Widget _buildDailySummariesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: dailySummaries.length,
      itemBuilder: (context, index) {
        DailySummary summary = dailySummaries[index];
        DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(summary.dt * 1000);

        return Card(
          child: ListTile(
            title: Text('${summary.date} Summary'),
            subtitle: Text(
              'Main Condition: ${summary.mainCondition}\n'
                  'Avg Temp: ${summary.averageTemp}°C\n'
                  'Max Temp: ${summary.maxTemp}°C\n'
                  'Min Temp: ${summary.minTemp}°C\n'
                  'Feels Like: ${summary.feelsLike}°C\n'
                  'Dominant Condition: ${summary.dominantCondition}\n'
                  'Reason: ${summary.reason}\n'
                  'Last Updated: ${lastUpdate.toLocal()}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildAlertsSection() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        Alert alert = alerts[index];
        return Card(
          color: Colors.red[100],
          child: ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text('${alert.city} - ${alert.condition}'),
            subtitle: Text('${alert.message}\nTriggered at: ${alert.alertTime.toLocal()}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
