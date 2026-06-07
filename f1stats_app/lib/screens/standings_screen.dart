import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/f1_provider.dart';
import '../widgets/driver_standing_tile.dart';
import '../widgets/shimmer_box.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});
  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen>
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
            _Header(tab: _tab),
            TabBar(
              controller: _tab,
              indicatorColor: const Color(0xFFE10600),
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [Tab(text: 'PILOTOS'), Tab(text: 'CONSTRUCTORES')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [_DriverTab(), _ConstructorTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TabController tab;
  const _Header({required this.tab});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<F1Provider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text('Clasificación',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          // Season picker
          GestureDetector(
            onTap: () => _showSeasonPicker(context, p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Text(p.selectedSeason,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, color: Colors.white38, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSeasonPicker(BuildContext context, F1Provider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SeasonPickerSheet(
        seasons: p.seasons,
        selected: p.selectedSeason,
        onSelected: (s) { Navigator.pop(context); p.changeSeason(s); },
      ),
    );
  }
}

class _SeasonPickerSheet extends StatelessWidget {
  final List<String> seasons;
  final String selected;
  final void Function(String) onSelected;

  const _SeasonPickerSheet({required this.seasons, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Selecciona temporada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: seasons.length,
            itemBuilder: (_, i) {
              final s = seasons[i];
              final isSelected = s == selected;
              return ListTile(
                title: Text(s, style: TextStyle(
                  color: isSelected ? const Color(0xFFE10600) : Colors.white,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                )),
                trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFE10600), size: 18) : null,
                onTap: () => onSelected(s),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DriverTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<F1Provider>(builder: (_, p, __) {
      if (p.driverStandingsState == LoadState.loading) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ShimmerBox(height: 64, borderRadius: 10),
          ),
        );
      }
      if (p.driverStandings.isEmpty) {
        return const Center(child: Text('Sin datos disponibles', style: TextStyle(color: Colors.white38)));
      }
      return RefreshIndicator(
        color: const Color(0xFFE10600),
        onRefresh: () => p.loadDriverStandings(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: p.driverStandings.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: DriverStandingTile(standing: p.driverStandings[i], showWins: true),
          ),
        ),
      );
    });
  }
}

class _ConstructorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<F1Provider>(builder: (_, p, __) {
      if (p.constructorStandingsState == LoadState.loading) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ShimmerBox(height: 64, borderRadius: 10)),
        );
      }
      if (p.constructorStandings.isEmpty) {
        return const Center(child: Text('Sin datos disponibles', style: TextStyle(color: Colors.white38)));
      }
      return RefreshIndicator(
        color: const Color(0xFFE10600),
        onRefresh: () => p.loadConstructorStandings(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: p.constructorStandings.length,
          itemBuilder: (_, i) {
            final s = p.constructorStandings[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.07)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  SizedBox(width: 28, child: Text('${s.position}', style: TextStyle(
                    color: s.position == 1 ? const Color(0xFFE10600) : Colors.white38,
                    fontWeight: FontWeight.w700, fontSize: 15,
                  ))),
                  Container(width: 3, height: 32, decoration: BoxDecoration(
                    color: s.constructor.teamColor, borderRadius: BorderRadius.circular(2),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.constructor.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(s.constructor.nationality, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(s.points, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    const Text('PTS', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ]),
                ]),
              ),
            );
          },
        ),
      );
    });
  }
}
