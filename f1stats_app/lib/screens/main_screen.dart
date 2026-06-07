import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'standings_screen.dart';
import 'schedule_screen.dart';
import 'compare_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    StandingsScreen(),
    ScheduleScreen(),
    CompareScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: const Color(0xFF0F0F0F),
          selectedItemColor: const Color(0xFFE10600),
          unselectedItemColor: Colors.white30,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_numbered_outlined), activeIcon: Icon(Icons.format_list_numbered), label: 'Clasificación'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Calendario'),
            BottomNavigationBarItem(
              icon: Icon(Icons.compare_arrows_outlined), activeIcon: Icon(Icons.compare_arrows), label: 'Comparar'),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined), activeIcon: Icon(Icons.emoji_events), label: 'Historia'),
          ],
        ),
      ),
    );
  }
}
