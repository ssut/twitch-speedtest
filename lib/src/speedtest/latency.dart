import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';


class Latency {
  static bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  static http.Client client = IOClient(new HttpClient()
    ..badCertificateCallback = _certificateCheck);

  static Future<int> test(Uri uri) async {
    final host = uri.host;
    final port = uri.port;

    // look up dns first to measure more precise latency
    final record = await DnsUtils.lookupRecord(uri.host, RRecordType.A);
    final ip = record.single.data;

    final newUri = Uri.parse(uri.toString().replaceFirst('${uri.scheme}://${uri.host}', '${uri.scheme}://${ip}'));

    Socket socket;
    final stopwatch = Stopwatch()..start();
    try {
      await client.head(newUri, headers: { 'host': uri.host });

      final elapsed = stopwatch.elapsedMilliseconds;
      return elapsed;
    } catch (e) {
      print(e);
      return null;
    } finally {
      stopwatch.stop();
      await socket?.close();
    }
  }
}

