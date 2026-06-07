import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/f1_provider.dart';
import '../widgets/shimmer_box.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Comparador',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            TabBar(
              controller: _tab,
              indicatorColor: const Color(0xFFE10600),
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [Tab(text: 'PILOTOS'), Tab(text: 'EQUIPOS')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [const _DriverCompareTab(), const _ConstructorCompareTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  DRIVER COMPARE TAB
// ══════════════════════════════════════════════════════════════════════════════

class _DriverCompareTab extends StatefulWidget {
  const _DriverCompareTab();
  @override
  State<_DriverCompareTab> createState() => _DriverCompareTabState();
}

class _DriverCompareTabState extends State<_DriverCompareTab> {
  String _season = '2024';
  Driver? _driverA;
  Driver? _driverB;
  List<Driver> _availableDrivers = [];
  bool _loadingDrivers = false;

  List<DriverSeasonStats>? _statsA;
  List<DriverSeasonStats>? _statsB;
  bool _loadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() { _loadingDrivers = true; });
    try {
      final p = context.read<F1Provider>();
      _availableDrivers = await p.getDriversInSeason(_season);
    } catch (_) {}
    setState(() { _loadingDrivers = false; });
  }

  Future<void> _compare() async {
    if (_driverA == null || _driverB == null) return;
    setState(() { _loadingStats = true; _statsA = null; _statsB = null; });
    final p = context.read<F1Provider>();
    final results = await Future.wait([
      p.getDriverCareer(_driverA!.driverId),
      p.getDriverCareer(_driverB!.driverId),
    ]);
    setState(() { _statsA = results[0]; _statsB = results[1]; _loadingStats = false; });
  }

  void _changeSeason(String s) {
    setState(() { _season = s; _driverA = null; _driverB = null; _statsA = null; _statsB = null; });
    _loadDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Season picker row
        _SeasonRow(season: _season, onChanged: _changeSeason),
        const SizedBox(height: 16),

        // Selector cards
        Row(children: [
          Expanded(child: _DriverSelector(
            label: 'Piloto A',
            color: const Color(0xFFE10600),
            selected: _driverA,
            drivers: _availableDrivers,
            loading: _loadingDrivers,
            onSelected: (d) => setState(() { _driverA = d; _statsA = null; _statsB = null; }),
          )),
          const SizedBox(width: 10),
          const _VsChip(),
          const SizedBox(width: 10),
          Expanded(child: _DriverSelector(
            label: 'Piloto B',
            color: const Color(0xFF3671C6),
            selected: _driverB,
            drivers: _availableDrivers,
            loading: _loadingDrivers,
            onSelected: (d) => setState(() { _driverB = d; _statsA = null; _statsB = null; }),
          )),
        ]),
        const SizedBox(height: 16),

        // Compare button
        if (_driverA != null && _driverB != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadingStats ? null : _compare,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE10600),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _loadingStats
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Comparar trayectoria completa', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),

        // Results
        if (_loadingStats) ...[
          const SizedBox(height: 24),
          ShimmerBox(height: 200, borderRadius: 12),
        ] else if (_statsA != null && _statsB != null) ...[
          const SizedBox(height: 24),
          _DriverStatsComparison(
            driverA: _driverA!,
            driverB: _driverB!,
            statsA: _statsA!,
            statsB: _statsB!,
          ),
        ],
      ]),
    );
  }
}

class _DriverStatsComparison extends StatelessWidget {
  final Driver driverA;
  final Driver driverB;
  final List<DriverSeasonStats> statsA;
  final List<DriverSeasonStats> statsB;

  const _DriverStatsComparison({
    required this.driverA, required this.driverB,
    required this.statsA, required this.statsB,
  });

  int get _winsA => statsA.fold(0, (s, e) => s + e.wins);
  int get _winsB => statsB.fold(0, (s, e) => s + e.wins);
  int get _champA => statsA.where((s) => s.position == 1).length;
  int get _champB => statsB.where((s) => s.position == 1).length;
  double get _bestPtsA => statsA.isEmpty ? 0 : statsA.map((s) => s.points).reduce((a, b) => a > b ? a : b);
  double get _bestPtsB => statsB.isEmpty ? 0 : statsB.map((s) => s.points).reduce((a, b) => a > b ? a : b);
  int get _seasonsA => statsA.length;
  int get _seasonsB => statsB.length;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Header names
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(children: [
          Expanded(child: Text(driverA.fullName,
              style: const TextStyle(color: Color(0xFFE10600), fontWeight: FontWeight.w700, fontSize: 14),
              textAlign: TextAlign.center)),
          const Text('VS', style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w700)),
          Expanded(child: Text(driverB.fullName,
              style: const TextStyle(color: Color(0xFF3671C6), fontWeight: FontWeight.w700, fontSize: 14),
              textAlign: TextAlign.center)),
        ]),
      ),
      const SizedBox(height: 10),

      // Stat rows
      _StatBar(label: 'Campeonatos', valA: _champA.toDouble(), valB: _champB.toDouble(), isInt: true),
      _StatBar(label: 'Victorias totales', valA: _winsA.toDouble(), valB: _winsB.toDouble(), isInt: true),
      _StatBar(label: 'Mejor puntuación (temporada)', valA: _bestPtsA, valB: _bestPtsB),
      _StatBar(label: 'Temporadas en F1', valA: _seasonsA.toDouble(), valB: _seasonsB.toDouble(), isInt: true),

      const SizedBox(height: 16),

      // Season by season table
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              const SizedBox(width: 44, child: Text('AÑO', style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w600))),
              Expanded(child: Text(driverA.lastName.toUpperCase(),
                  style: const TextStyle(color: Color(0xFFE10600), fontSize: 10, fontWeight: FontWeight.w600))),
              Expanded(child: Text(driverB.lastName.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF3671C6), fontSize: 10, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
            ]),
          ),
          const Divider(height: 1, color: Colors.white10),
          ...(() {
            final allSeasons = {...statsA.map((s) => s.season), ...statsB.map((s) => s.season)}.toList()..sort((a, b) => b.compareTo(a));
            return allSeasons.take(15).map((season) {
              final a = statsA.firstWhere((s) => s.season == season, orElse: () => DriverSeasonStats(season: season, position: 0, points: 0, wins: 0, podiums: 0, poles: 0, team: '-'));
              final b = statsB.firstWhere((s) => s.season == season, orElse: () => DriverSeasonStats(season: season, position: 0, points: 0, wins: 0, podiums: 0, poles: 0, team: '-'));
              final aWon = a.position > 0 && b.position > 0 && a.position < b.position;
              final bWon = a.position > 0 && b.position > 0 && b.position < a.position;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04)))),
                child: Row(children: [
                  SizedBox(width: 44, child: Text(season, style: const TextStyle(color: Colors.white38, fontSize: 12))),
                  Expanded(child: a.position == 0
                      ? const Text('–', style: TextStyle(color: Colors.white24, fontSize: 12))
                      : Row(children: [
                          if (aWon) const Icon(Icons.arrow_upward, size: 12, color: Color(0xFFE10600)),
                          Text('P${a.position}  ${a.points.toStringAsFixed(0)}pts', style: TextStyle(
                            color: aWon ? const Color(0xFFE10600) : Colors.white54,
                            fontSize: 12,
                            fontWeight: aWon ? FontWeight.w600 : FontWeight.w400,
                          )),
                        ])),
                  Expanded(child: b.position == 0
                      ? const Text('–', style: TextStyle(color: Colors.white24, fontSize: 12), textAlign: TextAlign.right)
                      : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Text('P${b.position}  ${b.points.toStringAsFixed(0)}pts', style: TextStyle(
                            color: bWon ? const Color(0xFF3671C6) : Colors.white54,
                            fontSize: 12,
                            fontWeight: bWon ? FontWeight.w600 : FontWeight.w400,
                          )),
                          if (bWon) const Icon(Icons.arrow_upward, size: 12, color: Color(0xFF3671C6)),
                        ])),
                ]),
              );
            }).toList();
          })(),
        ]),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CONSTRUCTOR COMPARE TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ConstructorCompareTab extends StatefulWidget {
  const _ConstructorCompareTab();
  @override
  State<_ConstructorCompareTab> createState() => _ConstructorCompareTabState();
}

class _ConstructorCompareTabState extends State<_ConstructorCompareTab> {
  String _season = '2024';
  Constructor? _teamA;
  Constructor? _teamB;
  List<Constructor> _available = [];
  bool _loadingTeams = false;

  List<ConstructorSeasonStats>? _statsA;
  List<ConstructorSeasonStats>? _statsB;
  bool _loadingStats = false;

  @override
  void initState() { super.initState(); _loadTeams(); }

  Future<void> _loadTeams() async {
    setState(() { _loadingTeams = true; });
    try {
      _available = await context.read<F1Provider>().getConstructorsInSeason(_season);
    } catch (_) {}
    setState(() { _loadingTeams = false; });
  }

  Future<void> _compare() async {
    if (_teamA == null || _teamB == null) return;
    setState(() { _loadingStats = true; _statsA = null; _statsB = null; });
    final p = context.read<F1Provider>();
    final results = await Future.wait([
      p.getConstructorCareer(_teamA!.constructorId),
      p.getConstructorCareer(_teamB!.constructorId),
    ]);
    setState(() { _statsA = results[0]; _statsB = results[1]; _loadingStats = false; });
  }

  void _changeSeason(String s) {
    setState(() { _season = s; _teamA = null; _teamB = null; _statsA = null; _statsB = null; });
    _loadTeams();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _SeasonRow(season: _season, onChanged: _changeSeason),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(child: _TeamSelector(
            label: 'Equipo A',
            color: const Color(0xFFE10600),
            selected: _teamA,
            teams: _available,
            loading: _loadingTeams,
            onSelected: (t) => setState(() { _teamA = t; _statsA = null; _statsB = null; }),
          )),
          const SizedBox(width: 10),
          const _VsChip(),
          const SizedBox(width: 10),
          Expanded(child: _TeamSelector(
            label: 'Equipo B',
            color: const Color(0xFF3671C6),
            selected: _teamB,
            teams: _available,
            loading: _loadingTeams,
            onSelected: (t) => setState(() { _teamB = t; _statsA = null; _statsB = null; }),
          )),
        ]),
        const SizedBox(height: 16),

        if (_teamA != null && _teamB != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadingStats ? null : _compare,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE10600),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _loadingStats
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Comparar historia completa', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),

        if (_loadingStats) ...[
          const SizedBox(height: 24),
          ShimmerBox(height: 200, borderRadius: 12),
        ] else if (_statsA != null && _statsB != null) ...[
          const SizedBox(height: 24),
          _ConstructorStatsComparison(teamA: _teamA!, teamB: _teamB!, statsA: _statsA!, statsB: _statsB!),
        ],
      ]),
    );
  }
}

class _ConstructorStatsComparison extends StatelessWidget {
  final Constructor teamA, teamB;
  final List<ConstructorSeasonStats> statsA, statsB;

  const _ConstructorStatsComparison({required this.teamA, required this.teamB, required this.statsA, required this.statsB});

  int get _champsA => statsA.where((s) => s.position == 1).length;
  int get _champsB => statsB.where((s) => s.position == 1).length;
  int get _winsA => statsA.fold(0, (s, e) => s + e.wins);
  int get _winsB => statsB.fold(0, (s, e) => s + e.wins);
  int get _seasonsA => statsA.length;
  int get _seasonsB => statsB.length;
  double get _bestPtsA => statsA.isEmpty ? 0 : statsA.map((s) => s.points).reduce((a, b) => a > b ? a : b);
  double get _bestPtsB => statsB.isEmpty ? 0 : statsB.map((s) => s.points).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(children: [
          Expanded(child: Text(teamA.name,
              style: const TextStyle(color: Color(0xFFE10600), fontWeight: FontWeight.w700, fontSize: 14),
              textAlign: TextAlign.center)),
          const Text('VS', style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w700)),
          Expanded(child: Text(teamB.name,
              style: const TextStyle(color: Color(0xFF3671C6), fontWeight: FontWeight.w700, fontSize: 14),
              textAlign: TextAlign.center)),
        ]),
      ),
      const SizedBox(height: 10),
      _StatBar(label: 'Campeonatos de constructores', valA: _champsA.toDouble(), valB: _champsB.toDouble(), isInt: true),
      _StatBar(label: 'Victorias totales', valA: _winsA.toDouble(), valB: _winsB.toDouble(), isInt: true),
      _StatBar(label: 'Mejor puntuación (temporada)', valA: _bestPtsA, valB: _bestPtsB),
      _StatBar(label: 'Temporadas en F1', valA: _seasonsA.toDouble(), valB: _seasonsB.toDouble(), isInt: true),

      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              const SizedBox(width: 44, child: Text('AÑO', style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w600))),
              Expanded(child: Text(teamA.name.toUpperCase(), style: const TextStyle(color: Color(0xFFE10600), fontSize: 10, fontWeight: FontWeight.w600))),
              Expanded(child: Text(teamB.name.toUpperCase(), style: const TextStyle(color: Color(0xFF3671C6), fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            ]),
          ),
          const Divider(height: 1, color: Colors.white10),
          ...(() {
            final allSeasons = {...statsA.map((s) => s.season), ...statsB.map((s) => s.season)}.toList()..sort((a, b) => b.compareTo(a));
            return allSeasons.take(15).map((season) {
              final a = statsA.firstWhere((s) => s.season == season, orElse: () => ConstructorSeasonStats(season: season, position: 0, points: 0, wins: 0));
              final b = statsB.firstWhere((s) => s.season == season, orElse: () => ConstructorSeasonStats(season: season, position: 0, points: 0, wins: 0));
              final aWon = a.position > 0 && b.position > 0 && a.position < b.position;
              final bWon = a.position > 0 && b.position > 0 && b.position < a.position;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04)))),
                child: Row(children: [
                  SizedBox(width: 44, child: Text(season, style: const TextStyle(color: Colors.white38, fontSize: 12))),
                  Expanded(child: a.position == 0
                      ? const Text('–', style: TextStyle(color: Colors.white24, fontSize: 12))
                      : Text('P${a.position}  ${a.points.toStringAsFixed(0)}pts', style: TextStyle(
                          color: aWon ? const Color(0xFFE10600) : Colors.white54,
                          fontSize: 12, fontWeight: aWon ? FontWeight.w600 : FontWeight.w400))),
                  Expanded(child: b.position == 0
                      ? const Text('–', style: TextStyle(color: Colors.white24, fontSize: 12), textAlign: TextAlign.right)
                      : Text('P${b.position}  ${b.points.toStringAsFixed(0)}pts', style: TextStyle(
                          color: bWon ? const Color(0xFF3671C6) : Colors.white54,
                          fontSize: 12, fontWeight: bWon ? FontWeight.w600 : FontWeight.w400), textAlign: TextAlign.right)),
                ]),
              );
            }).toList();
          })(),
        ]),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _SeasonRow extends StatelessWidget {
  final String season;
  final void Function(String) onChanged;
  const _SeasonRow({required this.season, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final seasons = F1ApiService.availableSeasons;
    return Row(children: [
      const Text('Temporada base:', style: TextStyle(color: Colors.white54, fontSize: 13)),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF161616),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => _SeasonSheet(seasons: seasons, selected: season, onSelected: (s) { Navigator.pop(context); onChanged(s); }),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(children: [
            Text(season, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, color: Colors.white38, size: 16),
          ]),
        ),
      ),
    ]);
  }
}

class _SeasonSheet extends StatelessWidget {
  final List<String> seasons;
  final String selected;
  final void Function(String) onSelected;
  const _SeasonSheet({required this.seasons, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(height: 12),
    Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
    const SizedBox(height: 16),
    const Text('Temporada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
    const SizedBox(height: 12),
    Expanded(child: ListView.builder(
      itemCount: seasons.length,
      itemBuilder: (_, i) {
        final s = seasons[i];
        return ListTile(
          title: Text(s, style: TextStyle(color: s == selected ? const Color(0xFFE10600) : Colors.white)),
          trailing: s == selected ? const Icon(Icons.check, color: Color(0xFFE10600), size: 18) : null,
          onTap: () => onSelected(s),
        );
      },
    )),
  ]);
}

class _VsChip extends StatelessWidget {
  const _VsChip();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(6)),
    child: const Text('VS', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}

class _DriverSelector extends StatelessWidget {
  final String label;
  final Color color;
  final Driver? selected;
  final List<Driver> drivers;
  final bool loading;
  final void Function(Driver) onSelected;

  const _DriverSelector({required this.label, required this.color, required this.selected,
    required this.drivers, required this.loading, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : () => showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF161616),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _DriverPickerSheet(drivers: drivers, color: color, onSelected: (d) { Navigator.pop(context); onSelected(d); }),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected != null ? color.withOpacity(0.5) : Colors.white12),
        ),
        child: Column(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(Icons.person, color: color, size: 20)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 4),
          Text(selected?.lastName ?? 'Seleccionar', style: TextStyle(
            color: selected != null ? Colors.white : Colors.white30,
            fontWeight: FontWeight.w600, fontSize: 13,
          ), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _DriverPickerSheet extends StatefulWidget {
  final List<Driver> drivers;
  final Color color;
  final void Function(Driver) onSelected;
  const _DriverPickerSheet({required this.drivers, required this.color, required this.onSelected});
  @override
  State<_DriverPickerSheet> createState() => _DriverPickerSheetState();
}

class _DriverPickerSheetState extends State<_DriverPickerSheet> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.drivers.where((d) => d.fullName.toLowerCase().contains(_search.toLowerCase())).toList();
    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.7, maxChildSize: 0.95,
      builder: (_, ctrl) => Column(children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar piloto...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true, fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
          ),
        )),
        Expanded(child: ListView.builder(
          controller: ctrl,
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final d = filtered[i];
            return ListTile(
              leading: CircleAvatar(backgroundColor: widget.color.withOpacity(0.15),
                child: Text(d.code.isNotEmpty ? d.code.substring(0, 2) : d.lastName.substring(0, 2),
                    style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.w700))),
              title: Text(d.fullName, style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(d.nationality, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              onTap: () => widget.onSelected(d),
            );
          },
        )),
      ]),
    );
  }
}

class _TeamSelector extends StatelessWidget {
  final String label;
  final Color color;
  final Constructor? selected;
  final List<Constructor> teams;
  final bool loading;
  final void Function(Constructor) onSelected;

  const _TeamSelector({required this.label, required this.color, required this.selected,
    required this.teams, required this.loading, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : () => showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF161616),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _TeamPickerSheet(teams: teams, color: color, onSelected: (t) { Navigator.pop(context); onSelected(t); }),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected != null ? color.withOpacity(0.5) : Colors.white12),
        ),
        child: Column(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(
            color: (selected?.teamColor ?? color).withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(Icons.directions_car, color: selected?.teamColor ?? color, size: 20)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 4),
          Text(selected?.name ?? 'Seleccionar', style: TextStyle(
            color: selected != null ? Colors.white : Colors.white30,
            fontWeight: FontWeight.w600, fontSize: 12,
          ), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _TeamPickerSheet extends StatelessWidget {
  final List<Constructor> teams;
  final Color color;
  final void Function(Constructor) onSelected;
  const _TeamPickerSheet({required this.teams, required this.color, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.6, maxChildSize: 0.9,
      builder: (_, ctrl) => Column(children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Seleccionar equipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Expanded(child: ListView.builder(
          controller: ctrl,
          itemCount: teams.length,
          itemBuilder: (_, i) {
            final t = teams[i];
            return ListTile(
              leading: Container(width: 4, height: 32, decoration: BoxDecoration(color: t.teamColor, borderRadius: BorderRadius.circular(2))),
              title: Text(t.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(t.nationality, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              onTap: () => onSelected(t),
            );
          },
        )),
      ]),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final double valA, valB;
  final bool isInt;
  const _StatBar({required this.label, required this.valA, required this.valB, this.isInt = false});

  @override
  Widget build(BuildContext context) {
    final total = valA + valB;
    final fracA = total == 0 ? 0.5 : (valA / total).clamp(0.05, 0.95);
    final fracB = 1 - fracA;
    final aWins = valA > valB;
    final bWins = valB > valA;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: [
        Row(children: [
          Text(isInt ? valA.toInt().toString() : valA.toStringAsFixed(0),
              style: TextStyle(color: aWins ? const Color(0xFFE10600) : Colors.white54,
                  fontWeight: aWins ? FontWeight.w700 : FontWeight.w400, fontSize: 15)),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center)),
          Text(isInt ? valB.toInt().toString() : valB.toStringAsFixed(0),
              style: TextStyle(color: bWins ? const Color(0xFF3671C6) : Colors.white54,
                  fontWeight: bWins ? FontWeight.w700 : FontWeight.w400, fontSize: 15)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(flex: (fracA * 100).round(), child: Container(
            height: 5, decoration: BoxDecoration(
              color: aWins ? const Color(0xFFE10600) : Colors.white12,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3)),
            ),
          )),
          const SizedBox(width: 2),
          Expanded(flex: (fracB * 100).round(), child: Container(
            height: 5, decoration: BoxDecoration(
              color: bWins ? const Color(0xFF3671C6) : Colors.white12,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
            ),
          )),
        ]),
      ]),
    );
  }
}
