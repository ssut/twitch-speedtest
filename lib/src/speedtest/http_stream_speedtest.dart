import 'dart:async';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:stream_channel/isolate_channel.dart';

class HttpStreamSpeedTestChunkData {
  final int length;
  final Duration elapsed;

  HttpStreamSpeedTestChunkData(this.length, this.elapsed);
}

enum HttpStreamSpeedTestCommand {
  Cancelled,
}

class HttpStreamSpeedTest {
  static Future<dynamic> get(String url, SendPort sendPort) async {
    IsolateChannel channel;
    final token = CancelToken();
    if (sendPort != null) {
      channel = IsolateChannel.connectSend(sendPort);
      channel.stream.listen((event) {
        if (event is HttpStreamSpeedTestCommand) {
          if (event == HttpStreamSpeedTestCommand.Cancelled) {
            token.cancel();
          }
        }
      });
    }

    final response = await Dio().get<ResponseBody>(url,
      options: Options(
        responseType: ResponseType.stream,
      ),
      cancelToken: token,
    );

    final completer = new Completer();
    Stopwatch stopwatch = Stopwatch()..start();
    // ignore: cancel_subscriptions
    dynamic sub;
    sub = response.data.stream.listen((value) {
      if (token.isCancelled) {
        sub?.cancel();
        throw new Error();
      }

      channel.sink.add(HttpStreamSpeedTestChunkData(value.length, stopwatch.elapsed));
      stopwatch.reset();
    });

    sub.onError(completer.completeError);
    sub.onDone(completer.complete);

    await completer.future;
  }
}
