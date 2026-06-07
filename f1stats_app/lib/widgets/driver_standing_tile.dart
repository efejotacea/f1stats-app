import 'package:flutter/material.dart';
import '../models/models.dart';

class DriverStandingTile extends StatelessWidget {
  final DriverStanding standing;
  final bool showWins;

  const DriverStandingTile({
    super.key,
    required this.standing,
    this.showWins = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = standing.position == 1;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('${standing.position}', style: TextStyle(
              color: isFirst ? const Color(0xFFE10600) : Colors.white38,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            )),
          ),
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: standing.constructor.teamColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(standing.driver.fullName, style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                )),
                Text(standing.constructor.name, style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                )),
              ],
            ),
          ),
          if (showWins && standing.wins > 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text('${standing.wins}V', style: const TextStyle(color: Colors.white24, fontSize: 11)),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(standing.points, style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              )),
              const Text('PTS', style: TextStyle(color: Colors.white30, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
