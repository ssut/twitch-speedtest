import 'package:http/http.dart' as http;
import 'package:twitch_speedtest/src/geoip/response.dart';

class GeoIP {
  static Future<GeoIpResponse> getMyInfo() async {
    final response = await http.get(Uri.encodeFull('https://freegeoip.app/json'));
    return GeoIpResponse.fromRawJson(response.body);
  }
}
