import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workspace_viewmodel.dart';
import '../../project/models/build.dart';
import '../../project/models/build_log.dart';

class BuildLogScreen extends StatefulWidget {
  final ProjectBuild build;

  const BuildLogScreen({super.key, required this.build});

  @override
  State<BuildLogScreen> createState() => _BuildLogScreenState();
}

class _BuildLogScreenState extends State<BuildLogScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _autoScroll = true;
  int _previousLogCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorkspaceViewModel>();
    final activeBuild = viewModel.project.builds.firstWhere(
      (b) => b.id == widget.build.id,
      orElse: () => widget.build,
    );

    final allLogs = activeBuild.logs;
    final searchQuery = _searchController.text.toLowerCase().trim();

    final filteredLogs = searchQuery.isEmpty
        ? allLogs
        : allLogs.where((log) => log.message.toLowerCase().contains(searchQuery)).toList();

    if (_autoScroll && allLogs.length > _previousLogCount) {
      _previousLogCount = allLogs.length;
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${activeBuild.platform} Build Logs', style: const TextStyle(fontSize: 16)),
            Text('ID: ${activeBuild.id}', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_center),
            onPressed: () => setState(() => _autoScroll = !_autoScroll),
            tooltip: 'Toggle Auto-scroll',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Filter logs...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF1E1E1E), // Terminal black
        child: filteredLogs.isEmpty
            ? const Center(
                child: Text(
                  'No log output available.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) {
                  return _LogLine(entry: filteredLogs[index]);
                },
              ),
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  final BuildLogEntry entry;
  const _LogLine({required this.entry});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss').format(entry.timestamp);

    Color textColor;
    switch (entry.level) {
      case BuildLogLevel.error:
        textColor = Colors.redAccent;
        break;
      case BuildLogLevel.warning:
        textColor = Colors.orangeAccent;
        break;
      case BuildLogLevel.debug:
        textColor = Colors.grey;
        break;
      default:
        textColor = Colors.greenAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeStr,
            style: const TextStyle(
              color: Color(0xFF808080),
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.message,
              style: TextStyle(
                color: textColor,
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
