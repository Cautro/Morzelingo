import 'package:flutter/material.dart';

class DuelsWaitingPage extends StatelessWidget {
  const DuelsWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Text("Ожидание"),
          ),
        ),
      ),
    );
  }
}
