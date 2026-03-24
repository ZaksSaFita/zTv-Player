import 'package:flutter/material.dart';
import 'package:ztv_player/screens/livetv_screen/livetv_screen.dart';
import 'package:ztv_player/screens/movies_screen/movies_screen.dart';
import 'package:ztv_player/screens/series_screen/series_screen.dart';
import 'package:ztv_player/screens/settings_screen/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LiveTvScreen(),
    const MoviesScreen(),
    const SeriesScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = ['Live TV', 'Movies', 'Series', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Series'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
