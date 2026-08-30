import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../project/models/project.dart';
import '../../project/models/fix_record.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class FixHistoryScreen extends StatelessWidget {
  final Project project;

  const FixHistoryScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final history = project.fixHistory.isNotEmpty ? project.fixHistory : _generateMockHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fix History'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: history.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionTitle(
                  title: 'Autonomous Fix History',
                  subtitle: 'Audit trail of AI-generated surgical fixes and validations.',
                );
              }
              return _FixRecordCard(record: history[index - 1]);
            },
          ),
        ),
      ),
    );
  }

  List<FixRecord> _generateMockHistory() {
    final now = DateTime.now();
    return [
      FixRecord(
        id: 'f1',
        issue: 'Login button interaction failure',
        rootCause: 'isLoading state not reset after error.',
        modifiedFiles: ['lib/features/auth/viewmodels/auth_viewmodel.dart'],
        fixSummary: 'Added finally block to reset isLoading state.',
        buildResult: 'SUCCESS',
        testResult: 'PASSED',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      FixRecord(
        id: 'f2',
        issue: 'Overflow on mobile discovery screen',
        rootCause: 'Hardcoded padding in DiscoveryChatScreen.',
        modifiedFiles: ['lib/features/discovery/screens/discovery_chat_screen.dart'],
        fixSummary: 'Replaced fixed padding with AppConstants.spacingMd.',
        buildResult: 'SUCCESS',
        testResult: 'N/A (Visual Fix)',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }
}

class _FixRecordCard extends StatelessWidget {
  final FixRecord record;
  const _FixRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, HH:mm').format(record.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          title: Text(record.issue, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(timeStr, style: Theme.of(context).textTheme.labelSmall),
          trailing: const Icon(Icons.verified, color: Colors.green, size: 20),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(context, 'Root Cause', record.rootCause),
                  const SizedBox(height: 12),
                  _buildSection(context, 'Fix Summary', record.fixSummary),
                  const SizedBox(height: 12),
                  const Text('Files Modified:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  ...record.modifiedFiles.map((f) => Text('• $f', style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildOutcome('Build', record.buildResult, Colors.green),
                      _buildOutcome('Test', record.testResult, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(content, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildOutcome(String label, String value, Color color) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
