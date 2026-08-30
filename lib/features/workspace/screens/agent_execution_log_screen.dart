import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../project/models/agent.dart';
import '../../project/models/agent_execution.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class AgentExecutionLogScreen extends StatefulWidget {
  final Agent agent;

  const AgentExecutionLogScreen({super.key, required this.agent});

  @override
  State<AgentExecutionLogScreen> createState() => _AgentExecutionLogScreenState();
}

class _AgentExecutionLogScreenState extends State<AgentExecutionLogScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ExecutionLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _generateMockLogs();
  }

  void _generateMockLogs() async {
    final now = DateTime.now();
    final mockEvents = [
      {'msg': '${widget.agent.name} started', 'details': 'Initializing agent environment and loading project context.'},
      {'msg': 'Analyzing selected technology: Flutter', 'details': 'Verifying compatibility with target platforms (Android, iOS).'},
      {'msg': 'Mapping requirements to architecture modules', 'details': 'Matching 5 functional requirements to the CLEAN architecture blueprint.'},
      {'msg': 'Created module structure', 'details': 'Defined folders: auth, chat, data, domain, presentation.'},
      {'msg': 'Generating dependency graph', 'details': 'Linking modules and identifying external package requirements.'},
      {'msg': 'Architecture generated successfully', 'details': 'Blueprint ready for developer agent execution.'},
    ];

    for (var i = 0; i < mockEvents.length; i++) {
      await Future.delayed(Duration(milliseconds: 500 + (i * 200)));
      if (!mounted) return;
      
      setState(() {
        _logs.add(ExecutionLog(
          timestamp: now.add(Duration(minutes: i)),
          message: mockEvents[i]['msg']!,
          details: mockEvents[i]['details'],
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.agent.name} Execution'),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Column(
            children: [
              _AgentHeader(agent: widget.agent),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return _LogItem(log: _logs[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgentHeader extends StatelessWidget {
  final Agent agent;
  const _AgentHeader({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Execution',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Text(
                  'Task: Generating Blueprint',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const CircularProgressIndicator(strokeWidth: 2),
        ],
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final ExecutionLog log;
  const _LogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(log.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: KindleCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          visualDensity: VisualDensity.compact,
          leading: Text(
            timeStr,
            style: const TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontSize: 12),
          ),
          title: Text(
            log.message,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          children: [
            if (log.details != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.details!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
