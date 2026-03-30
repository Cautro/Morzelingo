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
              _themeController(),
              _langController()
            ],
          ),
        ),
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
              Text("$wpm WPM - кол-во слов в минуту "),
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
  const _themeController();

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

class _langController extends StatefulWidget {
  const _langController();

  @override
  State<_langController> createState() => _langControllerState();
}

class _langControllerState extends State<_langController> {
  String selected = "";

  @override
  Future<void> getLang() async {
    String? lang = await SettingsService.getLang();
    setState(() {
      selected = lang;
    });
    print(selected);
  }

  @override
  void initState()  {
    super.initState();
    getLang();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text("Язык обучения", style: Theme.of(context).textTheme.bodyLarge,),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton(
                segments: [
                  ButtonSegment(
                      value: "en",
                      label: Text("Английский")
                  ),
                  ButtonSegment(
                      value: "ru",
                      label: Text("Русский", style: TextStyle(
                      ),)
                  ),
                ],
                style: ButtonStyle(
                    side: WidgetStatePropertyAll(BorderSide.none)
                ),
                selected: {selected},
                onSelectionChanged: (Set<String> newselect) {
                  setState(() {
                    selected = newselect.first;
                  });
                  SettingsService.setLang(selected);
                },
              ),
            )
          ),
        ],
      )
    );
  }
}
