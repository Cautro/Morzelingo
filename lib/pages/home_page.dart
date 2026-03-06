import 'package:flutter/material.dart';
import 'package:morzelingo/pages/education_page.dart';
import 'package:morzelingo/pages/freemode_text_page.dart';
import 'package:morzelingo/pages/letters_page.dart';
import 'package:morzelingo/pages/practice_letters_page.dart';
import 'package:morzelingo/pages/login_page.dart';
import 'package:morzelingo/pages/profile_page.dart';
import '../app_theme.dart';
import 'freemode_page.dart';

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
    EducationPage(),
    LettersPage(),
    ProfilePage(), // Вкладка 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // показываем выбранный экран
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.keyboard,
              size: 30,
              color: _currentIndex == 0
                  ? AppTheme.primary
                  : Colors.grey,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.school,
              size: 30,
              color: _currentIndex == 1
                  ? AppTheme.primary
                  : Colors.grey,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.font_download,
              size: 30,
              color: _currentIndex == 2
                  ? AppTheme.primary
                  : Colors.grey,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person,
              size: 30,
              color: _currentIndex == 3
                  ? AppTheme.primary
                  : Colors.grey,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}