import 'dart:async';
import '../models/models.dart';
import '../services/alert_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DataProcessor {
  final ApiService _apiService = ApiService(); // Fetch weather data from API
  final StorageService _storageService; // For storing summaries and alerts
  final AlertService _alertService; // For triggering alerts
  Timer? _timer; // Timer to trigger API calls at intervals

  final Duration fetchInterval; // Fetch interval is now configurable (e.g., 1 minute)
  final Map<String, List<WeatherData>> _cityWeatherData = {}; // Store data for each city
  final Map<String, int> _alertCounters = {}; // Track city-specific alert counters

  final Function(String, List<DailySummary>) onDailySummaryUpdated; // Callback when data is updated
  final Function(Alert) onAlertTriggered; // Callback when an alert is triggered

  DataProcessor({
    required StorageService storageService,
    required AlertService alertService,
    required this.onDailySummaryUpdated,
    required this.onAlertTriggered,
    required this.fetchInterval,
  })  : _storageService = storageService,
        _alertService = alertService;

  // Start the data fetching process
  void start() {
    _fetchAndProcessData(); // Immediately fetch data
    _timer = Timer.periodic(fetchInterval, (timer) {
      _fetchAndProcessData(); // Fetch data at every interval
    });
  }

  // Stop the data fetching process
  void stop() {
    _timer?.cancel();
  }

  // Fetch and process weather data
  Future<void> _fetchAndProcessData() async {
    try {
      List<WeatherData> weatherData = await _apiService.fetchWeatherData(); // Fetch data from API
      _cityWeatherData.clear();
      for (var data in weatherData) {
        // Group data by city
        if (_cityWeatherData.containsKey(data.city)) {
          _cityWeatherData[data.city]!.add(data);
        } else {
          _cityWeatherData[data.city] = [data];
        }
      }
      _processRollups(); // Process the data for summaries
      _checkAlerts(weatherData); // Check for any alerts
    } catch (e) {
      print('Error fetching or processing data: $e');
    }
  }

  // Process data and generate daily summaries
  void _processRollups() async {
    String today = DateTime.now().toIso8601String().split('T')[0];

    _cityWeatherData.forEach((city, cityData) async {
      List<WeatherData> todayData = cityData.where((data) => data.updateTime.toIso8601String().split('T')[0] == today).toList();
      if (todayData.isEmpty) return;

      // Calculate average, max, and min temperatures for the city
      int averageTemp = (todayData.map((e) => e.temperature).reduce((a, b) => a + b) / todayData.length).round();
      int maxTemp = todayData.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
      int minTemp = todayData.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
      int feelsLike = todayData.first.feelsLike;
      int humidity = todayData.first.humidity; // Fetch humidity from the first data point
      double windSpeed = todayData.first.windSpeed; // Fetch wind speed from the first data point

      // Determine the dominant weather condition
      Map<String, int> conditionCounts = {};
      for (var entry in todayData) {
        conditionCounts[entry.mainCondition] = (conditionCounts[entry.mainCondition] ?? 0) + 1;
      }
      String dominantCondition = conditionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      String reason = 'Most frequent condition: $dominantCondition';

      // Create a summary for this city
      List<DailySummary> summaries = [
        DailySummary(
          city: city, // Pass the city name
          date: today,
          averageTemp: averageTemp,
          maxTemp: maxTemp,
          minTemp: minTemp,
          dominantCondition: dominantCondition,
          reason: reason,
          mainCondition: todayData.first.mainCondition,
          feelsLike: feelsLike,
          dt: todayData.first.updateTime.millisecondsSinceEpoch ~/ 1000, // Store as Unix timestamp
          updateTime: todayData.first.updateTime, // Add the updateTime value
          humidity: humidity, // Pass humidity value
          windSpeed: windSpeed, // Pass wind speed value
        )
      ];

      // Save the summary to storage
      await _storageService.saveDailySummary(summaries.first);

      // Update the summary for this city in the UI
      onDailySummaryUpdated(city, summaries);
    });
  }

  void _checkAlerts(List<WeatherData> latestData) {
    for (var data in latestData) {
      print('Checking temperature for ${data.city}: ${data.temperature}°C'); // Debugging output
      if (data.temperature > 25) { // Set threshold to 25°C
        _alertCounters[data.city] = (_alertCounters[data.city] ?? 0) + 1;
        print('Alert counter for ${data.city}: ${_alertCounters[data.city]}'); // Debugging output
        if (_alertCounters[data.city]! >= 1) { // Trigger alert if condition is met for two updates
          Alert alert = Alert(
              city: data.city,
              condition: 'High Temperature',
              alertTime: DateTime.now(),
              message: 'Temperature in ${data.city} has exceeded 25°C for two consecutive updates.'
          );
          print('Alert triggered for ${data.city}: ${alert.message}'); // Debugging output
          onAlertTriggered(alert);
          _alertCounters[data.city] = 0; // Reset counter after alert
        }
      } else {
        _alertCounters[data.city] = 0; // Reset counter if condition not met
      }
    }
  }
}
