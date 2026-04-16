import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morzelingo/pages/duels/view/duels_flow_page.dart';
import 'package:morzelingo/pages/education/presentation/pages/education_page.dart';
import 'package:morzelingo/pages/practice/view/letters_page.dart';
import 'package:morzelingo/pages/profile/view/profile_page.dart';
import 'package:morzelingo/settings_context.dart';

import '../ui/app_ui.dart';
import 'freemode/view/freemode_flow_page.dart';

class HomeTabsPage extends StatefulWidget {
  const HomeTabsPage({super.key});

  @override
  State<HomeTabsPage> createState() => _HomeTabsPageState();
}

class _HomeTabsPageState extends State<HomeTabsPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    EducationPage(),
    FreemodeFlowPage(),
    DuelsFlowPage(),
    LettersPage(),
    ProfilePage(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school_rounded),
      label: 'Обучение',
    ),
    NavigationDestination(
      icon: Icon(Icons.keyboard_outlined),
      selectedIcon: Icon(Icons.keyboard_rounded),
      label: 'Свободный',
    ),
    NavigationDestination(
      icon: Icon(Icons.bolt_outlined),
      selectedIcon: Icon(Icons.bolt_rounded),
      label: 'Дуэли',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'Буквы',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Профиль',
    ),
  ];

  Future<void> _hintsDialog() async {
    final bool isEnable = await SettingsService.getHints();
    if (isEnable) {
      Timer(
        Duration(milliseconds: 500),
          () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return AppConfirmationDialog(
                  title: 'Посмотреть советы?',
                  message: 'Сейчас вы можете посмотреть советы, которые помогут вам в обучении морзе, их всегда можно посмотреть в профиле, показ этого окна при входе в приложение можно настроить',
                  confirmLabel: 'Да, Посмотреть',
                  cancelLabel: 'Позже',
                  destructive: false,
                  onConfirm: () {
                    Navigator.pushNamed(context, "/hints");
                  },
                );
              },
            );
          }
      );
    }
  }

  @override
  void initState() {
    _hintsDialog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 72,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
                  selectedIndex: _currentIndex,
                  destinations: _destinations,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}