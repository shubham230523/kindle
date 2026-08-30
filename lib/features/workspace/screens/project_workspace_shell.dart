import 'package:flutter/material.dart';
import '../../project/models/project.dart';
import 'project_dashboard_screen.dart';
import 'agent_activity_screen.dart';
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
  int _selectedIndex = 0;

  final List<_WorkspaceDestination> _destinations = [
    const _WorkspaceDestination('Overview', Icons.dashboard_outlined, Icons.dashboard),
    const _WorkspaceDestination('Requirements', Icons.assignment_outlined, Icons.assignment),
    const _WorkspaceDestination('Architecture', Icons.account_tree_outlined, Icons.account_tree),
    const _WorkspaceDestination('Plan', Icons.map_outlined, Icons.map),
    const _WorkspaceDestination('Development', Icons.code_outlined, Icons.code),
    const _WorkspaceDestination('Builds', Icons.build_circle_outlined, Icons.build_circle),
    const _WorkspaceDestination('Testing', Icons.bug_report_outlined, Icons.bug_report),
    const _WorkspaceDestination('Settings', Icons.settings_outlined, Icons.settings),
  ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return ProjectDashboardScreen(project: widget.project);
      case 1:
        return RequirementsListScreen(project: widget.project);
      case 2:
        return ArchitectureOverviewScreen(project: widget.project);
      case 3:
        return DevelopmentPlanScreen(project: widget.project);
      case 4:
        return const AgentActivityScreen();
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

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
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
                      child: Row(
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
    );
  }
}

class _WorkspaceDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _WorkspaceDestination(this.label, this.icon, this.selectedIcon);
}
