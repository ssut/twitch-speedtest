// To parse this JSON data, do
//
//     final twitchChannelAccessTokenResponse = twitchChannelAccessTokenResponseFromJson(jsonString);

import 'dart:convert';

class TwitchChannelAccessTokenResponse {
  TwitchChannelAccessTokenResponse({
    this.token,
    this.sig,
    this.mobileRestricted,
    this.expiresAt,
  });

  final String token;
  final String sig;
  final bool mobileRestricted;
  final DateTime expiresAt;

  factory TwitchChannelAccessTokenResponse.fromRawJson(String str) => TwitchChannelAccessTokenResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TwitchChannelAccessTokenResponse.fromJson(Map<String, dynamic> json) => TwitchChannelAccessTokenResponse(
    token: json["token"],
    sig: json["sig"],
    mobileRestricted: json["mobile_restricted"],
    expiresAt: DateTime.parse(json["expires_at"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "sig": sig,
    "mobile_restricted": mobileRestricted,
    "expires_at": expiresAt.toIso8601String(),
  };
}
