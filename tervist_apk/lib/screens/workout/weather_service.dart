import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service class to handle weather data fetching from OpenWeatherMap API
class WeatherService {
  static const String apiKey = '074011b67e7a2d3c5beb0ac91ed3a2e0';
  static const String city = 'Tangerang';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // Cache the weather data
  static WeatherData? _cachedWeatherData;
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidity = Duration(minutes: 10);
  
  /// Fetch weather data with caching
  static Future<WeatherData> fetchWeather() async {
    // Check if cache is valid
    if (_cachedWeatherData != null && _lastFetchTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheValidity) {
        return _cachedWeatherData!;
      }
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final weatherData = WeatherData.fromJson(json.decode(response.body));
        
        // Update cache
        _cachedWeatherData = weatherData;
        _lastFetchTime = DateTime.now();
        
        return weatherData;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      // Return default data if API call fails
      return WeatherData(
        temperature: 30.0,
        description: 'Sunny',
        iconCode: '01d',
        cityName: city,
        feelsLike: 32.0,
        humidity: 70,
        windSpeed: 3.5,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Set up a periodic weather update stream
  static Stream<WeatherData> getPeriodicWeatherUpdates() {
    // Create a stream that updates every 10 minutes
    return Stream.periodic(const Duration(minutes: 10), (_) => fetchWeather())
      .asyncMap((future) => future);
  }

  /// Map OpenWeatherMap icon codes to corresponding Flutter icons
  static IconData getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': return Icons.wb_sunny; // clear sky day
      case '01n': return Icons.nightlight_round; // clear sky night
      case '02d': return Icons.cloud_outlined; // few clouds day
      case '02n': return Icons.cloud_outlined; // few clouds night
      case '03d':
      case '03n': return Icons.cloud; // scattered clouds
      case '04d':
      case '04n': return Icons.cloud_queue; // broken clouds
      case '09d':
      case '09n': return Icons.grain; // shower rain
      case '10d':
      case '10n': return Icons.beach_access; // rain
      case '11d':
      case '11n': return Icons.flash_on; // thunderstorm
      case '13d':
      case '13n': return Icons.ac_unit; // snow
      case '50d':
      case '50n': return Icons.cloud_outlined; // mist
      default: return Icons.wb_sunny;
    }
  }
  
  /// Get background color based on weather condition
  static Color getWeatherBackgroundColor(String iconCode) {
    if (iconCode.startsWith('01')) {
      return Colors.amber.shade50; // Clear sky
    } else if (iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) {
      return Colors.blue.shade50; // Cloudy
    } else if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return Colors.blueGrey.shade50; // Rain
    } else if (iconCode.startsWith('11')) {
      return Colors.deepPurple.shade50; // Thunderstorm
    } else if (iconCode.startsWith('13')) {
      return Colors.lightBlue.shade50; // Snow
    } else {
      return Colors.grey.shade50; // Mist or default
    }
  }
  
  /// Get text color based on weather condition
  static Color getWeatherTextColor(String iconCode) {
    if (iconCode.startsWith('01')) {
      return Colors.amber.shade800; // Clear sky
    } else if (iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) {
      return Colors.blue.shade800; // Cloudy
    } else if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return Colors.blueGrey.shade800; // Rain
    } else if (iconCode.startsWith('11')) {
      return Colors.deepPurple.shade800; // Thunderstorm
    } else if (iconCode.startsWith('13')) {
      return Colors.lightBlue.shade800; // Snow
    } else {
      return Colors.grey.shade800; // Mist or default
    }
  }
}

/// Model class to represent weather data
class WeatherData {
  final double temperature;
  final String description;
  final String iconCode;
  final String cityName;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.cityName,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
      cityName: json['name'],
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      timestamp: DateTime.now(),
    );
  }
}

/// Widget to display weather information
class WeatherWidget extends StatefulWidget {
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showDetails;
  final double iconSize;
  final double fontSize;

  const WeatherWidget({
    Key? key, 
    this.textColor, 
    this.iconColor,
    this.backgroundColor,
    this.showDetails = false,
    this.iconSize = 14,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  WeatherData? _weatherData;
  bool _isLoading = true;
  Timer? _refreshTimer;
  StreamSubscription? _weatherSubscription;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    
    // Set up stream subscription for periodic updates
    _weatherSubscription = WeatherService.getPeriodicWeatherUpdates().listen((weatherData) {
      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _weatherSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await WeatherService.fetchWeather();
      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshWeather() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildWeatherContainer(
        icon: Icons.refresh,
        temperature: '...',
        description: 'Loading...',
      );
    }

    if (_weatherData == null) {
      return _buildWeatherContainer(
        icon: Icons.error_outline,
        temperature: 'N/A',
        description: 'Error',
      );
    }

    return GestureDetector(
      onTap: _refreshWeather,
      child: _buildWeatherContainer(
        icon: WeatherService.getWeatherIcon(_weatherData!.iconCode),
        temperature: '${_weatherData!.temperature.toStringAsFixed(0)}°C',
        description: _weatherData!.description,
      ),
    );
  }

  Widget _buildWeatherContainer({
    required IconData icon, 
    required String temperature, 
    required String description
  }) {
    final Color backgroundColor = widget.backgroundColor ?? 
      (_weatherData != null 
        ? WeatherService.getWeatherBackgroundColor(_weatherData!.iconCode) 
        : Colors.amber.shade50);
    
    final Color textColor = widget.textColor ?? 
      (_weatherData != null 
        ? WeatherService.getWeatherTextColor(_weatherData!.iconCode) 
        : Colors.amber.shade800);
    
    final Color iconColor = widget.iconColor ?? textColor;
    
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon, 
          color: iconColor, 
          size: widget.iconSize
        ),
        const SizedBox(width: 4),
        Text(
          '$temperature $description',
          style: TextStyle(
            fontSize: widget.fontSize,
            color: textColor,
          ),
        ),
      ],
    );
    
    if (widget.showDetails && _weatherData != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(height: 4),
          Text(
            'Feels like: ${_weatherData!.feelsLike.toStringAsFixed(0)}°C',
            style: TextStyle(
              fontSize: widget.fontSize - 2,
              color: textColor,
            ),
          ),
          Text(
            'Humidity: ${_weatherData!.humidity}% · Wind: ${_weatherData!.windSpeed} m/s',
            style: TextStyle(
              fontSize: widget.fontSize - 2,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: content,
    );
  }
}

/// Widget to show a detailed weather card with more information
class DetailedWeatherCard extends StatelessWidget {
  final Future<WeatherData> weatherDataFuture;
  
  const DetailedWeatherCard({
    Key? key,
    required this.weatherDataFuture,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData>(
      future: weatherDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorCard();
        }
        
        final weatherData = snapshot.data!;
        return _buildWeatherCard(weatherData);
      },
    );
  }
  
  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
  
  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Unable to load weather data'),
        ),
      ),
    );
  }
  
  Widget _buildWeatherCard(WeatherData data) {
    final backgroundColor = WeatherService.getWeatherBackgroundColor(data.iconCode);
    final textColor = WeatherService.getWeatherTextColor(data.iconCode);
    
    return Card(
      elevation: 4,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.cityName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  '${data.timestamp.hour}:${data.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.temperature.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Icon(
                  WeatherService.getWeatherIcon(data.iconCode),
                  size: 48,
                  color: textColor,
                ),
              ],
            ),
            Text(
              data.description,
              style: TextStyle(
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherDetail(
                  Icons.thermostat, 
                  'Feels like', 
                  '${data.feelsLike.toStringAsFixed(0)}°C',
                  textColor,
                ),
                _buildWeatherDetail(
                  Icons.water_drop, 
                  'Humidity', 
                  '${data.humidity}%',
                  textColor,
                ),
                _buildWeatherDetail(
                  Icons.air, 
                  'Wind speed', 
                  '${data.windSpeed} m/s',
                  textColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherDetail(IconData icon, String label, String value, Color textColor) {
    return Column(
      children: [
        Icon(icon, color: textColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}