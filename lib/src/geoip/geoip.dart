import 'package:http/http.dart' as http;
import 'package:twitch_speedtest/src/geoip/response.dart';

class GeoIP {
  static Future<IpInfo> getMyIpInfo() async {
    final response = await http.get('https://ipwhois.app/json/').timeout(Duration(seconds: 30));
    return IpInfo.fromRawJson(response.body);
  }
}
