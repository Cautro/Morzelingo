import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morzelingo/pages/hints/view/hint_details_page.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/ui/app_ui.dart';

class HintsPage extends StatefulWidget {
  const HintsPage({super.key});

  @override
  State<HintsPage> createState() => _HintsPageState();
}

class _HintsPageState extends State<HintsPage> {
  bool isLoading = true;
  List<dynamic> data = [];

  Future<List<dynamic>> getHintsData() async {
    final String response = await rootBundle.loadString('assets/data/hints.json');
    final List<dynamic> data = jsonDecode(response);
    return data;
  }

  @override
  void initState() {
    super.initState();
    _loadHints();
  }

  Future<void> _loadHints() async {
    final hints = await getHintsData();

    if (!mounted) return;

    setState(() {
      data = hints;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingPage()
        : AppPageScaffold(
      appBar: AppBar(
        title: const Text("Советы"),
      ),
      padding: AppSpacing.pageDense,
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index] as Map<String, dynamic>;
          return Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.xs),
            child:  AppListCard(
              title: item["title"] ?? "",
              subtitle: item["subtitle"] ?? "",
              leading: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadii.md,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HintDetailsPage(item: item))
                );
              },
            ),
          );

        },
      ),
    );
  }
}