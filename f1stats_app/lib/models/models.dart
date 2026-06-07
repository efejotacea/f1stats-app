import 'package:flutter/material.dart';

// ── Driver ───────────────────────────────────────────────────────────────────
class Driver {
  final String driverId;
  final String code;
  final String firstName;
  final String lastName;
  final String nationality;
  final String dateOfBirth;
  final String? wikipediaUrl;

  const Driver({
    required this.driverId,
    required this.code,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.dateOfBirth,
    this.wikipediaUrl,
  });

  String get fullName => '$firstName $lastName';

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        driverId: json['driverId'] ?? '',
        code: json['code'] ?? '',
        firstName: json['givenName'] ?? '',
        lastName: json['familyName'] ?? '',
        nationality: json['nationality'] ?? '',
        dateOfBirth: json['dateOfBirth'] ?? '',
        wikipediaUrl: json['url'],
      );
}

// ── Constructor (Team) ───────────────────────────────────────────────────────
class Constructor {
  final String constructorId;
  final String name;
  final String nationality;

  const Constructor({
    required this.constructorId,
    required this.name,
    required this.nationality,
  });

  factory Constructor.fromJson(Map<String, dynamic> json) => Constructor(
        constructorId: json['constructorId'] ?? '',
        name: json['name'] ?? '',
        nationality: json['nationality'] ?? '',
      );

  Color get teamColor {
    switch (constructorId) {
      case 'ferrari': return const Color(0xFFE8002D);
      case 'mercedes': return const Color(0xFF27F4D2);
      case 'red_bull': return const Color(0xFF3671C6);
      case 'mclaren': return const Color(0xFFFF8000);
      case 'alpine': return const Color(0xFF0093CC);
      case 'aston_martin': return const Color(0xFF358C75);
      case 'williams': return const Color(0xFF64C4FF);
      case 'rb':
      case 'alphatauri': return const Color(0xFF6692FF);
      case 'kick_sauber':
      case 'alfa': return const Color(0xFF52E252);
      case 'haas': return const Color(0xFFB6BABD);
      case 'renault': return const Color(0xFFFFD700);
      case 'brawn': return const Color(0xFFB8FF00);
      case 'lotus_f1':
      case 'lotus': return const Color(0xFFFFB800);
      case 'force_india': return const Color(0xFFFF80C7);
      case 'sauber': return const Color(0xFF006EFF);
      case 'toro_rosso': return const Color(0xFF4E7CFF);
      default: return const Color(0xFF888888);
    }
  }
}

// ── Driver Standing ──────────────────────────────────────────────────────────
class DriverStanding {
  final int position;
  final String points;
  final int wins;
  final Driver driver;
  final Constructor constructor;
  final String? season;

  const DriverStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.driver,
    required this.constructor,
    this.season,
  });

  factory DriverStanding.fromJson(Map<String, dynamic> json, {String? season}) {
    final constructors = json['Constructors'] as List;
    return DriverStanding(
      position: int.tryParse(json['position'] ?? '0') ?? 0,
      points: json['points'] ?? '0',
      wins: int.tryParse(json['wins'] ?? '0') ?? 0,
      driver: Driver.fromJson(json['Driver']),
      constructor: Constructor.fromJson(constructors.first),
      season: season,
    );
  }
}

// ── Constructor Standing ─────────────────────────────────────────────────────
class ConstructorStanding {
  final int position;
  final String points;
  final int wins;
  final Constructor constructor;
  final String? season;

  const ConstructorStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.constructor,
    this.season,
  });

  factory ConstructorStanding.fromJson(Map<String, dynamic> json, {String? season}) =>
      ConstructorStanding(
        position: int.tryParse(json['position'] ?? '0') ?? 0,
        points: json['points'] ?? '0',
        wins: int.tryParse(json['wins'] ?? '0') ?? 0,
        constructor: Constructor.fromJson(json['Constructor']),
        season: season,
      );
}

// ── Driver Season Stats (for comparison) ─────────────────────────────────────
class DriverSeasonStats {
  final String season;
  final int position;
  final double points;
  final int wins;
  final int podiums;
  final int poles;
  final String team;

  const DriverSeasonStats({
    required this.season,
    required this.position,
    required this.points,
    required this.wins,
    required this.podiums,
    required this.poles,
    required this.team,
  });
}

// ── Constructor Season Stats (for comparison) ─────────────────────────────────
class ConstructorSeasonStats {
  final String season;
  final int position;
  final double points;
  final int wins;

  const ConstructorSeasonStats({
    required this.season,
    required this.position,
    required this.points,
    required this.wins,
  });
}

// ── Race ─────────────────────────────────────────────────────────────────────
class Race {
  final String season;
  final int round;
  final String raceName;
  final Circuit circuit;
  final String date;
  final String? time;
  final List<RaceResult> results;

  const Race({
    required this.season,
    required this.round,
    required this.raceName,
    required this.circuit,
    required this.date,
    this.time,
    this.results = const [],
  });

  factory Race.fromJson(Map<String, dynamic> json) => Race(
        season: json['season'] ?? '',
        round: int.tryParse(json['round'] ?? '0') ?? 0,
        raceName: json['raceName'] ?? '',
        circuit: Circuit.fromJson(json['Circuit']),
        date: json['date'] ?? '',
        time: json['time'],
        results: (json['Results'] as List? ?? [])
            .map((r) => RaceResult.fromJson(r))
            .toList(),
      );

  DateTime get dateTime => DateTime.tryParse(date) ?? DateTime.now();

  String get countryFlag {
    final country = circuit.country.toLowerCase();
    const flags = {
      'australia': '🇦🇺', 'china': '🇨🇳', 'japan': '🇯🇵',
      'bahrain': '🇧🇭', 'saudi arabia': '🇸🇦',
      'usa': '🇺🇸', 'united states': '🇺🇸', 'italy': '🇮🇹',
      'monaco': '🇲🇨', 'spain': '🇪🇸', 'canada': '🇨🇦',
      'uk': '🇬🇧', 'great britain': '🇬🇧', 'hungary': '🇭🇺',
      'belgium': '🇧🇪', 'netherlands': '🇳🇱', 'singapore': '🇸🇬',
      'mexico': '🇲🇽', 'brazil': '🇧🇷',
      'qatar': '🇶🇦', 'abu dhabi': '🇦🇪', 'austria': '🇦🇹',
      'azerbaijan': '🇦🇿', 'germany': '🇩🇪', 'france': '🇫🇷',
      'turkey': '🇹🇷', 'portugal': '🇵🇹', 'russia': '🇷🇺',
      'korea': '🇰🇷', 'india': '🇮🇳',
    };
    for (final entry in flags.entries) {
      if (country.contains(entry.key)) return entry.value;
    }
    return '🏁';
  }
}

// ── Circuit ──────────────────────────────────────────────────────────────────
class Circuit {
  final String circuitId;
  final String circuitName;
  final String locality;
  final String country;

  const Circuit({
    required this.circuitId,
    required this.circuitName,
    required this.locality,
    required this.country,
  });

  factory Circuit.fromJson(Map<String, dynamic> json) => Circuit(
        circuitId: json['circuitId'] ?? '',
        circuitName: json['circuitName'] ?? '',
        locality: json['Location']?['locality'] ?? '',
        country: json['Location']?['country'] ?? '',
      );
}

// ── Race Result ──────────────────────────────────────────────────────────────
class RaceResult {
  final int position;
  final String points;
  final Driver driver;
  final Constructor constructor;
  final String? time;
  final String? fastestLapTime;
  final String status;
  final int grid;
  final int laps;

  const RaceResult({
    required this.position,
    required this.points,
    required this.driver,
    required this.constructor,
    this.time,
    this.fastestLapTime,
    required this.status,
    required this.grid,
    required this.laps,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) => RaceResult(
        position: int.tryParse(json['position'] ?? '0') ?? 0,
        points: json['points'] ?? '0',
        driver: Driver.fromJson(json['Driver']),
        constructor: Constructor.fromJson(json['Constructor']),
        time: json['Time']?['time'],
        fastestLapTime: json['FastestLap']?['Time']?['time'],
        status: json['status'] ?? '',
        grid: int.tryParse(json['grid'] ?? '0') ?? 0,
        laps: int.tryParse(json['laps'] ?? '0') ?? 0,
      );
}

// ── Qualifying Result ─────────────────────────────────────────────────────────
class QualifyingResult {
  final int position;
  final Driver driver;
  final Constructor constructor;
  final String? q1;
  final String? q2;
  final String? q3;

  const QualifyingResult({
    required this.position,
    required this.driver,
    required this.constructor,
    this.q1,
    this.q2,
    this.q3,
  });

  factory QualifyingResult.fromJson(Map<String, dynamic> json) =>
      QualifyingResult(
        position: int.tryParse(json['position'] ?? '0') ?? 0,
        driver: Driver.fromJson(json['Driver']),
        constructor: Constructor.fromJson(json['Constructor']),
        q1: json['Q1'],
        q2: json['Q2'],
        q3: json['Q3'],
      );
}
