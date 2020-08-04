enum TwitchRegion {
  Asia,
  Australia,
  Europe,
  NorthAmerica,
  SouthAmerica,
  USCentral,
  USEast,
  USWest,
  NA,
}

class TwitchServer {
  final String code;
  final TwitchRegion region;
  final String location;

  TwitchServer(this.code, this.region, this.location);
}

final TwitchServers = [
  TwitchServer('HKG', TwitchRegion.Asia, 'Hong Kong'),
  TwitchServer('TYO', TwitchRegion.Asia, 'Japan, Tokyo'),
  TwitchServer('SIN', TwitchRegion.Asia, 'Singapore'),
  TwitchServer('SEL', TwitchRegion.Asia, 'South Korea, Seoul'),
  TwitchServer('TPE', TwitchRegion.Asia, 'Taiwan, Taipei'),
  TwitchServer('BKK', TwitchRegion.Asia, 'Thailand, Bangkok'),
  TwitchServer('SYD', TwitchRegion.Australia, 'Sydney'),
  TwitchServer('VIE', TwitchRegion.Europe, 'Austria, Vienna'),
  TwitchServer('PRG', TwitchRegion.Europe, 'Czech Republic, Prague'),
  TwitchServer('CPH', TwitchRegion.Europe, 'Denmark, Copenhagen'),
  TwitchServer('HEL', TwitchRegion.Europe, 'Finland, Helsinki'),
  TwitchServer('MRS', TwitchRegion.Europe, 'France, Marseille'),
  TwitchServer('CDG', TwitchRegion.Europe, 'France, Paris'),
  TwitchServer('BER', TwitchRegion.Europe, 'Germany, Berlin'),
  TwitchServer('FRA', TwitchRegion.Europe, 'Germany, Frankfurt'),
  TwitchServer('MIL', TwitchRegion.Europe, 'Italy, Milan'),
  TwitchServer('AMS', TwitchRegion.Europe, 'Netherlands, Amsterdam'),
  TwitchServer('OSL', TwitchRegion.Europe, 'Norway, Oslo'),
  TwitchServer('WAW', TwitchRegion.Europe, 'Poland, Warsaw'),
  TwitchServer('MAD', TwitchRegion.Europe, 'Spain, Madrid'),
  TwitchServer('ARN', TwitchRegion.Europe, 'Sweden, Stockholm'),
  TwitchServer('LHR', TwitchRegion.Europe, 'UK, London'),
  TwitchServer('YMQ', TwitchRegion.NorthAmerica, 'Canada, Quebec'),
  TwitchServer('YTO', TwitchRegion.NorthAmerica, 'Canada, Toronto'),
  TwitchServer('QRO', TwitchRegion.NorthAmerica, 'Mexico, Queretaro'),
  TwitchServer('RIO', TwitchRegion.SouthAmerica, 'Brazil, Rio de Janeiro'),
  TwitchServer('SAO', TwitchRegion.SouthAmerica, 'Brazil, Sao Paulo'),
  TwitchServer('DFW', TwitchRegion.USCentral, 'Dallas, TX'),
  TwitchServer('DEN', TwitchRegion.USCentral, 'Denver, CO'),
  TwitchServer('HOU', TwitchRegion.USCentral, 'Houston, TX'),
  TwitchServer('IAD', TwitchRegion.USCentral, 'Ashburn, VA'),
  TwitchServer('ATL', TwitchRegion.USCentral, 'Atlanta, GA'),
  TwitchServer('ORD', TwitchRegion.USCentral, 'Chicago, IL'),
  TwitchServer('MIA', TwitchRegion.USCentral, 'Miami, FL'),
  TwitchServer('JFK', TwitchRegion.USCentral, 'New York, NY'),
  TwitchServer('LAX', TwitchRegion.USCentral, 'Los Angeles, CA'),
  TwitchServer('PHX', TwitchRegion.USCentral, 'Phoenix, AZ'),
  TwitchServer('PDX', TwitchRegion.USCentral, 'Portland, OR'),
  TwitchServer('SLC', TwitchRegion.USCentral, 'Salt Lake City, UT'),
  TwitchServer('SFO', TwitchRegion.USCentral, 'San Francisco, CA'),
  TwitchServer('SJC', TwitchRegion.USCentral, 'San Jose, CA'),
  TwitchServer('SEA', TwitchRegion.USCentral, 'Seattle, WA'),
];

TwitchServer findTwitchServer(String code) {
  return TwitchServers.firstWhere((server) => code.toUpperCase().startsWith(server.code));
}
