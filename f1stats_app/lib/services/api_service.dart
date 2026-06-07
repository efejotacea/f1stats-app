import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class F1ApiService {
  static const _base = 'https://ergast.com/api/f1';
  static const _timeout = Duration(seconds: 20);

  // Seasons available in Ergast API
  static List<String> get availableSeasons =>
      List.generate(2024 - 1950 + 1, (i) => (2024 - i).toString());

  Future<T> _get<T>(String path, T Function(Map<String, dynamic>) parser) async {
    final uri = Uri.parse('$_base$path.json?limit=100');
    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) throw Exception('Error ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return parser(data['MRData'] as Map<String, dynamic>);
  }

  // ── Standings by season ───────────────────────────────────────────────────
  Future<List<DriverStanding>> getDriverStandings(String season) =>
      _get('/$season/driverStandings', (data) {
        final table = data['StandingsTable']['StandingsLists'] as List;
        if (table.isEmpty) return <DriverStanding>[];
        return (table.first['DriverStandings'] as List)
            .map((e) => DriverStanding.fromJson(e, season: season))
            .toList();
      });

  Future<List<ConstructorStanding>> getConstructorStandings(String season) =>
      _get('/$season/constructorStandings', (data) {
        final table = data['StandingsTable']['StandingsLists'] as List;
        if (table.isEmpty) return <ConstructorStanding>[];
        return (table.first['ConstructorStandings'] as List)
            .map((e) => ConstructorStanding.fromJson(e, season: season))
            .toList();
      });

  // ── Schedule by season ────────────────────────────────────────────────────
  Future<List<Race>> getSchedule(String season) =>
      _get('/$season', (data) {
        return (data['RaceTable']['Races'] as List)
            .map((e) => Race.fromJson(e))
            .toList();
      });

  // ── Race results ──────────────────────────────────────────────────────────
  Future<Race?> getRaceResults(String season, int round) =>
      _get('/$season/$round/results', (data) {
        final races = data['RaceTable']['Races'] as List;
        if (races.isEmpty) return null;
        return Race.fromJson(races.first);
      });

  Future<Race?> getLastRaceResults() =>
      _get('/current/last/results', (data) {
        final races = data['RaceTable']['Races'] as List;
        if (races.isEmpty) return null;
        return Race.fromJson(races.first);
      });

  // ── All drivers in a season ───────────────────────────────────────────────
  Future<List<Driver>> getDriversInSeason(String season) =>
      _get('/$season/drivers', (data) {
        return (data['DriverTable']['Drivers'] as List)
            .map((e) => Driver.fromJson(e))
            .toList();
      });

  // ── All constructors in a season ──────────────────────────────────────────
  Future<List<Constructor>> getConstructorsInSeason(String season) =>
      _get('/$season/constructors', (data) {
        return (data['ConstructorTable']['Constructors'] as List)
            .map((e) => Constructor.fromJson(e))
            .toList();
      });

  // ── Driver career: standing per season ───────────────────────────────────
  Future<List<DriverSeasonStats>> getDriverCareer(String driverId) async {
    final data = await _get('/drivers/$driverId/driverStandings', (data) {
      return data['StandingsTable']['StandingsLists'] as List;
    });

    // Also get podiums across all seasons
    final results = <DriverSeasonStats>[];
    for (final seasonData in data) {
      final season = seasonData['season'] as String;
      final standings = seasonData['DriverStandings'] as List;
      if (standings.isEmpty) continue;
      final s = standings.first;
      final constructors = s['Constructors'] as List;
      results.add(DriverSeasonStats(
        season: season,
        position: int.tryParse(s['position'] ?? '0') ?? 0,
        points: double.tryParse(s['points'] ?? '0') ?? 0,
        wins: int.tryParse(s['wins'] ?? '0') ?? 0,
        podiums: 0, // would need extra call
        poles: 0,
        team: constructors.isNotEmpty ? constructors.last['name'] ?? '' : '',
      ));
    }
    return results.reversed.toList();
  }

  // ── Constructor career ────────────────────────────────────────────────────
  Future<List<ConstructorSeasonStats>> getConstructorCareer(String constructorId) async {
    final data = await _get('/constructors/$constructorId/constructorStandings', (data) {
      return data['StandingsTable']['StandingsLists'] as List;
    });

    return data.map<ConstructorSeasonStats>((seasonData) {
      final season = seasonData['season'] as String;
      final standings = seasonData['ConstructorStandings'] as List;
      if (standings.isEmpty) {
        return ConstructorSeasonStats(season: season, position: 0, points: 0, wins: 0);
      }
      final s = standings.first;
      return ConstructorSeasonStats(
        season: season,
        position: int.tryParse(s['position'] ?? '0') ?? 0,
        points: double.tryParse(s['points'] ?? '0') ?? 0,
        wins: int.tryParse(s['wins'] ?? '0') ?? 0,
      );
    }).toList().reversed.toList();
  }

  // ── Qualifying results ────────────────────────────────────────────────────
  Future<List<QualifyingResult>> getQualifyingResults(String season, int round) =>
      _get('/$season/$round/qualifying', (data) {
        final races = data['RaceTable']['Races'] as List;
        if (races.isEmpty) return <QualifyingResult>[];
        return (races.first['QualifyingResults'] as List? ?? [])
            .map((e) => QualifyingResult.fromJson(e))
            .toList();
      });
}
