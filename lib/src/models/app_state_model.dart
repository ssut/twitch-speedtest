import 'package:flutter/foundation.dart' as foundation;
import 'package:twitch_speedtest/src/geoip/geoip.dart';
import 'package:twitch_speedtest/src/geoip/response.dart';

class AppStateModel extends foundation.ChangeNotifier {
  bool isLoading = true;
  GeoIpResponse myIpInfo;

  void init() async {
    try {
      myIpInfo = await GeoIP.getMyInfo();
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }

}
