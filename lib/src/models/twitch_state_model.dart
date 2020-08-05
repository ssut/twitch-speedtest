import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:pool/pool.dart';
import 'package:twitch_speedtest/src/speedtest/jitter.dart';
import 'package:twitch_speedtest/src/speedtest/latency.dart';
import 'package:http/http.dart' as http;
import 'package:twitch_speedtest/src/twitch/client.dart';
import 'package:twitch_speedtest/src/twitch/servers.dart';
import 'package:dio/dio.dart';

enum TwitchLoadingState {
  Error,
  NoServers,
  Standby,
  Preparing,
  TestingPing,
  TestingSpeed,
  Reporting,
  Done,
}

class TwitchStateModel extends foundation.ChangeNotifier {
  TwitchClient client;

  List<List<Variant>> hlsVariantsInfos;
  List<List<Variant>> variantsForTest = [[], []];
  Set<TwitchServer> twitchServers = Set();
  String servers = '';

  List<int> _latencies = [];

  int avgLatency;
  int jitter;

  double progress = 0.0;

  Duration testDuration;
  int bytesReceived;
  int lastSpeedBytes;
  int _lastCheckedMillis = 0;
  int _lastCheckedBytes = 0;

  TwitchLoadingState state = TwitchLoadingState.Standby;

  setLoadingState(TwitchLoadingState state) {
    this.state = state;

    notifyListeners();
  }

  int get lastLatency => _latencies.length > 0 ? _latencies.last : null;

  _clearTwitchServers() {
    twitchServers.clear();

    notifyListeners();
  }

  _setProgress(double progress) {
    this.progress = progress;

    notifyListeners();
  }

  _setServers(Set<TwitchServer> twitchServers) {
    this.twitchServers = twitchServers;
  }

  _setVariantsForTest(List<List<Variant>> list) {
    variantsForTest = list ?? [[], []];
  }

  _calculateAvgLatency() {
    final latencies = _latencies ?? [];
    _setAvgLatency((latencies.reduce((a, b) => a + b) / latencies.length).toInt());
  }

  _setAvgLatency(int latency) {
    avgLatency = latency;

    notifyListeners();
  }

  _calculateJitter() {
    final latencies = (_latencies ?? []).map((latency) => latency.toDouble()).toList();

    _setJitter(Jitter.compute(latencies).toInt());
  }

  _setJitter(int jitter) {
    this.jitter = jitter;

    notifyListeners();
  }

  _initClient() {
    this.client = TwitchClient();
  }

  _updatePeriodically({ Duration interval, CancelToken token }) async {
    for (;;) {
      if (token.isCancelled) {
        return;
      }

      if (_lastCheckedMillis < (testDuration.inMilliseconds / 100).floor() * 100) {
        lastSpeedBytes = (bytesReceived ~/ testDuration.inMilliseconds) * 1000;
        _lastCheckedMillis = testDuration.inMilliseconds;
        _lastCheckedBytes = bytesReceived;
      }

      progress = min(1, testDuration.inMilliseconds / 10000);
      notifyListeners();
      await Future.delayed(interval);
    }
  }

  _testSpeed({ List<List<String>> mediaUrls }) async {
    final testUrls = [...mediaUrls[0], ...mediaUrls[1]];

    CancelToken token = CancelToken();

    bytesReceived = 0;
    testDuration = Duration(milliseconds: 0);
    lastSpeedBytes = 0;
    _lastCheckedMillis = 0;
    _lastCheckedBytes = 0;
    notifyListeners();

    final pool = new Pool(8, timeout: new Duration(seconds: 60));
    _updatePeriodically(
      token: token,
      interval: Duration(milliseconds: 150),
    );

    int lastIndex = testUrls.length;
    for (int i = 0; i < lastIndex && testDuration.inMilliseconds < 10000; i++) {
      final url = testUrls[i];
      if (url == null) {
        break;
      }

      Response<ResponseBody> response;
      try {
        response = await Dio().get<ResponseBody>(url,
          options: Options(
            responseType: ResponseType.stream,
          ),
          cancelToken: token,
        );
      } catch (e) {
        continue;
      }

      if (response == null) {
        continue;
      }

      await pool.withResource(() async {
        final completer = new Completer();
        Stopwatch stopwatch = Stopwatch()..start();
        // ignore: cancel_subscriptions
        dynamic sub;
        sub = response.data.stream.listen((value) {
          if (token.isCancelled) {
            sub?.cancel();
            throw new Error();
          }

          bytesReceived += value.length;
          testDuration += stopwatch.elapsed;
          stopwatch.reset();
        });

        sub.onError(completer.complete);
        sub.onDone(completer.complete);

        await completer.future;
//        sub.cancel();
      });
    }

    _setProgress(1);
    token.cancel();

    lastSpeedBytes = (bytesReceived ~/ testDuration.inSeconds);
    notifyListeners();
  }

  start({ int targetChannelCount = 20 }) async {
    if (state.index >= TwitchLoadingState.Preparing.index) {
      return;
    }

    setLoadingState(TwitchLoadingState.Preparing);
    _initClient();
    _clearTwitchServers();
    _setVariantsForTest(null);
    _setProgress(0);

    try {
      final streams = await client.getRecommendedStreams(count: targetChannelCount);
      print(streams);

      hlsVariantsInfos = (await Future.wait(
        streams.map((stream) async {
          final accessToken = await client.getChannelAccessToken(
              username: stream.broadcaster.username);

          return client.getHLSInfo(
            username: stream.broadcaster.username,
            token: accessToken.token,
            signature: accessToken.sig,
          );
        }),
      )).where((element) => element != null).toList();

      Set<TwitchServer> servers = Set();
      for (var variants in hlsVariantsInfos) {
        final first = variants.first;

        if (first.url.host.startsWith('video-weaver.')) {
          final code = first.url.host.split('.')[1];
          final server = findTwitchServer(code);
          if (server != null) {
            servers.add(server);
          }
        }
      }

      if (servers.length == 0) {
        setLoadingState(TwitchLoadingState.NoServers);
        return;
      }

      _setServers(servers);

      List<List<Variant>> variantsForTest = [[], []];
      // filter 2 of the highest bitrate hlsVariantInfos only
      for (var hlsVariants in hlsVariantsInfos) {
        var variants = List<Variant>.from(hlsVariants);
        variants.sort((a, b) => b.format.bitrate - a.format.bitrate);
        variants = variants.take(2).toList();

        if (variants.length == 2) {
          variantsForTest[0].add(variants[1]);
          variantsForTest[1].add(variants[0]);
        }
      }

      if (variantsForTest[0].length == 0 || variantsForTest[1].length == 0) {
        setLoadingState(TwitchLoadingState.NoServers);
        return;
      }
      _setVariantsForTest(variantsForTest);

      // loading all variant urls
      final mediaUrls = await Future.wait(
        variantsForTest.map((variants) async {
          var segmentUrls = await Future.wait(variants.map((variant) async {
            final response = await http.get(variant.url);
            var playlist = await HlsPlaylistParser.create().parseString(variant.url, response.body);

            if (playlist is HlsMediaPlaylist) {
              return playlist.segments.map((segment) => segment.url).toList();
            }

            return null;
          }));

          return segmentUrls.expand((element) => element).where((element) => element != null).toList();
        })
      );

      // first comes: (1) 5 seconds (2)
      final stopwatch = Stopwatch()..start();

      setLoadingState(TwitchLoadingState.TestingPing);
      final testList = [...mediaUrls[0], ...mediaUrls[1]];

      var last = testList.length;
      var i = 0;
      for (; i < last; i++) {
        final url = testList[i];
        if (url == null) {
          break;
        }

        final uri = Uri.parse(url);
        try {
          final latency = await Latency.test(uri);
          if (latency != null) {
            if (_latencies.length == 0) {
              last = max(10000 ~/ latency, 200);
            }

            _latencies.add(latency);
            _calculateAvgLatency();
          }
        } catch (e) {
        } finally {
          double progress = ++i / last;
          _setProgress(progress);
        }
      }

      _setProgress(1);
      _calculateJitter();

      setLoadingState(TwitchLoadingState.TestingSpeed);

      await _testSpeed(
        mediaUrls: mediaUrls,
      );
    } catch (e) {
      print(e);

      setLoadingState(TwitchLoadingState.Error);
    }
  }
}
