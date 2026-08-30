import 'package:flutter/material.dart';
import 'agent_execution_log_screen.dart';
import '../viewmodels/workspace_viewmodel.dart';
import '../../project/models/agent.dart';
import '../../project/models/agent_execution.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class AgentActivityScreen extends StatefulWidget {
  final WorkspaceViewModel viewModel;
  const AgentActivityScreen({super.key, required this.viewModel});

  @override
  State<AgentActivityScreen> createState() => _AgentActivityScreenState();
}

class _AgentActivityScreenState extends State<AgentActivityScreen> {
  List<_AgentStatusData> _getAgentData() {
    return widget.viewModel.agents.map((agent) {
      final isActive = widget.viewModel.activeExecution?.agentId == agent.id;
      final execution = isActive ? widget.viewModel.activeExecution : null;

      return _AgentStatusData(
        agent: agent,
        currentTask: execution != null ? 'Executing Task' : (isActive ? 'Initializing' : 'Idle'),
        status: execution?.status ?? ExecutionStatus.idle,
        progress: execution?.status == ExecutionStatus.completed ? 1.0 : (isActive ? 0.5 : 0.0),
        activity: execution?.logs.last.message ?? 'Waiting for instructions...',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final agents = _getAgentData();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindle Agents'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: agents.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionTitle(
                  title: 'Autonomous Activity',
                  subtitle: 'Real-time status of specialized AI agents.',
                );
              }
              return _AgentActivityCard(
                data: agents[index - 1],
                activeExecution: widget.viewModel.activeExecution?.agentId == agents[index - 1].agent.id
                    ? widget.viewModel.activeExecution
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AgentStatusData {
  final Agent agent;
  final String currentTask;
  final ExecutionStatus status;
  final double progress;
  final String activity;

  _AgentStatusData({
    required this.agent,
    required this.currentTask,
    required this.status,
    required this.progress,
    required this.activity,
  });
}

class _AgentActivityCard extends StatelessWidget {
  final _AgentStatusData data;
  final AgentExecution? activeExecution;

  const _AgentActivityCard({required this.data, this.activeExecution});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgentExecutionLogScreen(
                agent: data.agent,
                execution: activeExecution,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AgentIcon(type: data.agent.type, status: data.status),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.agent.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        data.agent.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _ExecutionStatusBadge(status: data.status),
              ],
            ),
            const Divider(height: AppConstants.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Task', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text(data.currentTask, style: const TextStyle(fontSize: 13)),
                  ],
                ),
                if (data.progress > 0 && data.progress < 1.0)
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${(data.progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: data.progress,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.terminal, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.activity,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentIcon extends StatelessWidget {
  final AgentType type;
  final ExecutionStatus status;

  const _AgentIcon({required this.type, required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case AgentType.architect:
        icon = Icons.architecture;
        break;
      case AgentType.developer:
        icon = Icons.code;
        break;
      case AgentType.tester:
        icon = Icons.bug_report;
        break;
      case AgentType.manager:
        icon = Icons.assignment_ind;
        break;
    }

    final isRunning = status == ExecutionStatus.running || status == ExecutionStatus.planning;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isRunning)
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
          ),
        CircleAvatar(
          radius: 16,
          backgroundColor: isRunning ? AppColors.primary : Colors.grey.shade200,
          child: Icon(icon, color: isRunning ? Colors.white : Colors.grey.shade600, size: 18),
        ),
      ],
    );
  }
}

class _ExecutionStatusBadge extends StatelessWidget {
  final ExecutionStatus status;
  const _ExecutionStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ExecutionStatus.running:
        color = Colors.blue;
        break;
      case ExecutionStatus.completed:
        color = Colors.green;
        break;
      case ExecutionStatus.failed:
        color = Colors.red;
        break;
      case ExecutionStatus.planning:
        color = Colors.orange;
        break;
      case ExecutionStatus.waiting:
        color = Colors.amber;
        break;
      case ExecutionStatus.idle:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}
