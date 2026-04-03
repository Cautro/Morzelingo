import 'package:flutter/material.dart';

import '../ui/app_ui.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      child: AppLoadingIndicator(),
    );
  }
}
