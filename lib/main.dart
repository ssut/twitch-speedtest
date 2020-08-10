import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twitch_speedtest/src/app.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Twitch SpeedTest');
    setWindowMinSize(Size(375, 667));
  }

  await Executor().warmUp();
  await DotEnv().load('.env');
  SyncfusionLicense.registerLicense(DotEnv().env['SYNCFUSION_LICENSE']);

  await FirebaseApp.configure(
    name: 'TwitchSpeedTest',
    options: FirebaseOptions(
      googleAppID: '1:277805388271:ios:2490a2f79d3597d9bf661a',
      projectID: '277805388271',
    ),
  );

//  FirebaseApp.configure(name: null, options: null)

  runApp(
      EasyLocalization(
        supportedLocales: [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
          Locale('ja', 'JP'),
        ],
        path: 'assets/translations',
        useOnlyLangCode: true,
        fallbackLocale: Locale('en', 'US'),
        child: TwitchSpeedTestApp(),
      )
  );
}

