import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather_app/weather_rule_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(WeatherRuleEngineApp()); // Run the WeatherRuleEngineApp
}
