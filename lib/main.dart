import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:http/http.dart';
import 'package:twitch_speedtest/src/geoip/geoip.dart';
import 'package:twitch_speedtest/src/geoip/response.dart';
import 'package:twitch_speedtest/src/twitch/client.dart';
import 'dart:ui' as ui;

import 'package:twitch_speedtest/src/twitch/servers.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Main(title: 'Twitch SpeedTest'),
    );
  }
}

class Main extends StatefulWidget {
  Main({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  bool isLoading = true;

  final client = new TwitchClient();
  List<List<Variant>> hlsVariantsInfos;
  Set<TwitchServer> twitchServers = Set();
  String servers = '';
  GeoIpResponse myIpInfo;

  @override
  void initState() {
    super.initState();

    _load();
  }

  void _load() async {
    try {
      myIpInfo = await GeoIP.getMyInfo();
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _start() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      twitchServers.clear();
    });

    final streams = await client.getRecommendedStreams(count: 15);
    hlsVariantsInfos = await Future.wait(
      streams.map((stream) async {
        final accessToken = await client.getChannelAccessToken(username: stream.broadcaster.username);

        return client.getHLSInfo(
          username: stream.broadcaster.username,
          token: accessToken.token,
          signature: accessToken.sig,
        );
      }),
    );

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

    setState(() {
      twitchServers = servers;
    });
    print("servers set");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isLoading ?
            CircularProgressIndicator() :
            FloatingActionButton(onPressed: _start, tooltip: 'Test', child: Icon(Icons.arrow_right, size: 32)),
            Text(
              'qkRnj',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              twitchServers.length == 0 ? '' : 'server(s): ${twitchServers.map((server) => server.location).join(', ')}',
            ),
          ],
        ),
      ),
    );
  }
}
