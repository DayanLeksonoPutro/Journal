import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/tool.dart';
import '../providers/journal_provider.dart';
import '../utils/app_localizations.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final categories = journalProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'reports')),
        actions: [
          IconButton(
            icon: iconoir.ShareAndroid(
                color: Theme.of(context).colorScheme.primary),
            onPressed: () => AppTool.shareApp(context),
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: Text('No data yet. Start journaling!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length + 1, // +1 for Global consistency
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return _buildGlobalHeatmap(context);
                }
                final category = categories[index];
                final successRate = journalProvider.getSuccessRate(category.id);
                return _buildCategoryReport(
                    context, category.name, successRate);
              },
            ),
    );
  }

  Widget _buildCategoryReport(
      BuildContext context, String name, double successRate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${successRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: successRate,
                      color: _getColor(successRate),
                      title: 'Success',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: 100 - successRate,
                      color: Colors.grey[200]!,
                      title: 'Other',
                      radius: 40,
                      titleStyle: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalHeatmap(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Consistency Heatmap',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 28, // Last 4 weeks
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity((index % 5) / 5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }
}
