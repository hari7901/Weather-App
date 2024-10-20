import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../config.dart';

class ApiService {
  final List<String> _cities = ['Mumbai', 'Chennai', 'Delhi', 'Kolkata', 'Hyderabad'];

  // Public method to access the cities
  List<String> getCities() {
    return _cities;
  }

  Future<List<WeatherData>> fetchWeatherData() async {
    final String apiKey = await Config.getOpenWeatherMapApiKey();

    if (apiKey.isEmpty) {
      throw Exception('OPENWEATHERMAP_API_KEY is missing. Please provide it.');
    }

    List<WeatherData> weatherDataList = [];

    for (String city in _cities) {
      try {
        print('Fetching weather data for city: $city'); // Debugging output
        final response = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Weather data for $city: $data'); // Debugging output
          WeatherData weatherData = WeatherData.fromJson(data);
          weatherDataList.add(weatherData);
          print('Fetched data for $city: ${weatherData.temperature}°C, feels like ${weatherData.feelsLike}°C'); // Debugging output
        } else {
          print('Failed to load weather data for $city. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching weather data for $city: $e');
      }
    }

    return weatherDataList;
  }
}
