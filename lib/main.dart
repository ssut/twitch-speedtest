import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twitch_speedtest/src/app.dart';

void main() {
  runApp(
      EasyLocalization(
        supportedLocales: [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
          Locale('ja', 'JP'),
        ],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        child: TwitchSpeedTestApp(),
      )
  );
}

