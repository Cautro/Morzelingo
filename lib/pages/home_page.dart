import 'package:flutter/material.dart';
import 'package:morzelingo/pages/duels/view/duels_flow_page.dart';
import 'package:morzelingo/pages/education/view/education_page.dart';
import 'package:morzelingo/pages/practice/view/letters_page.dart';
import 'package:morzelingo/pages/profile/view/profile_page.dart';
import '../app_theme.dart';
import 'freemode/view/freemode_flow_page.dart';

class HomeTabsPage extends StatefulWidget {
  const HomeTabsPage({super.key});

  @override
  State<HomeTabsPage> createState() => _HomeTabsPageState();
}

class _HomeTabsPageState extends State<HomeTabsPage> {
  int _currentIndex = 0;

  // Список экранов для вкладок
  final List<Widget> _screens = [
    EducationPage(),
    FreemodeFlowPage(),
    DuelsFlowPage(),
    LettersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 50,
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
              Icons.school,
              size: 30,
              color: _currentIndex == 0
                  ? AppTheme.primary
                  : Colors.grey,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.keyboard,
              size: 30,
              color: _currentIndex == 1
                  ? AppTheme.primary
                  : Colors.grey,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.assistant_photo,
              size: 30,
              color: _currentIndex == 2
                  ? AppTheme.primary
                  : Colors.grey,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.font_download,
              size: 30,
              color: _currentIndex == 3
                  ? AppTheme.primary
                  : Colors.grey,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person,
              size: 30,
              color: _currentIndex == 4
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