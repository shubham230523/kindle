import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workspace_viewmodel.dart';
import '../../../core/services/agent_simulator_service.dart';
import '../../../core/services/backend_agent_service.dart';
import '../../project/models/project.dart';
import 'project_dashboard_screen.dart';
import '../widgets/onboarding_overlay.dart';
import 'agent_activity_screen.dart';
import 'generated_code_screen.dart';
import 'generated_changes_screen.dart';
import 'build_dashboard_screen.dart';
import 'testing_dashboard_screen.dart';
import 'debug_agent_screen.dart';
import 'fix_history_screen.dart';
import 'project_artifacts_screen.dart';
import '../../project/screens/project_delivery_screen.dart';
import '../../project/screens/requirements_list_screen.dart';
import '../../project/screens/architecture_overview_screen.dart';
import '../../project/screens/development_plan_screen.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';

class ProjectWorkspaceShell extends StatefulWidget {
  final Project project;

  const ProjectWorkspaceShell({super.key, required this.project});

  @override
  State<ProjectWorkspaceShell> createState() => _ProjectWorkspaceShellState();
}

class _ProjectWorkspaceShellState extends State<ProjectWorkspaceShell> {
  late WorkspaceViewModel _viewModel;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = WorkspaceViewModel(widget.project, BackendAgentService());
  }

  final List<_WorkspaceDestination> _destinations = [
    const _WorkspaceDestination('Overview', Icons.dashboard_outlined, Icons.dashboard),
    const _WorkspaceDestination('Requirements', Icons.assignment_outlined, Icons.assignment),
    const _WorkspaceDestination('Architecture', Icons.account_tree_outlined, Icons.account_tree),
    const _WorkspaceDestination('Plan', Icons.map_outlined, Icons.map),
    const _WorkspaceDestination('Development', Icons.code_outlined, Icons.code),
    const _WorkspaceDestination('Changes', Icons.history, Icons.history),
    const _WorkspaceDestination('Source', Icons.folder_outlined, Icons.folder),
    const _WorkspaceDestination('Builds', Icons.build_circle_outlined, Icons.build_circle),
    const _WorkspaceDestination('Testing', Icons.bug_report_outlined, Icons.bug_report),
    const _WorkspaceDestination('Debug', Icons.healing_outlined, Icons.healing),
    const _WorkspaceDestination('Fix History', Icons.auto_fix_high_outlined, Icons.auto_fix_high),
    const _WorkspaceDestination('Artifacts', Icons.inventory_2_outlined, Icons.inventory_2),
    const _WorkspaceDestination('Ship', Icons.rocket_launch_outlined, Icons.rocket_launch),
    const _WorkspaceDestination('Settings', Icons.settings_outlined, Icons.settings),
  ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return ProjectDashboardScreen(
          project: _viewModel.project,
          isDeveloping: _viewModel.isDeveloping,
          activeExecution: _viewModel.activeExecution,
        );
      case 1:
        return RequirementsListScreen(project: _viewModel.project);
      case 2:
        return ArchitectureOverviewScreen(project: _viewModel.project);
      case 3:
        return DevelopmentPlanScreen(project: _viewModel.project);
      case 4:
        return AgentActivityScreen(viewModel: _viewModel);
      case 5:
        return GeneratedChangesScreen(project: _viewModel.project);
      case 6:
        return GeneratedCodeScreen(fileSystem: _viewModel.virtualFileSystem);
      case 7:
        return BuildDashboardScreen(project: _viewModel.project);
      case 8:
        return TestingDashboardScreen(project: _viewModel.project);
      case 9:
        return const DebugAgentScreen();
      case 10:
        return FixHistoryScreen(project: _viewModel.project);
      case 11:
        return ProjectArtifactsScreen(project: _viewModel.project);
      case 12:
        return ProjectDeliveryScreen(project: _viewModel.project);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_destinations[_selectedIndex].icon, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                '${_destinations[_selectedIndex].label} Section',
                style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('This feature is currently sparked but not yet implemented.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return ChangeNotifierProvider.value(
          value: _viewModel,
          child: Stack(
            children: [
              Scaffold(
              body: Row(
            children: [
              if (!isMobile)
                SizedBox(
                  width: isDesktop ? 240 : 80,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              extended: isDesktop,
                              selectedIndex: _selectedIndex,
                              onDestinationSelected: (int index) {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              leading: isDesktop
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.auto_awesome, color: AppColors.primary),
                                              const SizedBox(width: 12),
                                              Text(
                                                'KINDLE',
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 2,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          if (_viewModel.isDeveloping)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0, left: 36.0),
                                              child: Text(
                                                'DEVELOPING...',
                                                style: TextStyle(color: Colors.amber.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24.0),
                                      child: Icon(Icons.auto_awesome, color: AppColors.primary),
                                    ),
                              destinations: _destinations.map((d) {
                                return NavigationRailDestination(
                                  icon: Icon(d.icon),
                                  selectedIcon: Icon(d.selectedIcon),
                                  label: Text(d.label),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _buildBody()),
            ],
          ),
          bottomNavigationBar: isMobile
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: _destinations.take(5).map((d) {
                    return NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    );
                  }).toList(),
                )
              : null,
          floatingActionButton: _selectedIndex == 0 && !_viewModel.isDeveloping
              ? FloatingActionButton.extended(
                  onPressed: () {
                    _viewModel.startDevelopment();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Kindle Agents have started development!'),
                          ],
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Development'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                )
              : null,
            ),
            if (_viewModel.downloadStream != null)
              OnboardingOverlay(
                progressStream: _viewModel.downloadStream!,
                onDismiss: () => _viewModel.onDownloadDismissed(),
              ),
          ],
        ));
      },
    );
  }
}

class _WorkspaceDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _WorkspaceDestination(this.label, this.icon, this.selectedIcon);
}
