import 'package:flutter/material.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _wpmSlider(),
              _themeController()
            ],
          ),
        ),
      ),
    );
  }
}

class _wpmSlider extends StatefulWidget {
  const _wpmSlider({super.key});

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

  @override

  Future<void> getSettings() async {
    final saved = await SettingsService.getWpm();

    setState(() {
      wpm = saved.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text("${wpm} WPM - кол-во слов в минуту "),
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
        ),

      ),
    );
  }
}

class _themeController extends StatefulWidget {
  const _themeController({super.key});

  @override
  State<_themeController> createState() => _themeControllerState();
}

class _themeControllerState extends State<_themeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: SwitchListTile(
          title: Text( themeController.themeMode == ThemeMode.dark ? "Тёмная тема" : "Светлая тема"),
          value: themeController.themeMode == ThemeMode.dark,
          onChanged: (value) {
            themeController.toggleTheme();
          },
        ),
      ),
    );
  }
}
