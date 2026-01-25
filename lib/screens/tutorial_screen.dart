import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../utils/app_localizations.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'tutorial_guide')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTutorialStep(
            context: context,
            icon: iconoir.ViewGrid(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: '1. Create Templates',
            description:
                'Go to the Journal tab and click "Add Template". You can define your own fields like text, numbers, checkboxes, or even image pairs.',
          ),
          _buildTutorialStep(
            context: context,
            icon: iconoir.PlusCircle(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: '2. Log Your Activities',
            description:
                'Once a template is created, click on it to start adding entries. Use the "Success Indicator" field to track your ROI or habit completion.',
          ),
          _buildTutorialStep(
            context: context,
            icon: iconoir.GraphUp(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: '3. Analyze Reports',
            description:
                'Visit the Report tab to see your success rate statistics and consistency heatmap. Make sure App Mode is set to "Advanced" in Settings.',
          ),
          _buildTutorialStep(
            context: context,
            icon: iconoir.CheckSquare(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: '4. Quick Notes & Todos',
            description:
                'Use the Task tab for simple checklists or brainstorming. You can long-press a note to convert it into a formal journal entry later.',
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                iconoir.ShieldCheck(
                    color: Theme.of(context).colorScheme.primary,
                    width: 32,
                    height: 32),
                const SizedBox(height: 12),
                Text(
                  'Privacy First',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All your data is stored locally on your device. We don\'t track or upload your personal information.',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                      height: 1.5,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
