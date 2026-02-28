import 'package:flutter/material.dart';

class MorseKey extends StatefulWidget {
  const MorseKey({super.key});

  @override
  State<MorseKey> createState() => _MorseKeyState();
}

class _MorseKeyState extends State<MorseKey> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                child: ElevatedButton
                  (
                    onPressed: () {
                      print("short");
                    },
                    onLongPress: () {
                      print("long");
                    },
                    child: Text("dfdf")
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
