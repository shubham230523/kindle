import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/mock_project.dart';
import '../features/workspace/screens/project_workspace_shell.dart';

class KindleApp extends StatelessWidget {
  const KindleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kindle',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: ProjectWorkspaceShell(project: MockProject.syncTasks),
    );
  }
}
