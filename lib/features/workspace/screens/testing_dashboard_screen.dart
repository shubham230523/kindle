import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../project/models/project.dart';
import '../../project/models/test_run.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class TestingDashboardScreen extends StatefulWidget {
  final Project project;

  const TestingDashboardScreen({super.key, required this.project});

  @override
  State<TestingDashboardScreen> createState() => _TestingDashboardScreenState();
}

class _TestingDashboardScreenState extends State<TestingDashboardScreen> {
  late List<TestRun> _testRuns;

  @override
  void initState() {
    super.initState();
    _testRuns = _generateMockTestRuns();
  }

  List<TestRun> _generateMockTestRuns() {
    final now = DateTime.now();
    return [
      TestRun(
        id: 'tr1',
        category: TestCategory.unit,
        status: TestStatus.passed,
        startedAt: now.subtract(const Duration(hours: 2)),
        completedAt: now.subtract(const Duration(hours: 1, minutes: 58)),
        totalCount: 42,
        passedCount: 42,
        failedCount: 0,
        skippedCount: 0,
        coverage: 0.88,
      ),
      TestRun(
        id: 'tr2',
        category: TestCategory.widget,
        status: TestStatus.failed,
        startedAt: now.subtract(const Duration(hours: 1)),
        completedAt: now.subtract(const Duration(minutes: 55)),
        totalCount: 15,
        passedCount: 13,
        failedCount: 2,
        skippedCount: 0,
        coverage: 0.75,
      ),
      TestRun(
        id: 'tr3',
        category: TestCategory.integration,
        status: TestStatus.passed,
        startedAt: now.subtract(const Duration(minutes: 30)),
        completedAt: now.subtract(const Duration(minutes: 10)),
        totalCount: 5,
        passedCount: 5,
        failedCount: 0,
        skippedCount: 0,
        coverage: 0.92,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing & QA'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
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
                  _OverviewSection(runs: _testRuns),
                  const SizedBox(height: AppConstants.spacingLg),
                  const SectionTitle(title: 'Recent Test Execution'),
                  ..._testRuns.map((run) => _TestRunCard(run: run)),
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

class _OverviewSection extends StatelessWidget {
  final List<TestRun> runs;
  const _OverviewSection({required this.runs});

  @override
  Widget build(BuildContext context) {
    int total = 0;
    int passed = 0;
    int failed = 0;
    double avgCoverage = 0.0;

    if (runs.isNotEmpty) {
      for (var run in runs) {
        total += run.totalCount;
        passed += run.passedCount;
        failed += run.failedCount;
        avgCoverage += run.coverage;
      }
      avgCoverage /= runs.length;
    }

    return KindleCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(context, 'Total', '$total', Colors.blue),
              _buildStat(context, 'Passed', '$passed', Colors.green),
              _buildStat(context, 'Failed', '$failed', Colors.red),
              _buildStat(context, 'Coverage', '${(avgCoverage * 100).toInt()}%', AppColors.primary),
            ],
          ),
          const Divider(height: AppConstants.spacingLg),
          KindleButton(
            text: 'Run All Tests',
            onPressed: () {},
            icon: Icons.play_arrow,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TestRunCard extends StatelessWidget {
  final TestRun run;
  const _TestRunCard({required this.run});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, HH:mm').format(run.startedAt);
    final durationStr = run.duration != null ? '${run.duration!.inMinutes}m ${run.duration!.inSeconds % 60}s' : '--';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: KindleCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: _StatusIcon(status: run.status),
          title: Text(
            '${_getCategoryName(run.category)} Tests',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('$timeStr • $durationStr'),
          trailing: Text(
            '${run.passedCount}/${run.totalCount}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: run.status == TestStatus.passed ? Colors.green : Colors.red,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow('Passed', '${run.passedCount}', Colors.green),
                  _buildDetailRow('Failed', '${run.failedCount}', Colors.red),
                  _buildDetailRow('Skipped', '${run.skippedCount}', Colors.grey),
                  _buildDetailRow('Coverage', '${(run.coverage * 100).toInt()}%', AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(TestCategory category) {
    switch (category) {
      case TestCategory.unit:
        return 'Unit';
      case TestCategory.widget:
        return 'Widget';
      case TestCategory.integration:
        return 'Integration';
    }
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final TestStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (status) {
      case TestStatus.passed:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case TestStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case TestStatus.running:
        icon = Icons.sync;
        color = Colors.blue;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }
    return Icon(icon, color: color);
  }
}
