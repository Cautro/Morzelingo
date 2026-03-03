import 'package:flutter/material.dart';
import 'package:morzelingo/pages/freemode_page.dart';
import 'package:morzelingo/pages/login_page.dart';
import 'package:morzelingo/pages/profile_page.dart';

class HomeTabsPage extends StatefulWidget {
  const HomeTabsPage({super.key});

  @override
  State<HomeTabsPage> createState() => _HomeTabsPageState();
}

class _HomeTabsPageState extends State<HomeTabsPage> {
  int _currentIndex = 0;

  // Список экранов для вкладок
  final List<Widget> _screens = [
    FreemodePage(), // Вкладка 0
    ProfilePage(), // Вкладка 1
    Center(child: Text("Настройки")), // Вкладка 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // показываем выбранный экран
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // переключаем экран
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.keyboard),
            label: "Вопросы",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Профиль",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Настройки",
          ),
        ],
      ),
    );
  }
}