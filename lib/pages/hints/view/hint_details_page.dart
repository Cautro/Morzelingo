import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morzelingo/ui/app_ui.dart';

class HintDetailsPage extends StatelessWidget {
  final Map<String, dynamic> item;
  const HintDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      appBar: AppBar(title: Text("Совет"),),
      padding: AppSpacing.pageDense,
      child: Column(
        children: [
          AppSectionHeader(
            title: item["title"],
          ),
          const SizedBox(height: AppSpacing.lg,),
          AppSurfaceCard(
            child: Text(item["content"], style: Theme.of(context).textTheme.bodyLarge,),
          ),
        ],
      ),
    );
  }
}
