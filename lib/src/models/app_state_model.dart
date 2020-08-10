import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' as foundation;
import 'package:twitch_speedtest/src/geoip/geoip.dart';
import 'package:twitch_speedtest/src/geoip/response.dart';

class AppStateModel extends foundation.ChangeNotifier {
  bool isLoading = true;
  bool isUnavailable = false;

  IpInfo myIpInfo;
  final String os = Platform.operatingSystem;
  final String osVersion = Platform.operatingSystemVersion;

  bool loadChecked = false;

  setLoadChecked() {
    this.loadChecked = true;
  }

  Future init() async {
    try {
      myIpInfo = await GeoIP.getMyIpInfo();
    } catch (e) {
      isUnavailable = true;
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }

}
