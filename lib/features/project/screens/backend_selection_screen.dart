import 'package:flutter/material.dart';
import '../models/project.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class BackendSelectionScreen extends StatefulWidget {
  final Project project;

  const BackendSelectionScreen({super.key, required this.project});

  @override
  State<BackendSelectionScreen> createState() => _BackendSelectionScreenState();
}

class _BackendSelectionScreenState extends State<BackendSelectionScreen> {
  String? _selectedBackend;
  String? _selectedDatabase;

  final List<String> _backends = ['None', 'Firebase', 'Supabase', 'Node.js', 'SpringBoot', 'Custom'];
  final List<String> _databases = ['None', 'SQLite', 'PostgreSQL', 'MongoDB', 'Firebase Firestore'];

  @override
  void initState() {
    super.initState();
    _selectedBackend = widget.project.selectedBackend;
    _selectedDatabase = widget.project.selectedDatabase;
    _applyRecommendation();
  }

  void _applyRecommendation() {
    if (_selectedBackend == null && _selectedDatabase == null) {
      if (widget.project.selectedTechnology == 'flutter') {
        _selectedBackend = 'Firebase';
        _selectedDatabase = 'Firebase Firestore';
      } else if (widget.project.selectedTechnology == 'web_stack') {
        _selectedBackend = 'Supabase';
        _selectedDatabase = 'PostgreSQL';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend & Database'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRecommendationCard(),
                const SizedBox(height: AppConstants.spacingLg),
                const SectionTitle(title: 'Choose Backend'),
                Wrap(
                  spacing: AppConstants.spacingSm,
                  children: _backends.map((b) => ChoiceChip(
                    label: Text(b),
                    selected: _selectedBackend == b,
                    onSelected: (val) => setState(() => _selectedBackend = val ? b : null),
                  )).toList(),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                const SectionTitle(title: 'Choose Database'),
                Wrap(
                  spacing: AppConstants.spacingSm,
                  children: _databases.map((d) => ChoiceChip(
                    label: Text(d),
                    selected: _selectedDatabase == d,
                    onSelected: (val) => setState(() => _selectedDatabase = val ? d : null),
                  )).toList(),
                ),
                const SizedBox(height: AppConstants.spacingXl),
                KindleButton(
                  text: 'Finalize Infrastructure',
                  onPressed: () {
                    final updated = widget.project.copyWith(
                      selectedBackend: _selectedBackend,
                      selectedDatabase: _selectedDatabase,
                    );
                    Navigator.pop(context, updated);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    String suggestion = "";
    String reasoning = "";
    String alternatives = "";

    if (widget.project.selectedTechnology == 'flutter') {
      suggestion = "Firebase + Firestore";
      reasoning = "Best integration with Flutter, handles authentication, hosting, and real-time data seamlessly.";
      alternatives = "Supabase + PostgreSQL";
    } else {
      suggestion = "Supabase + PostgreSQL";
      reasoning = "Provides a powerful relational database with built-in auth and real-time capabilities, ideal for complex data models.";
      alternatives = "Node.js + MongoDB";
    }

    return KindleCard(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                "Kindle Recommendation",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            suggestion,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(reasoning, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            "Alternatives: $alternatives",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
