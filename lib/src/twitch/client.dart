import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:twitch_speedtest/src/twitch/responses/twitch_channel_access_token_response.dart';
import 'package:twitch_speedtest/src/twitch/responses/twitch_recommended_channel_response.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' show Random;

var uuid = Uuid();

 class RecommendedStreamBroadcaster {
  final String id;
  final String displayName;
  final String username;
  final String profileImageURL;

  RecommendedStreamBroadcaster(this.id, this.displayName, this.username, this.profileImageURL);
}

 class RecommendedStream {
  final String id;
  final RecommendedStreamBroadcaster broadcaster;
  final int viewersCount;

  RecommendedStream(this.id, this.broadcaster, this.viewersCount);
}

class TwitchClient {
  static String clientId = 'kimne78kx3ncx6brgo4mv6wki5h1ko';

  final String deviceId = uuid.v4().split('-').first;
  final http.Client client = http.Client();
  final String acceptLang;

  TwitchClient({ this.acceptLang = 'ko-KR' });

  Map<String, String> get requiredHeaders => {
    'Client-Id': clientId,
    'X-Device-Id': this.deviceId,
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ( KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36',
    'Accept': '*/*',
    'Accept-Language': '${this.acceptLang}, en-US;q=0.1',
    'Origin': 'https://www.twitch.tv',
  };

  Future<List<RecommendedStream>> getRecommendedStreams({ int count = 10 }) async {
    final String recID = '9610a470-62df-48ad-b4ff-1e0b1424babe';
    final response = await this.client.post(Uri.encodeFull('https://gql.twitch.tv/gql'),
      body: json.encode([{"operationName":"RecommendedChannels","variables":{"first":count,"recID":recID,"location":"LEFT_NAV","context":{"platform":"web"}},"extensions":{"persistedQuery":{"version":1,"sha256Hash":"bf992b593a6bdb08834ecf08c9621e421272febfb25bc67033b48c7b8f8bdda9"}}}]),
      headers: {
        ...this.requiredHeaders,
        'Content-Type': 'text/plain;charset=UTF-8',
      },
    );
    debugPrint(json.decode(response.body)[0].runtimeType.toString());

    final decoded = TwitchRecommendedChannelResponse.fromJson(json.decode(response.body)[0]);
    return decoded.data.recommendedStreams.edges.map((edge) {
      return RecommendedStream(
          edge.node.id,
          RecommendedStreamBroadcaster(
          edge.node.broadcaster.id,
          edge.node.broadcaster.displayName,
          edge.node.broadcaster.login,
          edge.node.broadcaster.profileImageUrl,
          ),
        edge.node.viewersCount,
      );
    }).toList();
  }

  Future<TwitchChannelAccessTokenResponse> getChannelAccessToken({ String username }) async {
    final response = await this.client.get(Uri.encodeFull('https://api.twitch.tv/api/channels/${username}/access_token'),
      headers: this.requiredHeaders,
    );

    return TwitchChannelAccessTokenResponse.fromRawJson(response.body);
  }

  Future<List<Variant>> getHLSInfo({
    String username,
    String token,
    String signature,
    bool allowAudioOnly = false,
    bool allowSource = true,
    String type = 'any',
  }) async {
    final query = {
      'token': token,
      'sig': signature,
      'allow_audio_only': allowAudioOnly ? 'true' : 'false',
      'allow_source': allowSource ? 'true' : 'false',
      'type': type,
      'p': randomBetween(1, 10e6.toInt()).toString(),
    };
    final uri = Uri.https('usher.ttvnw.net', '/api/channel/hls/${username}.m3u8', query);
    final response = await this.client.get(uri,
      headers: this.requiredHeaders,
    );

    HlsMasterPlaylist playlist;
    try {
      playlist = await HlsPlaylistParser.create().parseString(uri, response.body);
    } on ParserException catch (e) {
      print(e);
      return null;
    }

    // lower to higher
    playlist.variants.sort((a, b) => a.format.bitrate.compareTo(b.format.bitrate));

    return playlist.variants;
  }
}
