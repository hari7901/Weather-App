import 'package:flutter/services.dart';

class Config {
  static const MethodChannel _channel = MethodChannel('com.example.weather_app/config');

  static Future<String> getOpenWeatherMapApiKey() async {
    try {
      final String apiKey = await _channel.invokeMethod('getOpenWeatherMapApiKey');
      return apiKey;
    } on PlatformException catch (e) {
      print("Failed to get API Key: '${e.message}'.");
      return '';
    }
  }
}
