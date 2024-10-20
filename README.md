# Requirements
To set up and run this application, you will need the following:

Flutter SDK: Install Flutter SDK to build and run the application. You can download it from here.
Dart: Flutter uses Dart as the programming language. Dart is included when you install Flutter.
OpenWeatherMap API Key: Sign up for an API key from OpenWeatherMap.

# Additional Tools

Docker: To optionally run a database container or set up local web services using Docker, you can install Docker from here.
Git: Install Git to clone the project repository.

# API Dependencies
This project uses the following APIs:

# OpenWeatherMap API for fetching weather data, including:
1) Temperature (temp)
2) Feels Like (feels_like)
3) Humidity (humidity)
4) Wind Speed (wind_speed)
5) Dominant weather condition (main)

# Setup Instructions

# Step 1: Clone the Repository
Clone the repository from GitHub:

git clone https://github.com/your-github-username/weather-dashboard.git
cd weather-dashboard

# Step 2: Install Flutter
Make sure that Flutter is installed on your system. Follow this guide to install Flutter.

Once installed, verify it by running:

flutter doctor

# Step 3: Install Project Dependencies
Install the necessary dependencies by running the following command in the project directory:

flutter pub get

# Step 4: Set Up API Key
Sign up for an API key on OpenWeatherMap.

Create a .env file in the root directory to store the API key:
OPENWEATHERMAP_API_KEY=your_api_key_here

# Step 6: Running the Application

To run the Flutter application on an emulator or connected device, use the following command:
flutter run

# Design Choices
1. Real-Time Data Processing
The application fetches weather data at configurable intervals (default: every 5 minutes) using the OpenWeatherMap API. Each city’s weather data is updated and displayed in real-time.

2. Rollups and Aggregates
For each day, the system processes and stores aggregated weather data:

Average temperature: Computed using hourly data throughout the day.
Maximum and Minimum temperatures: Tracked throughout the day.
Dominant weather condition: Based on the most frequent weather condition during the day.

3. User Preferences (Celsius/Fahrenheit)
Users can toggle between Celsius and Fahrenheit via a switch UI. Temperature data is converted using the following formula for Fahrenheit:
F = (C * 9/5) + 32

4. Alerting System
The user can set temperature thresholds (e.g., alerts when the temperature exceeds 35°C). When these conditions are met, the system triggers an alert with a popup notification, ensuring users are informed in real-time.

# API Integration
The application uses the OpenWeatherMap API to fetch the following data for each city:

Main Weather Condition (main): e.g., Rain, Clear, etc.
Temperature (temp): Real-time temperature in Kelvin (converted to Celsius or Fahrenheit).
Feels Like (feels_like): Perceived temperature.
Humidity (humidity): Current humidity percentage.
Wind Speed (wind_speed): Wind speed in meters per second.
The API is called at regular intervals, and the responses are processed into daily summaries and stored in memory or persistent storage (MongoDB in this case).

# Visualization
The weather trends and data summaries are visualized using the charts_flutter package. The following charts are provided:

Bar Chart: Shows the daily temperature summaries, including average, maximum, and minimum temperatures.

# 1. Data Retrieval Simulation
The API is called every 5 minutes, and the system retrieves and parses the weather data. Use flutter run to simulate real-time data retrieval and display.

# 2. Temperature Conversion
The application allows the user to toggle between Celsius and Fahrenheit. Temperatures are correctly converted and displayed as per the user's preference.

# 3. Alert System
The alert system is tested by setting configurable temperature thresholds. If the weather data exceeds the set threshold for two consecutive updates, an alert popup is triggered.

