// To parse this JSON data, do
//
//     final twitchRecommendedChannelResponse = twitchRecommendedChannelResponseFromJson(jsonString);

import 'dart:convert';

class TwitchRecommendedChannelResponse {
  TwitchRecommendedChannelResponse({
    this.data,
    this.extensions,
  });

  final Data data;
  final Extensions extensions;

  factory TwitchRecommendedChannelResponse.fromRawJson(String str) => TwitchRecommendedChannelResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TwitchRecommendedChannelResponse.fromJson(Map<String, dynamic> json) => TwitchRecommendedChannelResponse(
    data: Data.fromJson(json["data"]),
    extensions: Extensions.fromJson(json["extensions"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "extensions": extensions.toJson(),
  };
}

class Data {
  Data({
    this.recommendedStreams,
  });

  final RecommendedStreams recommendedStreams;

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    recommendedStreams: RecommendedStreams.fromJson(json["recommendedStreams"]),
  );

  Map<String, dynamic> toJson() => {
    "recommendedStreams": recommendedStreams.toJson(),
  };
}

class RecommendedStreams {
  RecommendedStreams({
    this.generationId,
    this.responseId,
    this.edges,
    this.typename,
  });

  final String generationId;
  final String responseId;
  final List<Edge> edges;
  final String typename;

  factory RecommendedStreams.fromRawJson(String str) => RecommendedStreams.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecommendedStreams.fromJson(Map<String, dynamic> json) => RecommendedStreams(
    generationId: json["generationID"],
    responseId: json["responseID"],
    edges: List<Edge>.from(json["edges"].map((x) => Edge.fromJson(x))),
    typename: json["__typename"],
  );

  Map<String, dynamic> toJson() => {
    "generationID": generationId,
    "responseID": responseId,
    "edges": List<dynamic>.from(edges.map((x) => x.toJson())),
    "__typename": typename,
  };
}

class Edge {
  Edge({
    this.node,
    this.trackingId,
    this.typename,
  });

  final Node node;
  final String trackingId;
  final EdgeTypename typename;

  factory Edge.fromRawJson(String str) => Edge.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Edge.fromJson(Map<String, dynamic> json) => Edge(
    node: Node.fromJson(json["node"]),
    trackingId: json["trackingID"],
    typename: edgeTypenameValues.map[json["__typename"]],
  );

  Map<String, dynamic> toJson() => {
    "node": node.toJson(),
    "trackingID": trackingId,
    "__typename": edgeTypenameValues.reverse[typename],
  };
}

class Node {
  Node({
    this.id,
    this.broadcaster,
    this.game,
    this.viewersCount,
    this.typename,
  });

  final String id;
  final Broadcaster broadcaster;
  final Game game;
  final int viewersCount;
  final NodeTypename typename;

  factory Node.fromRawJson(String str) => Node.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Node.fromJson(Map<String, dynamic> json) => Node(
    id: json["id"],
    broadcaster: Broadcaster.fromJson(json["broadcaster"]),
    game: Game.fromJson(json["game"]),
    viewersCount: json["viewersCount"],
    typename: nodeTypenameValues.map[json["__typename"]],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "broadcaster": broadcaster.toJson(),
    "game": game.toJson(),
    "viewersCount": viewersCount,
    "__typename": nodeTypenameValues.reverse[typename],
  };
}

class Broadcaster {
  Broadcaster({
    this.id,
    this.broadcastSettings,
    this.displayName,
    this.login,
    this.profileImageUrl,
    this.typename,
  });

  final String id;
  final BroadcastSettings broadcastSettings;
  final String displayName;
  final String login;
  final String profileImageUrl;
  final BroadcasterTypename typename;

  factory Broadcaster.fromRawJson(String str) => Broadcaster.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Broadcaster.fromJson(Map<String, dynamic> json) => Broadcaster(
    id: json["id"],
    broadcastSettings: BroadcastSettings.fromJson(json["broadcastSettings"]),
    displayName: json["displayName"],
    login: json["login"],
    profileImageUrl: json["profileImageURL"],
    typename: broadcasterTypenameValues.map[json["__typename"]],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "broadcastSettings": broadcastSettings.toJson(),
    "displayName": displayName,
    "login": login,
    "profileImageURL": profileImageUrl,
    "__typename": broadcasterTypenameValues.reverse[typename],
  };
}

class BroadcastSettings {
  BroadcastSettings({
    this.id,
    this.title,
    this.typename,
  });

  final String id;
  final String title;
  final BroadcastSettingsTypename typename;

  factory BroadcastSettings.fromRawJson(String str) => BroadcastSettings.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BroadcastSettings.fromJson(Map<String, dynamic> json) => BroadcastSettings(
    id: json["id"],
    title: json["title"],
    typename: broadcastSettingsTypenameValues.map[json["__typename"]],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "__typename": broadcastSettingsTypenameValues.reverse[typename],
  };
}

enum BroadcastSettingsTypename { BROADCAST_SETTINGS }

final broadcastSettingsTypenameValues = EnumValues({
  "BroadcastSettings": BroadcastSettingsTypename.BROADCAST_SETTINGS
});

enum BroadcasterTypename { USER }

final broadcasterTypenameValues = EnumValues({
  "User": BroadcasterTypename.USER
});

class Game {
  Game({
    this.id,
    this.displayName,
    this.typename,
  });

  final String id;
  final String displayName;
  final GameTypename typename;

  factory Game.fromRawJson(String str) => Game.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json["id"],
    displayName: json["displayName"],
    typename: gameTypenameValues.map[json["__typename"]],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "displayName": displayName,
    "__typename": gameTypenameValues.reverse[typename],
  };
}

enum GameTypename { GAME }

final gameTypenameValues = EnumValues({
  "Game": GameTypename.GAME
});

enum NodeTypename { STREAM }

final nodeTypenameValues = EnumValues({
  "Stream": NodeTypename.STREAM
});

enum EdgeTypename { RECOMMENDED_STREAMS_EDGE }

final edgeTypenameValues = EnumValues({
  "RecommendedStreamsEdge": EdgeTypename.RECOMMENDED_STREAMS_EDGE
});

class Extensions {
  Extensions({
    this.durationMilliseconds,
    this.operationName,
    this.requestId,
  });

  final int durationMilliseconds;
  final String operationName;
  final String requestId;

  factory Extensions.fromRawJson(String str) => Extensions.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Extensions.fromJson(Map<String, dynamic> json) => Extensions(
    durationMilliseconds: json["durationMilliseconds"],
    operationName: json["operationName"],
    requestId: json["requestID"],
  );

  Map<String, dynamic> toJson() => {
    "durationMilliseconds": durationMilliseconds,
    "operationName": operationName,
    "requestID": requestId,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
