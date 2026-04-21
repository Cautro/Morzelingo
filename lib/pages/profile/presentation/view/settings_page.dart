import 'package:flutter/material.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/theme_controller.dart';

import '../../../../ui/app_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
      ),
      padding: AppSpacing.pageDense,
      child: ListView(
        children: const [
          _wpmSlider(),
          SizedBox(height: AppSpacing.md),
          _themeController(),
          SizedBox(height: AppSpacing.md),
          _hintsController(),
          SizedBox(height: AppSpacing.md),
          _langController(),
        ],
      ),
    );
  }
}

class _wpmSlider extends StatefulWidget {
  const _wpmSlider();

  @override
  State<_wpmSlider> createState() => _wpmSliderState();
}

class _wpmSliderState extends State<_wpmSlider> {
  double wpm = 5;

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  Future<void> getSettings() async {
    final saved = await SettingsService.getWpm();

    setState(() {
      wpm = saved.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Скорость воспроизведения',
            subtitle: 'Измените WPM, чтобы подстроить обучение под своё понимание морзе.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '$wpm WPM',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: wpm,
            min: 5,
            max: 20,
            divisions: 15,
            onChanged: (value) {
              setState(() {
                wpm = value;
              });
              SettingsService.setWpm(value.toInt());
            },
          ),
        ],
      ),
    );
  }
}

class _themeController extends StatefulWidget {
  const _themeController();

  @override
  State<_themeController> createState() => _themeControllerState();
}

class _themeControllerState extends State<_themeController> {
  bool isDark = themeController.themeMode == ThemeMode.dark;
  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SwitchListTile(
        title: Text(
          isDark ? "Тёмная тема" : "Светлая тема",
        ),
        subtitle: const Text('Измените тему приложения под себя.'),
        value: themeController.themeMode == ThemeMode.dark,
        onChanged: (value) {
          themeController.toggleTheme();
          setState(() {
            isDark = themeController.themeMode == ThemeMode.dark;
          });
        },
      ),
    );
  }
}

class _hintsController extends StatefulWidget {
  const _hintsController();

  @override
  State<_hintsController> createState() => _hintsControllerState();
}

class _hintsControllerState extends State<_hintsController> {
  late bool value = false;

  Future<void> _loadHints() async {
    final saved = await SettingsService.getHints();
    if (!mounted) return;
    setState(() {
      value = saved;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHints();
  }

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SwitchListTile(
        value: value,
        title: const Text("Подсказки при входе"),
        subtitle: const Text('Настроить показ окна подсказок при входе'),
        onChanged: (value) async {
          await SettingsService.setHints(value);
          _loadHints();
        },
      ),
    );
  }
}


class _langController extends StatefulWidget {
  const _langController();

  @override
  State<_langController> createState() => _langControllerState();
}

class _langControllerState extends State<_langController> {
  String selected = "";

  @override
  void initState() {
    super.initState();
    getLang();
  }

  Future<void> getLang() async {
    String? lang = await SettingsService.getLang();
    setState(() {
      selected = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Язык обучения',
            subtitle: 'Измените язык обучения на предпочтительный для вас.',
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: "en",
                  label: Text("Английский"),
                ),
                ButtonSegment<String>(
                  value: "ru",
                  label: Text("Русский"),
                ),
              ],
              selected: {selected},
              onSelectionChanged: (Set<String> newselect) {
                setState(() {
                  selected = newselect.first;
                });
                SettingsService.setLang(selected);
              },
            ),
          ),
        ],
      ),
    );
  }
}
