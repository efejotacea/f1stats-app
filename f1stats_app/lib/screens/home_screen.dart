import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/f1_provider.dart';
import '../widgets/section_title.dart';
import '../widgets/driver_standing_tile.dart';
import '../widgets/shimmer_box.dart';
import 'race_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFE10600),
          onRefresh: () => context.read<F1Provider>().init(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(child: _NextRaceCard()),
              const SliverToBoxAdapter(child: SectionTitle('Últimos resultados')),
              SliverToBoxAdapter(child: _LastRaceResults()),
              const SliverToBoxAdapter(child: SectionTitle('Top clasificación 2024')),
              SliverToBoxAdapter(child: _TopStandings()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('F1 Stats',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            Text('Temporada 2024', style: TextStyle(color: Colors.white38, fontSize: 13)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFE10600), borderRadius: BorderRadius.circular(6)),
            child: const Text('F1',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

class _NextRaceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<F1Provider>(builder: (_, p, __) {
      if (p.scheduleState == LoadState.loading) {
        return Padding(
            padding: const EdgeInsets.all(16), child: ShimmerBox(height: 110, borderRadius: 14));
      }
      final race = p.nextRace;
      if (race == null) return const SizedBox();

      final daysLeft = race.dateTime.difference(DateTime.now()).inDays;
      final dateStr = DateFormat('d MMM yyyy', 'es').format(race.dateTime);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('PRÓXIMA CARRERA',
                style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.2)),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Text(race.countryFlag, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(race.raceName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(race.circuit.circuitName, style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Row(children: [
                  _Chip(dateStr, color: const Color(0xFFE10600)),
                  const SizedBox(width: 8),
                  _Chip('En $daysLeft días',
                      color: Colors.white12, textColor: Colors.white54),
                ]),
              ])),
            ]),
          ),
        ]),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _Chip(this.text, {required this.color, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _LastRaceResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<F1Provider>(builder: (_, p, __) {
      if (p.lastRaceState == LoadState.loading) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ShimmerBox(height: 56, borderRadius: 10),
          ))),
        );
      }
      final race = p.lastRace;
      if (race == null || race.results.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay resultados disponibles', style: TextStyle(color: Colors.white38)),
        );
      }

      final top3 = race.results.take(3).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          ...top3.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => RaceDetailScreen(race: race))),
              child: Container(
                decoration: BoxDecoration(
                  color: r.position == 1 ? const Color(0xFF1E1600) : const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  SizedBox(width: 24, child: Text('${r.position}', style: TextStyle(
                    color: r.position == 1 ? const Color(0xFFE8A000) : Colors.white38,
                    fontWeight: FontWeight.w600, fontSize: 14,
                  ))),
                  Container(width: 3, height: 28, decoration: BoxDecoration(
                    color: r.constructor.teamColor, borderRadius: BorderRadius.circular(2),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.driver.fullName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                    Text(r.constructor.name,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ])),
                  if (r.position == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE10600), borderRadius: BorderRadius.circular(4)),
                      child: const Text('25 pts',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    )
                  else
                    Text(r.time != null ? '+${r.time}' : r.status,
                        style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ]),
              ),
            ),
          )),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => RaceDetailScreen(race: race))),
            child: const Text('Ver clasificación completa →',
                style: TextStyle(color: Color(0xFFE10600), fontSize: 13)),
          ),
        ]),
      );
    });
  }
}

class _TopStandings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<F1Provider>(builder: (_, p, __) {
      if (p.driverStandingsState == LoadState.loading) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ShimmerBox(height: 56, borderRadius: 10),
          ))),
        );
      }
      final top5 = p.driverStandings.take(5).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: top5.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: DriverStandingTile(standing: s),
          )).toList(),
        ),
      );
    });
  }
}
