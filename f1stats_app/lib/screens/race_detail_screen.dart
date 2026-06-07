import 'package:flutter/material.dart';
import '../models/models.dart';

class RaceDetailScreen extends StatelessWidget {
  final Race race;
  const RaceDetailScreen({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF161616),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(race.countryFlag, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(race.raceName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                        )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${race.circuit.circuitName} · ${race.season}',
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          if (race.results.isNotEmpty) ...[
            SliverToBoxAdapter(child: _Podium(results: race.results.take(3).toList())),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('CLASIFICACIÓN COMPLETA', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.2)),
              ),
            ),
            SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _ResultRow(result: race.results[i]),
              childCount: race.results.length,
            )),
          ] else
            const SliverFillRemaining(
              child: Center(child: Text('Sin resultados disponibles', style: TextStyle(color: Colors.white38))),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<RaceResult> results;
  const _Podium({required this.results});

  @override
  Widget build(BuildContext context) {
    final p1 = results.isNotEmpty ? results[0] : null;
    final p2 = results.length > 1 ? results[1] : null;
    final p3 = results.length > 2 ? results[2] : null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          const Text('PODIO', style: TextStyle(color: Colors.white30, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (p2 != null) _PodiumColumn(result: p2, height: 70, medal: '🥈'),
              if (p1 != null) _PodiumColumn(result: p1, height: 90, medal: '🥇'),
              if (p3 != null) _PodiumColumn(result: p3, height: 55, medal: '🥉'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final RaceResult result;
  final double height;
  final String medal;
  const _PodiumColumn({required this.result, required this.height, required this.medal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Container(width: 3, height: 28, decoration: BoxDecoration(
          color: result.constructor.teamColor, borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(height: 6),
        Text(result.driver.lastName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        Text(result.constructor.name, style: const TextStyle(color: Colors.white30, fontSize: 10)),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: 80,
          decoration: BoxDecoration(
            color: result.position == 1
                ? const Color(0xFF1E1600)
                : const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            border: Border(top: BorderSide(color: result.constructor.teamColor, width: 2)),
          ),
          alignment: Alignment.center,
          child: Text('P${result.position}', style: TextStyle(
            color: result.position == 1 ? const Color(0xFFE8A000) : Colors.white38,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          )),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final RaceResult result;
  const _ResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('${result.position}', style: TextStyle(
            color: result.position <= 3 ? const Color(0xFFE8A000) : Colors.white38,
            fontWeight: FontWeight.w600, fontSize: 13,
          ))),
          Container(width: 3, height: 28, decoration: BoxDecoration(
            color: result.constructor.teamColor, borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.driver.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
              Text(result.constructor.name, style: const TextStyle(color: Colors.white30, fontSize: 10)),
            ],
          )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                result.time != null ? (result.position == 1 ? result.time! : '+${result.time}') : result.status,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text('${result.points} pts', style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
