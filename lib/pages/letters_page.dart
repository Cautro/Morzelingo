import 'package:flutter/material.dart';
import 'package:morzelingo/storage_context.dart';

class LettersPage extends StatefulWidget {
  const LettersPage({super.key});

  @override
  State<LettersPage> createState() => _LettersPageState();
}

class _LettersPageState extends State<LettersPage> {
  List letters = [
    { "letter": "A", "morse": "•—" }, { "letter": "B", "morse": "—•••" }, { "letter": "C", "morse": "—•—•" }, { "letter": "D", "morse": "—••" },
    { "letter": "E", "morse": "•" }, { "letter": "F", "morse": "••—•" }, { "letter": "G", "morse": "——•" }, { "letter": "H", "morse": "••••" },
    { "letter": "I", "morse": "••" }, { "letter": "J", "morse": "•———" }, { "letter": "K", "morse": "—•—" }, { "letter": "L", "morse": "•—••" },
    { "letter": "M", "morse": "——" }, { "letter": "N", "morse": "—•" }, { "letter": "O", "morse": "———" }, { "letter": "P", "morse": "•——•" },
    { "letter": "Q", "morse": "——•—" }, { "letter": "R", "morse": "•—•" }, { "letter": "S", "morse": "•••" }, { "letter": "T", "morse": "—" },
    { "letter": "U", "morse": "••—" }, { "letter": "V", "morse": "•••—" }, { "letter": "W", "morse": "•——" }, { "letter": "X", "morse": "—••—" },
    { "letter": "Y", "morse": "—•——" }, { "letter": "Z", "morse": "——••" }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(24),
          child: GridView.count(
              crossAxisCount: 4,
              children: letters.map((item) {
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
