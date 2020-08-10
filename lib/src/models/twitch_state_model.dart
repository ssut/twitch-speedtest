import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:pool/pool.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:twitch_speedtest/src/speedtest/http_stream_speedtest.dart';
import 'package:twitch_speedtest/src/speedtest/jitter.dart';
import 'package:twitch_speedtest/src/speedtest/latency.dart';
import 'package:http/http.dart' as http;
import 'package:twitch_speedtest/src/twitch/client.dart';
import 'package:twitch_speedtest/src/twitch/servers.dart';
import 'package:dio/dio.dart';
import 'package:worker_manager/worker_manager.dart';

enum TwitchLoadingState {
  Error,
  NoServers,
  Standby,
  Preparing,
  TestingPing,
  TestingSpeed,
  TestingSpeedDone,
  Reporting,
  Done,
}

enum TwitchTestType {
  Multi,
  Single,
}

class TwitchStateModel extends foundation.ChangeNotifier {
  TwitchClient client;

  List<List<Variant>> hlsVariantsInfos;
  List<Variant> variantsForTest = [];
  Set<TwitchServer> twitchServers = Set();

  List<int> _latencies = [];
  int lastLatency;

  int avgLatency;
  int jitter;

  double progress = 0.0;

  Duration testDuration;
  int bytesReceived;
  int lastSpeedBytes;
  int _lastCheckedMillis = 0;
  int _lastCheckedBytes = 0;

  TwitchTestType testType = TwitchTestType.Multi;
  TwitchLoadingState state = TwitchLoadingState.Standby;

  double get lastSpeedMbps => (lastSpeedBytes ?? 0.0) / 125000;

  int _totalRequests = 0;
  int _totalFails = 0;

  double get loss => _totalFails / _totalRequests;

  setTestType(TwitchTestType type) {
    testType = type;

    notifyListeners();
  }

  setLoadingState(TwitchLoadingState state) {
    this.state = state;

    notifyListeners();
  }

  reset() {
    hlsVariantsInfos = null;
    variantsForTest = [];
    twitchServers.clear();
    _latencies = [];
    lastLatency = null;
    avgLatency = null;
    jitter = null;
    progress = 0.0;
    testDuration = null;
    bytesReceived = null;
    lastSpeedBytes = null;
    _lastCheckedMillis = 0;
    _lastCheckedBytes = 0;
    _totalRequests = 0;
    _totalFails = 0;

    notifyListeners();
  }

  _clearTwitchServers() {
    twitchServers.clear();

    notifyListeners();
  }

  _setProgress(double progress) {
    this.progress = progress;

    notifyListeners();
  }

  _setLastLatency(int latency) {
    lastLatency = latency;
    print("SetLastLatency");

    notifyListeners();
  }

  _setServers(Set<TwitchServer> twitchServers) {
    this.twitchServers = twitchServers;

    notifyListeners();
  }

  _setVariantsForTest(List<Variant> list) {
    variantsForTest = list ?? [];
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

      _updateSpeed();
      await Future.delayed(interval);
    }
  }

  _updateSpeed() {
    if (_lastCheckedMillis < (testDuration.inMilliseconds / 100).floor() * 100) {
      lastSpeedBytes = (bytesReceived ~/ testDuration.inMilliseconds) * 1000;
      _lastCheckedMillis = testDuration.inMilliseconds;
      _lastCheckedBytes = bytesReceived;
    }

    progress = min(1, testDuration.inMilliseconds / 10000);
    notifyListeners();
  }

  _testSpeed(List<String> testUrls) async {
    CancelToken token = CancelToken();

    bytesReceived = 0;
    testDuration = Duration(milliseconds: 0);
    lastSpeedBytes = 0;
    _lastCheckedMillis = 0;
    _lastCheckedBytes = 0;
    notifyListeners();

    int poolSize = 1;
    if (this.testType == TwitchTestType.Multi) {
      poolSize = 6;
    }
    final pool = new Pool(poolSize, timeout: new Duration(seconds: 60));

    // WARN: violation of IsolateChannel usage
    ReceivePort rPort = new ReceivePort();
    IsolateChannel channel = new IsolateChannel.connectReceive(rPort);
    final sub = channel.stream.listen((data) {
      if (data is HttpStreamSpeedTestChunkData) {
        bytesReceived += data.length;
        testDuration += data.elapsed;

        _updateSpeed();
      }
    });
    int lastIndex = testUrls.length;
    for (int i = 0; i < lastIndex && testDuration.inMilliseconds < 10000; i++) {
      final url = testUrls[i];
      if (url == null) {
        break;
      }
      await pool.withResource(() async {
        print("pool executing $url");

        try {
          _totalRequests += 1;
          await Executor().execute(
            arg1: url,
            arg2: rPort.sendPort,
            fun2: HttpStreamSpeedTest.get,
          );
        } catch (e) {
          _totalFails += 1;
          print(e);
        }
      });
    }

    _setProgress(1);
    token.cancel();
    sub.cancel();

    lastSpeedBytes = (bytesReceived ~/ testDuration.inSeconds);
    notifyListeners();
  }

  start({ int targetChannelCount = 20 }) async {
    if (state.index >= TwitchLoadingState.Preparing.index) {
      return;
    }

    reset();

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
      print(servers.length);

      List<Variant> variantsForTest = [];
      // filter 2 of the highest bitrate hlsVariantInfos only
      for (var hlsVariants in hlsVariantsInfos) {
        var variants = List<Variant>.from(hlsVariants);
        variants.sort((a, b) => b.format.bitrate - a.format.bitrate);

        variantsForTest.add(variants[0]);
      }

      if (variantsForTest.length == 0) {
        setLoadingState(TwitchLoadingState.NoServers);
        return;
      }
      _setVariantsForTest(variantsForTest);

      // loading all variant urls
      final mediaUrls = (await Future.wait(
        variantsForTest.map((variant) async {
          final response = await http.get(variant.url);
          var playlist = await HlsPlaylistParser.create().parseString(variant.url, response.body);

          if (playlist is HlsMediaPlaylist) {
            return playlist.segments.map((segment) => segment.url).toList();
          }

          return null;
        })
      )).expand((items) => items).toList();

      // first comes: (1) 5 seconds (2)
      final stopwatch = Stopwatch()..start();

      setLoadingState(TwitchLoadingState.TestingPing);
      final testList = mediaUrls;

        var last = testList.length;
        var i = 0;
        for (; i < last; i++) {
          final url = testList[i];
          if (url == null) {
            break;
          }

          final uri = Uri.parse(url);
          try {
            final int latency = await Executor().execute(arg1: uri, fun1: Latency.test);
            if (latency != null) {
              if (_latencies.length == 0) {
                last = min(min(10000 ~/ latency, 200), testList.length);
                print("set last $last");
              }

              _totalRequests += 1;
              _latencies.add(latency);
              _setLastLatency(latency);
            } else {
              _totalFails += 1;
            }
          } catch (e) {
            print(e);
          } finally {
            double progress = ++i / last;
            _setProgress(progress);
          }
        }


      _setProgress(1);
      _calculateAvgLatency();
      _calculateJitter();

      setLoadingState(TwitchLoadingState.TestingSpeed);
      await Future.delayed(Duration(seconds: 3));
      await _testSpeed(mediaUrls);
      setLoadingState(TwitchLoadingState.TestingSpeedDone);
      await Future.delayed(Duration(seconds: 2));
      setLoadingState(TwitchLoadingState.Reporting);
      print(loss);
        
      
    } catch (e) {
      print(e);

      setLoadingState(TwitchLoadingState.Error);
    }
  }
}
