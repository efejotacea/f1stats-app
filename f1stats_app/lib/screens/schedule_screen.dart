import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/f1_provider.dart';
import '../models/models.dart';
import '../widgets/shimmer_box.dart';
import 'race_detail_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(child: _RaceList()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<F1Provider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text('Calendario',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSeasonPicker(context, p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(children: [
                Text(p.selectedSeason,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, color: Colors.white38, size: 16),
              ]),
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
      builder: (_) => Column(children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Selecciona temporada',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        Expanded(child: ListView.builder(
          itemCount: p.seasons.length,
          itemBuilder: (_, i) {
            final s = p.seasons[i];
            final isSelected = s == p.selectedSeason;
            return ListTile(
              title: Text(s, style: TextStyle(
                color: isSelected ? const Color(0xFFE10600) : Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              )),
              trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFE10600), size: 18) : null,
              onTap: () { Navigator.pop(context); p.changeSeason(s); },
            );
          },
        )),
      ]),
    );
  }
}

class _RaceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<F1Provider>(builder: (_, p, __) {
      if (p.scheduleState == LoadState.loading) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 12,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ShimmerBox(height: 80, borderRadius: 12),
          ),
        );
      }
      if (p.schedule.isEmpty) {
        return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.white38)));
      }

      final isCurrentSeason = p.selectedSeason == DateTime.now().year.toString() ||
          p.selectedSeason == '2024';

      return RefreshIndicator(
        color: const Color(0xFFE10600),
        onRefresh: () => p.loadSchedule(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: p.schedule.length,
          itemBuilder: (_, i) {
            final race = p.schedule[i];
            final isPast = race.dateTime.isBefore(DateTime.now());
            final isNext = isCurrentSeason && p.nextRace?.round == race.round;
            return _RaceCard(race: race, isPast: isPast || !isCurrentSeason, isNext: isNext);
          },
        ),
      );
    });
  }
}

class _RaceCard extends StatelessWidget {
  final Race race;
  final bool isPast;
  final bool isNext;

  const _RaceCard({required this.race, required this.isPast, required this.isNext});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM', 'es').format(race.dateTime);

    return GestureDetector(
      onTap: isPast
          ? () async {
              final p = context.read<F1Provider>();
              final result = await p.getRaceResults(race.season, race.round);
              if (result != null && context.mounted) {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => RaceDetailScreen(race: result)));
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isNext ? const Color(0xFF1A0A0A) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNext
                ? const Color(0xFFE10600).withOpacity(0.5)
                : Colors.white.withOpacity(0.06),
            width: isNext ? 1 : 0.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isPast
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFE10600).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('R${race.round}', style: TextStyle(
              color: isPast ? Colors.white30 : const Color(0xFFE10600),
              fontSize: 11, fontWeight: FontWeight.w700,
            )),
          ),
          const SizedBox(width: 12),
          Text(race.countryFlag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(race.raceName, style: TextStyle(
              color: isPast ? Colors.white54 : Colors.white,
              fontWeight: FontWeight.w500, fontSize: 13,
            )),
            const SizedBox(height: 2),
            Text(race.circuit.locality, style: const TextStyle(color: Colors.white30, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(dateStr, style: TextStyle(
              color: isPast ? Colors.white30 : Colors.white70,
              fontSize: 12, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            if (isPast)
              const Icon(Icons.check_circle_outline, size: 14, color: Colors.green)
            else if (isNext)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFE10600), borderRadius: BorderRadius.circular(4)),
                child: const Text('Próxima',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
              )
            else
              const Icon(Icons.radio_button_unchecked, size: 14, color: Colors.white24),
          ]),
        ]),
      ),
    );
  }
}
