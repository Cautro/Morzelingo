import 'package:flutter/material.dart';
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';

class DuelsWaitingPage extends StatelessWidget {
  final Function onLeave;
  const DuelsWaitingPage({super.key, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text("Ожидание"),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                child: Text("Отменить"),
                onPressed: () {
                  onLeave;
                },
              ),
            ),
          ],
        )
      ),
    );
  }
}
