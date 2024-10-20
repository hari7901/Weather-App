package com.example.weather_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.weather_app.BuildConfig // Import BuildConfig to access API key from gradle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.weather_app/config" // Define the channel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getOpenWeatherMapApiKey" -> {
                    val apiKey = BuildConfig.OPENWEATHERMAP_API_KEY // Fetch API key from BuildConfig
                    if (apiKey.isNotEmpty()) {
                        result.success(apiKey)
                    } else {
                        result.error("UNAVAILABLE", "API Key not available.", null)
                    }
                }
                "getUserTemperaturePreference" -> {
                    // Assuming you want to return a default temperature preference
                    // This can be updated to retrieve from SharedPreferences or another source
                    val tempPreference = "Celsius" // Hardcoded for now; you can modify this
                    result.success(tempPreference)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
