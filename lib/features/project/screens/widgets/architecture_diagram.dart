import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_layout.dart';

class ArchitectureDiagram extends StatelessWidget {
  const ArchitectureDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _DiagramNode(title: 'Presentation', icon: Icons.phone_android, color: Colors.blue),
        _DiagramArrow(isVertical: true),
        _DiagramNode(title: 'Domain', icon: Icons.psychology, color: Colors.orange),
        _DiagramArrow(isVertical: true),
        _DiagramNode(title: 'Data', icon: Icons.storage, color: Colors.green),
        _DiagramArrow(isVertical: true),
        _DiagramNode(title: 'Backend / API', icon: Icons.cloud, color: Colors.purple),
        _DiagramArrow(isVertical: true),
        _DiagramNode(title: 'Database', icon: Icons.dns, color: Colors.teal),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _DiagramNode(title: 'Presentation', icon: Icons.phone_android, color: Colors.blue)),
            _DiagramArrow(isVertical: false),
            Expanded(child: _DiagramNode(title: 'Domain', icon: Icons.psychology, color: Colors.orange)),
            _DiagramArrow(isVertical: false),
            Expanded(child: _DiagramNode(title: 'Data', icon: Icons.storage, color: Colors.green)),
          ],
        ),
        const SizedBox(height: AppConstants.spacingXl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 100),
            _DiagramArrow(isVertical: true),
            const SizedBox(width: 100),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: _DiagramNode(title: 'Backend / API', icon: Icons.cloud, color: Colors.purple),
            ),
            _DiagramArrow(isVertical: false),
            SizedBox(
              width: 300,
              child: _DiagramNode(title: 'Database', icon: Icons.dns, color: Colors.teal),
            ),
          ],
        ),
      ],
    );
  }
}

class _DiagramNode extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _DiagramNode({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppConstants.spacingSm),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramArrow extends StatelessWidget {
  final bool isVertical;

  const _DiagramArrow({required this.isVertical});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isVertical ? 8.0 : 16.0),
      child: Icon(
        isVertical ? Icons.arrow_downward : Icons.arrow_forward,
        size: 16,
        color: Colors.grey.shade400,
      ),
    );
  }
}
