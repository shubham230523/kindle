import 'package:flutter/material.dart';
import '../../project/models/test_run.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class TestDetailScreen extends StatelessWidget {
  final TestCase testCase;

  const TestDetailScreen({super.key, required this.testCase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Details'),
        actions: [
          _StatusBadge(status: testCase.status),
          const SizedBox(width: AppConstants.spacingMd),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderSection(testCase: testCase),
                  const SizedBox(height: AppConstants.spacingLg),
                  if (testCase.status == TestStatus.failed && testCase.errorMessage != null) ...[
                    const SectionTitle(title: 'Failure Reason'),
                    KindleCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testCase.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                          if (testCase.stackTrace != null) ...[
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              testCase.stackTrace!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                  if (testCase.relatedFiles.isNotEmpty) ...[
                    const SectionTitle(title: 'Related Source Files'),
                    KindleCard(
                      child: Column(
                        children: testCase.relatedFiles.map((file) => ListTile(
                          leading: const Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
                          title: Text(file, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                  const SectionTitle(title: 'Execution Logs'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: testCase.logs.isEmpty 
                        ? [const Text('No logs available for this test.', style: TextStyle(color: Colors.grey, fontFamily: 'monospace', fontSize: 12))]
                        : testCase.logs.map((log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
                            ),
                          )).toList(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final TestCase testCase;
  const _HeaderSection({required this.testCase});

  @override
  Widget build(BuildContext context) {
    final durationStr = testCase.duration != null ? '${testCase.duration!.inMilliseconds}ms' : '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          testCase.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Suite: ${testCase.suite}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              durationStr,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TestStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TestStatus.passed: color = Colors.green; break;
      case TestStatus.failed: color = Colors.red; break;
      case TestStatus.skipped: color = Colors.grey; break;
      case TestStatus.running: color = Colors.blue; break;
      case TestStatus.queued: color = Colors.orange; break;
    }

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}
