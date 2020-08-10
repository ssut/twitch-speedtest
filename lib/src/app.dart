import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:twitch_speedtest/src/models/app_state_model.dart';
import 'package:twitch_speedtest/src/models/history_model.dart';
import 'package:twitch_speedtest/src/models/settings_model.dart';
import 'package:twitch_speedtest/src/models/twitch_state_model.dart';
import 'package:twitch_speedtest/src/views/settings_tab_view.dart';

import 'package:twitch_speedtest/src/views/speedtest_tab_view.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class TwitchSpeedTestApp extends StatelessWidget {
  final appState = AppStateModel();
  final twitchState = TwitchStateModel();
  final history = HistoryModel();
  final settings = SettingsModel();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    setLocale(context);

    String fontFamily = 'Noto Sans KR';
    switch (context.locale.languageCode) {
      case 'ja':
        fontFamily = 'Noto Sans JP';
        break;

      case 'en':
        fontFamily = 'Hind';
        break;

      case 'ko':
      default:
        fontFamily = 'Noto Sans KR';
        break;
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateModel>(create: (_) {
          appState.init();
          return appState;
        }),
        ChangeNotifierProvider<TwitchStateModel>(create: (_) => twitchState),
        ChangeNotifierProvider<HistoryModel>(create: (_) => history),
        ChangeNotifierProvider<SettingsModel>(create: (_) => settings),
      ],
      child: Theme(
        data: ThemeData(
          fontFamily: fontFamily,
        ),
        child: CupertinoApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            ...context.localizationDelegates,
            EasyLocalization.of(context).delegate,
          ],
          supportedLocales: EasyLocalization.of(context).supportedLocales,
          locale: EasyLocalization.of(context).locale,
          home: TwitchSpeedTestHomePage(),
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
        ),
      ),
    );

  }

  void setLocale(BuildContext context) {
    switch (ui.window.locale?.languageCode) {
      case 'ko':
        context.locale = Locale('ko', 'KR');
        break;

      case 'en':
        context.locale = Locale('en', 'US');
        break;

      case 'ja':
        context.locale = Locale('ja', 'JP');
        break;

      case 'zh':
        if (ui.window.locale.scriptCode == 'Hant') {
          context.locale = Locale('zh', 'TW');
        }
        if (ui.window.locale.countryCode == 'HK' ||
            ui.window.locale.countryCode == 'TW' ||
            ui.window.locale.countryCode == 'CN') {
          context.locale = Locale('zh', ui.window.locale.countryCode);
        } else
          context.locale = Locale('zh', 'CN');
        break;

      default:
        break;
    }
  }
}

class TwitchSpeedTestHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, state, child) {
        return CupertinoTabScaffold(tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(IconData(0xf2b3, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage)),
              title: Text('tab:speedtest'.tr()),
            ),
            BottomNavigationBarItem(
              icon: Icon(IconData(0xf471, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage)),
              title: Text('tab:history'.tr()),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.gear),
              title: Text('tab:settings'.tr()),
            ),
          ],
        ), tabBuilder: (context, index) {
          CupertinoTabView tabView;
          switch (index) {
            case 0:
              tabView = CupertinoTabView(builder: (context) {
                return SpeedTestTabView();
              });
              break;

            case 1:
              break;

            case 2:
              tabView = CupertinoTabView(builder: (context) {
                return SettingsTabView();
              });
              break;
          }

          return tabView;
        });
      },
    );
  }
}
