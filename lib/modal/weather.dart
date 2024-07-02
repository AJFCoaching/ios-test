import 'package:matchday/main.dart';

class Weather {
  final String matchdate;
  final String cityName;
  final double temperature;
  final String mainCondition;

  Weather(
      {required this.matchdate,
      required this.cityName,
      required this.temperature,
      required this.mainCondition});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      matchdate: matchDate,
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}
