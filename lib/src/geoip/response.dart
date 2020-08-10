// To parse this JSON data, do
//
//     final ipInfo = ipInfoFromJson(jsonString);

import 'dart:convert';

class IpInfo {
  IpInfo({
    this.ip,
    this.success,
    this.type,
    this.continent,
    this.continentCode,
    this.country,
    this.countryCode,
    this.countryFlag,
    this.countryCapital,
    this.countryPhone,
    this.countryNeighbours,
    this.region,
    this.city,
    this.latitude,
    this.longitude,
    this.asn,
    this.org,
    this.isp,
    this.timezone,
    this.timezoneName,
    this.timezoneDstOffset,
    this.timezoneGmtOffset,
    this.timezoneGmt,
    this.currency,
    this.currencyCode,
    this.currencySymbol,
    this.currencyRates,
    this.currencyPlural,
    this.completedRequests,
  });

  final String ip;
  final bool success;
  final String type;
  final String continent;
  final String continentCode;
  final String country;
  final String countryCode;
  final String countryFlag;
  final String countryCapital;
  final String countryPhone;
  final String countryNeighbours;
  final String region;
  final String city;
  final String latitude;
  final String longitude;
  final String asn;
  final String org;
  final String isp;
  final String timezone;
  final String timezoneName;
  final String timezoneDstOffset;
  final String timezoneGmtOffset;
  final String timezoneGmt;
  final String currency;
  final String currencyCode;
  final String currencySymbol;
  final String currencyRates;
  final String currencyPlural;
  final int completedRequests;

  factory IpInfo.fromRawJson(String str) => IpInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IpInfo.fromJson(Map<String, dynamic> json) => IpInfo(
    ip: json["ip"],
    success: json["success"],
    type: json["type"],
    continent: json["continent"],
    continentCode: json["continent_code"],
    country: json["country"],
    countryCode: json["country_code"],
    countryFlag: json["country_flag"],
    countryCapital: json["country_capital"],
    countryPhone: json["country_phone"],
    countryNeighbours: json["country_neighbours"],
    region: json["region"],
    city: json["city"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    asn: json["asn"],
    org: json["org"],
    isp: json["isp"],
    timezone: json["timezone"],
    timezoneName: json["timezone_name"],
    timezoneDstOffset: json["timezone_dstOffset"],
    timezoneGmtOffset: json["timezone_gmtOffset"],
    timezoneGmt: json["timezone_gmt"],
    currency: json["currency"],
    currencyCode: json["currency_code"],
    currencySymbol: json["currency_symbol"],
    currencyRates: json["currency_rates"],
    currencyPlural: json["currency_plural"],
    completedRequests: json["completed_requests"],
  );

  Map<String, dynamic> toJson() => {
    "ip": ip,
    "success": success,
    "type": type,
    "continent": continent,
    "continent_code": continentCode,
    "country": country,
    "country_code": countryCode,
    "country_flag": countryFlag,
    "country_capital": countryCapital,
    "country_phone": countryPhone,
    "country_neighbours": countryNeighbours,
    "region": region,
    "city": city,
    "latitude": latitude,
    "longitude": longitude,
    "asn": asn,
    "org": org,
    "isp": isp,
    "timezone": timezone,
    "timezone_name": timezoneName,
    "timezone_dstOffset": timezoneDstOffset,
    "timezone_gmtOffset": timezoneGmtOffset,
    "timezone_gmt": timezoneGmt,
    "currency": currency,
    "currency_code": currencyCode,
    "currency_symbol": currencySymbol,
    "currency_rates": currencyRates,
    "currency_plural": currencyPlural,
    "completed_requests": completedRequests,
  };
}
