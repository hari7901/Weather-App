import 'package:flutter/material.dart';
import 'weather_dashboard.dart'; // Import the WeatherDashboard

class WeatherRuleEngineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Rule Engine',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: WeatherDashboard(), // Set the dashboard as the home screen
      debugShowCheckedModeBanner: false,
    );
  }
}
