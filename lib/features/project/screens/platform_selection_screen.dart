import 'package:flutter/material.dart';
import '../models/project.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class PlatformSelectionScreen extends StatefulWidget {
  final Project project;

  const PlatformSelectionScreen({super.key, required this.project});

  @override
  State<PlatformSelectionScreen> createState() => _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  late List<String> _selectedPlatforms;

  final List<Map<String, dynamic>> _platforms = [
    {'name': 'Android', 'icon': Icons.android, 'id': 'android'},
    {'name': 'iOS', 'icon': Icons.phone_iphone, 'id': 'ios'},
    {'name': 'Web', 'icon': Icons.language, 'id': 'web'},
    {'name': 'Windows', 'icon': Icons.desktop_windows, 'id': 'windows'},
    {'name': 'macOS', 'icon': Icons.laptop_mac, 'id': 'macos'},
    {'name': 'Linux', 'icon': Icons.terminal, 'id': 'linux'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlatforms = List.from(widget.project.platforms);
  }

  void _togglePlatform(String id) {
    setState(() {
      if (_selectedPlatforms.contains(id)) {
        _selectedPlatforms.remove(id);
      } else {
        _selectedPlatforms.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Platforms'),
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
                  'Where should your app live?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Select all platforms you want to support. Flutter allows you to target multiple platforms from a single codebase.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveLayout.isMobile(context) ? 2 : 3,
                      crossAxisSpacing: AppConstants.spacingMd,
                      mainAxisSpacing: AppConstants.spacingMd,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _platforms.length,
                    itemBuilder: (context, index) {
                      final platform = _platforms[index];
                      final isSelected = _selectedPlatforms.contains(platform['id']);

                      return KindleCard(
                        onTap: () => _togglePlatform(platform['id']),
                        padding: EdgeInsets.zero,
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    platform['icon'],
                                    size: 40,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: AppConstants.spacingSm),
                                  Text(
                                    platform['name'],
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(Icons.check_circle, size: 20, color: AppColors.primary),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                KindleButton(
                  text: 'Confirm Selection',
                  onPressed: _selectedPlatforms.isEmpty
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select at least one platform')),
                          )
                      : () {
                          final updatedProject = widget.project.copyWith(platforms: _selectedPlatforms);
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
