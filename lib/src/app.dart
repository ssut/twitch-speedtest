import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:twitch_speedtest/src/models/app_state_model.dart';
import 'package:twitch_speedtest/src/models/history_model.dart';
import 'package:twitch_speedtest/src/models/settings_model.dart';
import 'package:twitch_speedtest/src/models/twitch_state_model.dart';

import 'package:twitch_speedtest/src/views/speedtest_tab_view.dart';

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
      child: CupertinoApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: TwitchSpeedTestHomePage(),
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
    return CupertinoTabScaffold(tabBar: CupertinoTabBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(IconData(0xf2b3, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage)),
          title: Text('SpeedTest'),
        ),
        BottomNavigationBarItem(
          icon: Icon(IconData(0xf471, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage)),
          title: Text('History'),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.gear),
          title: Text('Settings'),
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
      }

      return tabView;
    });
  }
}
