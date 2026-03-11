import 'package:flutter/material.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/storage_context.dart';

class LettersPage extends StatefulWidget {
  const LettersPage({super.key});

  @override
  State<LettersPage> createState() => _LettersPageState();
}

class _LettersPageState extends State<LettersPage> {
  List lettersEN = [
    { "letter": "A", "morse": "•—" }, { "letter": "B", "morse": "—•••" }, { "letter": "C", "morse": "—•—•" }, { "letter": "D", "morse": "—••" },
    { "letter": "E", "morse": "•" }, { "letter": "F", "morse": "••—•" }, { "letter": "G", "morse": "——•" }, { "letter": "H", "morse": "••••" },
    { "letter": "I", "morse": "••" }, { "letter": "J", "morse": "•———" }, { "letter": "K", "morse": "—•—" }, { "letter": "L", "morse": "•—••" },
    { "letter": "M", "morse": "——" }, { "letter": "N", "morse": "—•" }, { "letter": "O", "morse": "———" }, { "letter": "P", "morse": "•——•" },
    { "letter": "Q", "morse": "——•—" }, { "letter": "R", "morse": "•—•" }, { "letter": "S", "morse": "•••" }, { "letter": "T", "morse": "—" },
    { "letter": "U", "morse": "••—" }, { "letter": "V", "morse": "•••—" }, { "letter": "W", "morse": "•——" }, { "letter": "X", "morse": "—••—" },
    { "letter": "Y", "morse": "—•——" }, { "letter": "Z", "morse": "——••" }
  ];

  List<Map<String, String>> lettersRU = [
    { "letter": "А", "morse": "•—" }, { "letter": "Б", "morse": "—•••" }, { "letter": "В", "morse": "•——" }, { "letter": "Г", "morse": "——•" },
    { "letter": "Д", "morse": "—••" }, { "letter": "Е", "morse": "•" }, { "letter": "Ж", "morse": "•••—" }, { "letter": "З", "morse": "——••" },
    { "letter": "И", "morse": "••" }, { "letter": "Й", "morse": "•———" }, { "letter": "К", "morse": "—•—" }, { "letter": "Л", "morse": "•—••" },
    { "letter": "М", "morse": "——" }, { "letter": "Н", "morse": "—•" }, { "letter": "О", "morse": "———" }, { "letter": "П", "morse": "•——•" },
    { "letter": "Р", "morse": "•—•" }, { "letter": "С", "morse": "•••" }, { "letter": "Т", "morse": "—" }, { "letter": "У", "morse": "••—" },
    { "letter": "Ф", "morse": "••—•" }, { "letter": "Х", "morse": "••••" }, { "letter": "Ц", "morse": "—•—•" }, { "letter": "Ч", "morse": "———•" },
    { "letter": "Ш", "morse": "———•" }, { "letter": "Щ", "morse": "——•—" }, { "letter": "Ъ", "morse": "——•——" }, { "letter": "Ы", "morse": "—•——" },
    { "letter": "Ь", "morse": "—••—" }, { "letter": "Э", "morse": "••—••" }, { "letter": "Ю", "morse": "••——" }, { "letter": "Я", "morse": "•—•—" }
  ];

  List<dynamic> Letters = [];

  @override
  void initState() {
    super.initState();
    getLang();
  }

  void getLang() async {
    String? lang = await SettingsService.getLang();
    print(lang);
    setState(() {
      Letters = lang == "en" ? lettersEN : lettersRU;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: GridView.count(
              crossAxisCount: 4,
              children: Letters.map((item) {
                return SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      StorageService.setItem("letter", item["letter"]);
                      Navigator.pushNamed(context, "/practiceletter");
                    },
                    child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: Text(item["letter"], style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 25),),),
                            Center(child: Text(item["morse"], style: Theme.of(context).textTheme.bodyMedium,),),
                          ],
                        )
                    ),
                  )
                );
              }).toList(),
          )
        ),
      ),
    );
  }
}
