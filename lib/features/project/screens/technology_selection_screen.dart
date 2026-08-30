import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/technology.dart';
import '../models/recommendation.dart';
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
  TechRecommendation? _recommendation;

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
    _generateRecommendation();
  }

  void _generateRecommendation() {
    final platforms = widget.project.platforms;
    
    if (platforms.length > 1 || (platforms.contains('android') && platforms.contains('ios'))) {
      _recommendation = const TechRecommendation(
        techId: 'flutter',
        confidence: 0.95,
        reason: 'Flutter provides the highest ROI for multi-platform development with a single codebase and native performance.',
        tradeoffs: ['Larger initial binary size', 'Learning curve for Dart'],
        alternatives: ['React Native'],
      );
    } else if (platforms.contains('web') && platforms.length == 1) {
      _recommendation = const TechRecommendation(
        techId: 'web_stack',
        confidence: 0.90,
        reason: 'For web-only experiences, a modern web stack offers the best SEO, accessibility, and loading speeds.',
        tradeoffs: ['Limited access to native mobile APIs'],
        alternatives: ['Flutter Web'],
      );
    } else if (platforms.contains('android') && platforms.length == 1) {
      _recommendation = const TechRecommendation(
        techId: 'kotlin_native',
        confidence: 0.85,
        reason: 'Native Android tools provide the deepest integration with system APIs and best performance for platform-specific features.',
        tradeoffs: ['Android only'],
        alternatives: ['Flutter'],
      );
    } else if (platforms.contains('ios') && platforms.length == 1) {
      _recommendation = const TechRecommendation(
        techId: 'swift_native',
        confidence: 0.85,
        reason: 'Native iOS development ensures immediate access to all Apple-specific hardware features and design paradigms.',
        tradeoffs: ['iOS only'],
        alternatives: ['Flutter'],
      );
    }
    
    if (_selectedTechId == null && _recommendation != null) {
      _selectedTechId = _recommendation!.techId;
    }
  }

  bool _isCompatible(Technology tech) {
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
                  'Kindle AI has analyzed your requirements and suggests a perfect fit.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                if (_recommendation != null) ...[
                  _RecommendationSection(
                    recommendation: _recommendation!,
                    tech: _technologies.firstWhere((t) => t.id == _recommendation!.techId),
                    isSelected: _selectedTechId == _recommendation!.techId,
                    onSelect: () => setState(() => _selectedTechId = _recommendation!.techId),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  const Divider(),
                  const SizedBox(height: AppConstants.spacingMd),
                  const Text(
                    'Other Compatible Options',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                ],
                Expanded(
                  child: ListView.builder(
                    itemCount: _technologies.length,
                    itemBuilder: (context, index) {
                      final tech = _technologies[index];
                      if (_recommendation != null && tech.id == _recommendation!.techId) {
                        return const SizedBox.shrink();
                      }
                      
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
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle, color: AppColors.primary),
                                    if (!isCompatible)
                                      const Icon(Icons.block, color: Colors.grey, size: 16),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.spacingXs),
                                Text(
                                  tech.description,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                  text: 'Finalize Spark Stack',
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

class _RecommendationSection extends StatelessWidget {
  final TechRecommendation recommendation;
  final Technology tech;
  final bool isSelected;
  final VoidCallback onSelect;

  const _RecommendationSection({
    required this.recommendation,
    required this.tech,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return KindleCard(
      onTap: onSelect,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Kindle Suggestion',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                '${(recommendation.confidence * 100).toInt()}% Confidence',
                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Row(
            children: [
              Expanded(
                child: Text(
                  tech.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(recommendation.reason),
          const SizedBox(height: AppConstants.spacingMd),
          const Text('Trade-offs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ...recommendation.tradeoffs.map((t) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Text('• $t', style: const TextStyle(fontSize: 12)),
              )),
          const SizedBox(height: AppConstants.spacingMd),
          const Text('Alternatives:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(recommendation.alternatives.join(', '), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
