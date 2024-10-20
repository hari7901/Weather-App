import 'package:flutter/material.dart';
import 'package:weather_app/services/storage_service.dart';
import 'services/api_service.dart';
import 'services/alert_service.dart';
import 'processors/data_processor.dart';
import 'models/models.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class WeatherDashboard extends StatefulWidget {
  @override
  _WeatherDashboardState createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  final ApiService _apiService = ApiService();
  final AlertService _alertService = AlertService();

  late DataProcessor _dataProcessor;
  List<String> cities = ['Mumbai', 'Chennai', 'Delhi', 'Kolkata', 'Hyderabad'];
  String selectedCity = 'Mumbai'; // Default selected city
  List<DailySummary> cityHistoricalData = [];
  List<Alert> _alerts = [];
  bool isLoading = true; // Flag for data loading state
  Set<String> citiesWithAlertShown = {}; // Keep track of cities with shown alerts
  bool useFahrenheit = false; // Flag to toggle between Celsius and Fahrenheit

  @override
  void initState() {
    super.initState();
    _dataProcessor = DataProcessor(
      storageService: StorageService(),
      alertService: _alertService,
      onDailySummaryUpdated: (city, summaries) {
        if (city == selectedCity) {
          setState(() {
            cityHistoricalData = summaries;
            isLoading = false; // Stop loading once data is fetched
          });
        }
      },
      onAlertTriggered: (alert) {
        // Show alert popup only if it hasn't been shown for the city
        if (!citiesWithAlertShown.contains(alert.city)) {
          _showAlertPopup(alert);
          citiesWithAlertShown.add(alert.city); // Mark this city as shown
        }
      },
      fetchInterval: Duration(minutes: 5), // Fetch data every 5 minutes
    );
    _dataProcessor.start();
  }

  @override
  void dispose() {
    _dataProcessor.stop();
    super.dispose();
  }

  // Function to convert Celsius to Fahrenheit
  int _convertToFahrenheit(int celsius) {
    return ((celsius * 9 / 5) + 32).round();
  }

  // Function to display temperature based on user's preference
  String _displayTemperature(int temperature) {
    return useFahrenheit
        ? '${_convertToFahrenheit(temperature)}°F'
        : '$temperature°C';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Weather Dashboard', style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedCity,
                onChanged: (String? newCity) {
                  if (newCity != null && newCity != selectedCity) {
                    setState(() {
                      selectedCity = newCity;
                      isLoading = true; // Start loading when new city is selected
                      _dataProcessor.start(); // Restart data fetch for the new city
                    });
                  }
                },
                items: cities.map<DropdownMenuItem<String>>((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
              ),
            ),
            // Toggle switch to choose between Celsius and Fahrenheit
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Celsius', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: useFahrenheit,
                    onChanged: (bool value) {
                      setState(() {
                        useFahrenheit = value;
                      });
                    },
                    activeTrackColor: Colors.lightBlueAccent,
                    activeColor: Colors.blue,
                  ),
                  Text('Fahrenheit', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
                : _buildCityWeatherData(cityHistoricalData),
            SizedBox(height: 20),
            cityHistoricalData.isNotEmpty
                ? Column(
              children: [
                _buildHistoricalBarChart(cityHistoricalData),
                SizedBox(height: 10),
                _buildChartLegend(),
              ],
            )
                : Center(child: Text('No historical data available for $selectedCity')),
          ],
        ),
      ),
    );
  }

  // UI for city weather data
  Widget _buildCityWeatherData(List<DailySummary> summaries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        DailySummary summary = summaries[index];
        return Card(
          margin: EdgeInsets.all(10),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.blueGrey[100],
                      child: Icon(
                        _getWeatherIcon(summary.mainCondition),
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${summary.city}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${summary.mainCondition}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Updated: ${summary.updateTime.toLocal()}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Temperature: ${_displayTemperature(summary.averageTemp)}',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Text('Feels Like: ${_displayTemperature(summary.feelsLike)}', style: TextStyle(fontSize: 14)),
                Text('Max Temp: ${_displayTemperature(summary.maxTemp)}', style: TextStyle(fontSize: 14)),
                Text('Min Temp: ${_displayTemperature(summary.minTemp)}', style: TextStyle(fontSize: 14)),
                Text('Humidity: ${summary.humidity}%', style: TextStyle(fontSize: 14)),
                Text('Wind Speed: ${summary.windSpeed} m/s', style: TextStyle(fontSize: 14)),
                Text('Reason: ${summary.reason}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fetch weather icon based on condition
  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'Sunny':
        return Icons.wb_sunny;
      case 'Rainy':
        return Icons.grain;
      case 'Cloudy':
        return Icons.wb_cloudy;
      case 'Snow':
        return Icons.ac_unit;
      default:
        return Icons.filter_drama; // Default icon for other conditions
    }
  }

  // Historical weather bar chart
  Widget _buildHistoricalBarChart(List<DailySummary> historicalSummaries) {
    List<charts.Series<DailySummary, String>> series = [
      charts.Series<DailySummary, String>(
        id: 'Average Temperature',
        data: historicalSummaries,
        domainFn: (DailySummary summary, _) => summary.date,
        measureFn: (DailySummary summary, _) => useFahrenheit
            ? _convertToFahrenheit(summary.averageTemp)
            : summary.averageTemp,
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
      ),
      charts.Series<DailySummary, String>(
        id: 'Feels Like',
        data: historicalSummaries,
        domainFn: (DailySummary summary, _) => summary.date,
        measureFn: (DailySummary summary, _) => useFahrenheit
            ? _convertToFahrenheit(summary.feelsLike)
            : summary.feelsLike,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
      charts.Series<DailySummary, String>(
        id: 'Max Temperature',
        data: historicalSummaries,
        domainFn: (DailySummary summary, _) => summary.date,
        measureFn: (DailySummary summary, _) => useFahrenheit
            ? _convertToFahrenheit(summary.maxTemp)
            : summary.maxTemp,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
      charts.Series<DailySummary, String>(
        id: 'Min Temperature',
        data: historicalSummaries,
        domainFn: (DailySummary summary, _) => summary.date,
        measureFn: (DailySummary summary, _) => useFahrenheit
            ? _convertToFahrenheit(summary.minTemp)
            : summary.minTemp,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
    ];

    return Container(
      height: 300,
      padding: EdgeInsets.all(10),
      child: charts.BarChart(
        series,
        animate: true,
        barGroupingType: charts.BarGroupingType.grouped,
      ),
    );
  }

  // Chart legend
  Widget _buildChartLegend() {
    return Column(
      children: <Widget>[
        _buildLegendItem("Average Temperature", Colors.yellow),
        _buildLegendItem("Feels Like", Colors.red),
        _buildLegendItem("Max Temperature", Colors.blue),
        _buildLegendItem("Min Temperature", Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  // Show an alert popup when an alert is triggered
  void _showAlertPopup(Alert alert) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert: ${alert.condition} in ${alert.city}'),
          content: Text(alert.message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
