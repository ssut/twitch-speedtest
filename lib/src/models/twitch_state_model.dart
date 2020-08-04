import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:twitch_speedtest/src/twitch/client.dart';
import 'package:twitch_speedtest/src/twitch/servers.dart';

enum TwitchLoadingState {
  Error,
  Standby,
  Preparing,
  Testing,
  Done,
}

class TwitchStateModel extends foundation.ChangeNotifier {
  TwitchClient client;

  List<List<Variant>> hlsVariantsInfos;
  Set<TwitchServer> twitchServers = Set();
  String servers = '';

  TwitchLoadingState state = TwitchLoadingState.Standby;

  setLoadingState(TwitchLoadingState state) {
    this.state = state;

    notifyListeners();
  }

  _clearTwitchServers() {
    twitchServers.clear();

    notifyListeners();
  }

  _setServers(Set<TwitchServer> twitchServers) {
    this.twitchServers = twitchServers;
  }

  _initClient() {
    this.client = TwitchClient();
  }

  init({ int targetChannelCount = 15 }) async {
    if (state.index >= TwitchLoadingState.Preparing.index) {
      return;
    }

    setLoadingState(TwitchLoadingState.Preparing);
    _initClient();
    _clearTwitchServers();

    try {
      final streams = await client.getRecommendedStreams(count: 15);
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

      print(hlsVariantsInfos);

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

      _setServers(servers);
    } catch (e) {
      print(e);

      setLoadingState(TwitchLoadingState.Error);
    }
  }
}
