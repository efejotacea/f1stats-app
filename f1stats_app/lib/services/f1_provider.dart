import 'package:flutter/material.dart';
import '../models/models.dart';
import 'api_service.dart';

enum LoadState { idle, loading, loaded, error }

class F1Provider extends ChangeNotifier {
  final _api = F1ApiService();

  // ── Current season state ─────────────────────────────────────────────────
  String selectedSeason = '2024';

  LoadState driverStandingsState = LoadState.idle;
  LoadState constructorStandingsState = LoadState.idle;
  LoadState scheduleState = LoadState.idle;
  LoadState lastRaceState = LoadState.idle;

  List<DriverStanding> driverStandings = [];
  List<ConstructorStanding> constructorStandings = [];
  List<Race> schedule = [];
  Race? lastRace;
  String? error;

  List<String> get seasons => F1ApiService.availableSeasons;

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([
      loadDriverStandings(),
      loadConstructorStandings(),
      loadSchedule(),
      loadLastRace(),
    ]);
  }

  Future<void> changeSeason(String season) async {
    selectedSeason = season;
    notifyListeners();
    await Future.wait([
      loadDriverStandings(),
      loadConstructorStandings(),
      loadSchedule(),
    ]);
  }

  // ── Loaders ───────────────────────────────────────────────────────────────
  Future<void> loadDriverStandings() async {
    driverStandingsState = LoadState.loading;
    notifyListeners();
    try {
      driverStandings = await _api.getDriverStandings(selectedSeason);
      driverStandingsState = LoadState.loaded;
    } catch (e) {
      error = e.toString();
      driverStandingsState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadConstructorStandings() async {
    constructorStandingsState = LoadState.loading;
    notifyListeners();
    try {
      constructorStandings = await _api.getConstructorStandings(selectedSeason);
      constructorStandingsState = LoadState.loaded;
    } catch (e) {
      constructorStandingsState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadSchedule() async {
    scheduleState = LoadState.loading;
    notifyListeners();
    try {
      schedule = await _api.getSchedule(selectedSeason);
      scheduleState = LoadState.loaded;
    } catch (e) {
      scheduleState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadLastRace() async {
    lastRaceState = LoadState.loading;
    notifyListeners();
    try {
      lastRace = await _api.getLastRaceResults();
      lastRaceState = LoadState.loaded;
    } catch (e) {
      lastRaceState = LoadState.error;
    }
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Race? get nextRace {
    final now = DateTime.now();
    try {
      return schedule.firstWhere((r) => r.dateTime.isAfter(now));
    } catch (_) {
      return null;
    }
  }

  Future<Race?> getRaceResults(String season, int round) =>
      _api.getRaceResults(season, round);

  Future<List<Driver>> getDriversInSeason(String season) =>
      _api.getDriversInSeason(season);

  Future<List<Constructor>> getConstructorsInSeason(String season) =>
      _api.getConstructorsInSeason(season);

  Future<List<DriverSeasonStats>> getDriverCareer(String driverId) =>
      _api.getDriverCareer(driverId);

  Future<List<ConstructorSeasonStats>> getConstructorCareer(String constructorId) =>
      _api.getConstructorCareer(constructorId);
}
