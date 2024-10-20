class WeatherData {
  final String city;
  final String mainCondition;
  final int temperature; // Stored as int in Celsius
  final int feelsLike; // Stored as int in Celsius
  final int maxTemp; // Maximum temperature in Celsius
  final int minTemp; // Minimum temperature in Celsius
  final int humidity; // Humidity percentage
  final double windSpeed; // Wind speed in m/s
  final DateTime updateTime; // Time of the data update (Unix timestamp)

  WeatherData({
    required this.city,
    required this.mainCondition,
    required this.temperature,
    required this.feelsLike,
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
    required this.windSpeed,
    required this.updateTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['name'],
      mainCondition: json['weather'][0]['main'],
      temperature: _safeKelvinToCelsius(json['main']['temp']),
      feelsLike: _safeKelvinToCelsius(json['main']['feels_like']),
      maxTemp: _safeKelvinToCelsius(json['main']['temp_max']),
      minTemp: _safeKelvinToCelsius(json['main']['temp_min']),
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      updateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
    );
  }

  static int _safeKelvinToCelsius(dynamic kelvin) {
    if (kelvin == null || kelvin is! num) {
      return 0; // Return 0 if invalid data
    }
    return (kelvin - 273.15).round();
  }

  // Convert Celsius to Fahrenheit
  int toFahrenheit(int celsius) {
    return ((celsius * 9 / 5) + 32).round();
  }
}
class DailySummary {
  final String city; // City name
  final String date; // e.g., '2023-08-25'
  final int averageTemp;
  final int maxTemp;
  final int minTemp;
  final String dominantCondition;
  final String reason; // Reason for dominant condition
  final String mainCondition; // Main weather condition
  final int feelsLike; // Feels like temperature
  final int dt; // Unix timestamp for data update
  final DateTime updateTime; // Time of the data update
  final int humidity; // Humidity percentage
  final double windSpeed; // Wind speed in m/s

  DailySummary({
    required this.city,
    required this.date,
    required this.averageTemp,
    required this.maxTemp,
    required this.minTemp,
    required this.dominantCondition,
    required this.reason,
    required this.mainCondition,
    required this.feelsLike,
    required this.dt,
    required this.updateTime,
    required this.humidity, // New field
    required this.windSpeed, // New field
  });

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'date': date,
      'averageTemp': averageTemp,
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'dominantCondition': dominantCondition,
      'reason': reason,
      'mainCondition': mainCondition,
      'feelsLike': feelsLike,
      'dt': dt,
      'updateTime': updateTime.millisecondsSinceEpoch, // Store as timestamp
      'humidity': humidity, // New field
      'windSpeed': windSpeed, // New field
    };
  }

  factory DailySummary.fromMap(Map<String, dynamic> map) {
    return DailySummary(
      city: map['city'],
      date: map['date'],
      averageTemp: (map['averageTemp'] as num).toInt(),
      maxTemp: (map['maxTemp'] as num).toInt(),
      minTemp: (map['minTemp'] as num).toInt(),
      dominantCondition: map['dominantCondition'],
      reason: map['reason'],
      mainCondition: map['mainCondition'],
      feelsLike: (map['feelsLike'] as num).toInt(),
      dt: map['dt'],
      updateTime: DateTime.fromMillisecondsSinceEpoch(map['updateTime']),
      humidity: (map['humidity'] as num).toInt(), // New field
      windSpeed: (map['windSpeed'] as num).toDouble(), // New field
    );
  }

  // Factory method to create DailySummary from WeatherData
  factory DailySummary.fromWeatherData(WeatherData data) {
    return DailySummary(
      city: data.city,
      date: DateTime.now().toIso8601String().split('T')[0], // Current date
      averageTemp: data.temperature,
      maxTemp: data.maxTemp,
      minTemp: data.minTemp,
      dominantCondition: data.mainCondition,
      reason: 'Dominant condition: ${data.mainCondition}',
      mainCondition: data.mainCondition,
      feelsLike: data.feelsLike,
      dt: data.updateTime.millisecondsSinceEpoch ~/ 1000,
      updateTime: data.updateTime, // Directly map updateTime from WeatherData
      humidity: data.humidity, // New field
      windSpeed: data.windSpeed, // New field
    );
  }
}

class Alert {
  final String city;
  final String condition;
  final DateTime alertTime;
  final String message;

  Alert({
    required this.city,
    required this.condition,
    required this.alertTime,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'condition': condition,
      'alertTime': alertTime.toIso8601String(),
      'message': message,
    };
  }

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      city: map['city'],
      condition: map['condition'],
      alertTime: DateTime.parse(map['alertTime']),
      message: map['message'],
    );
  }
}
