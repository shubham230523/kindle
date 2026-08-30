import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/technology.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class TechnologySelectionScreen extends StatefulWidget {
  final Project project;

  const TechnologySelectionScreen({super.key, required this.project});

  @override
  State<TechnologySelectionScreen> createState() => _TechnologySelectionScreenState();
}

class _TechnologySelectionScreenState extends State<TechnologySelectionScreen> {
  String? _selectedTechId;

  final List<Technology> _technologies = const [
    Technology(
      id: 'flutter',
      name: 'Flutter',
      description: 'Google\'s UI toolkit for building beautiful, natively compiled applications.',
      bestUseCase: 'Multi-platform apps with high-fidelity UI and fast development.',
      supportedPlatforms: ['android', 'ios', 'web', 'windows', 'macos', 'linux'],
    ),
    Technology(
      id: 'react_native',
      name: 'React Native',
      description: 'A popular framework by Meta for building mobile apps using React.',
      bestUseCase: 'Mobile-first applications with a large developer ecosystem.',
      supportedPlatforms: ['android', 'ios'],
    ),
    Technology(
      id: 'kotlin_native',
      name: 'Kotlin Native (Android)',
      description: 'Official Android development using Kotlin and Jetpack Compose.',
      bestUseCase: 'High-performance Android-only applications with deep system integration.',
      supportedPlatforms: ['android'],
    ),
    Technology(
      id: 'swift_native',
      name: 'Swift Native (iOS)',
      description: 'Official iOS development using Swift and SwiftUI.',
      bestUseCase: 'High-performance iOS-only applications with the latest Apple features.',
      supportedPlatforms: ['ios'],
    ),
    Technology(
      id: 'web_stack',
      name: 'Web Stack (React/Vue/Next)',
      description: 'Modern web development using standard web technologies.',
      bestUseCase: 'Progressive Web Apps and high-scale web platforms.',
      supportedPlatforms: ['web'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTechId = widget.project.selectedTechnology;
  }

  bool _isCompatible(Technology tech) {
    // A tech is compatible if it supports ALL platforms selected by the user
    return widget.project.platforms.every((p) => tech.supportedPlatforms.contains(p));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technology Stack'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose your Spark Stack',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Based on your platform selection (${widget.project.platforms.join(", ")}), we recommend the following stacks.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(
                  child: ListView.builder(
                    itemCount: _technologies.length,
                    itemBuilder: (context, index) {
                      final tech = _technologies[index];
                      final isCompatible = _isCompatible(tech);
                      final isSelected = _selectedTechId == tech.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                        child: Opacity(
                          opacity: isCompatible ? 1.0 : 0.5,
                          child: KindleCard(
                            onTap: isCompatible ? () => setState(() => _selectedTechId = tech.id) : null,
                            padding: const EdgeInsets.all(AppConstants.spacingMd),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tech.name,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle, color: AppColors.primary),
                                    if (!isCompatible)
                                      const Tooltip(
                                        message: 'Not compatible with selected platforms',
                                        child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.spacingSm),
                                Text(
                                  tech.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppConstants.spacingMd),
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primary),
                                    const SizedBox(width: AppConstants.spacingXs),
                                    Expanded(
                                      child: Text(
                                        'Best for: ${tech.bestUseCase}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.spacingSm),
                                Wrap(
                                  spacing: 4,
                                  children: tech.supportedPlatforms.map((p) => Chip(
                                    label: Text(p, style: const TextStyle(fontSize: 10)),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                KindleButton(
                  text: 'Finalize Spark',
                  onPressed: _selectedTechId == null
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a technology stack')),
                          )
                      : () {
                          final updatedProject = widget.project.copyWith(selectedTechnology: _selectedTechId);
                          Navigator.pop(context, updatedProject);
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
