import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _champions = [
    {'year': '2024', 'driver': 'Max Verstappen', 'team': 'Red Bull Racing', 'flag': '🇳🇱', 'color': 0xFF3671C6},
    {'year': '2023', 'driver': 'Max Verstappen', 'team': 'Red Bull Racing', 'flag': '🇳🇱', 'color': 0xFF3671C6},
    {'year': '2022', 'driver': 'Max Verstappen', 'team': 'Red Bull Racing', 'flag': '🇳🇱', 'color': 0xFF3671C6},
    {'year': '2021', 'driver': 'Max Verstappen', 'team': 'Red Bull Racing', 'flag': '🇳🇱', 'color': 0xFF3671C6},
    {'year': '2020', 'driver': 'Lewis Hamilton', 'team': 'Mercedes-AMG', 'flag': '🇬🇧', 'color': 0xFF27F4D2},
    {'year': '2019', 'driver': 'Lewis Hamilton', 'team': 'Mercedes-AMG', 'flag': '🇬🇧', 'color': 0xFF27F4D2},
    {'year': '2018', 'driver': 'Lewis Hamilton', 'team': 'Mercedes-AMG', 'flag': '🇬🇧', 'color': 0xFF27F4D2},
    {'year': '2017', 'driver': 'Lewis Hamilton', 'team': 'Mercedes-AMG', 'flag': '🇬🇧', 'color': 0xFF27F4D2},
    {'year': '2016', 'driver': 'Nico Rosberg', 'team': 'Mercedes-AMG', 'flag': '🇩🇪', 'color': 0xFF27F4D2},
    {'year': '2015', 'driver': 'Lewis Hamilton', 'team': 'Mercedes-AMG', 'flag': '🇬🇧', 'color': 0xFF27F4D2},
    {'year': '2014', 'driver': 'Lewis Hamilton', 'team': 'Mercedes-AMG', 'flag': '🇬🇧', 'color': 0xFF27F4D2},
    {'year': '2013', 'driver': 'Sebastian Vettel', 'team': 'Red Bull Racing', 'flag': '🇩🇪', 'color': 0xFF3671C6},
    {'year': '2012', 'driver': 'Sebastian Vettel', 'team': 'Red Bull Racing', 'flag': '🇩🇪', 'color': 0xFF3671C6},
    {'year': '2011', 'driver': 'Sebastian Vettel', 'team': 'Red Bull Racing', 'flag': '🇩🇪', 'color': 0xFF3671C6},
    {'year': '2010', 'driver': 'Sebastian Vettel', 'team': 'Red Bull Racing', 'flag': '🇩🇪', 'color': 0xFF3671C6},
    {'year': '2009', 'driver': 'Jenson Button', 'team': 'Brawn GP', 'flag': '🇬🇧', 'color': 0xFF888888},
    {'year': '2008', 'driver': 'Lewis Hamilton', 'team': 'McLaren', 'flag': '🇬🇧', 'color': 0xFFFF8000},
    {'year': '2007', 'driver': 'Kimi Räikkönen', 'team': 'Ferrari', 'flag': '🇫🇮', 'color': 0xFFE8002D},
    {'year': '2006', 'driver': 'Fernando Alonso', 'team': 'Renault', 'flag': '🇪🇸', 'color': 0xFF0093CC},
    {'year': '2005', 'driver': 'Fernando Alonso', 'team': 'Renault', 'flag': '🇪🇸', 'color': 0xFF0093CC},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Campeones', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _champions.length,
                itemBuilder: (_, i) {
                  final c = _champions[i];
                  final isFirst = i == 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isFirst ? const Color(0xFF1A1000) : const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFirst ? const Color(0xFFE8A000).withOpacity(0.4) : Colors.white.withOpacity(0.06),
                        width: isFirst ? 1 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          alignment: Alignment.center,
                          child: Text(c['year'] as String, style: TextStyle(
                            color: isFirst ? const Color(0xFFE8A000) : Colors.white30,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          )),
                        ),
                        Container(width: 3, height: 32, decoration: BoxDecoration(
                          color: Color(c['color'] as int),
                          borderRadius: BorderRadius.circular(2),
                        )),
                        const SizedBox(width: 12),
                        Text(c['flag'] as String, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c['driver'] as String, style: TextStyle(
                              color: isFirst ? Colors.white : Colors.white70,
                              fontWeight: isFirst ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            )),
                            Text(c['team'] as String, style: const TextStyle(color: Colors.white30, fontSize: 11)),
                          ],
                        )),
                        if (isFirst)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFE8A000).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                            child: const Text('🏆', style: TextStyle(fontSize: 14)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
