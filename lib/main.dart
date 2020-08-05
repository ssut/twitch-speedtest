import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twitch_speedtest/src/app.dart';
import 'package:syncfusion_flutter_core/core.dart';

void main() async {
  await DotEnv().load('.env');
  SyncfusionLicense.registerLicense(DotEnv().env['SYNCFUSION_LICENSE']);

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

