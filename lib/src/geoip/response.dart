// To parse this JSON data, do
//
//     final geoIpResponse = geoIpResponseFromJson(jsonString);

import 'dart:convert';

class GeoIpResponse {
  GeoIpResponse({
    this.ip,
    this.countryCode,
    this.countryName,
    this.regionCode,
    this.regionName,
    this.city,
    this.zipCode,
    this.timeZone,
    this.latitude,
    this.longitude,
    this.metroCode,
  });

  final String ip;
  final String countryCode;
  final String countryName;
  final String regionCode;
  final String regionName;
  final String city;
  final String zipCode;
  final String timeZone;
  final double latitude;
  final double longitude;
  final int metroCode;

  factory GeoIpResponse.fromRawJson(String str) => GeoIpResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GeoIpResponse.fromJson(Map<String, dynamic> json) => GeoIpResponse(
    ip: json["ip"],
    countryCode: json["country_code"],
    countryName: json["country_name"],
    regionCode: json["region_code"],
    regionName: json["region_name"],
    city: json["city"],
    zipCode: json["zip_code"],
    timeZone: json["time_zone"],
    latitude: json["latitude"].toDouble(),
    longitude: json["longitude"].toDouble(),
    metroCode: json["metro_code"],
  );

  Map<String, dynamic> toJson() => {
    "ip": ip,
    "country_code": countryCode,
    "country_name": countryName,
    "region_code": regionCode,
    "region_name": regionName,
    "city": city,
    "zip_code": zipCode,
    "time_zone": timeZone,
    "latitude": latitude,
    "longitude": longitude,
    "metro_code": metroCode,
  };
}
