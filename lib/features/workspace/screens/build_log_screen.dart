import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final List<BuildLogEntry> _allLogs = [];
  List<BuildLogEntry> _filteredLogs = [];
  bool _autoScroll = true;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _startLogSimulation();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredLogs = List.from(_allLogs);
      } else {
        _filteredLogs = _allLogs
            .where((log) => log.message.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _startLogSimulation() {
    final mockMessages = [
      'Checking flutter toolchain...',
      'Found Flutter 3.47.0 at /usr/local/flutter',
      'Resolving dependencies...',
      'dependency_one: ^1.2.0 (new)',
      'dependency_two: ^0.8.5 (upgraded)',
      'Downloading dependencies...',
      'Running build_runner...',
      'Compiling architecture modules...',
      'Compiling lib/main.dart...',
      '[WARNING] Found deprecated API usage in lib/core/utils.dart',
      'Generating Android manifest...',
      'Linking native resources...',
      'Signing APK with development certificate...',
      '[ERROR] Failed to find debug.keystore at ~/.android/debug.keystore',
      'Retrying with fallback credentials...',
      'Build successful. Artifact located at build/app/outputs/flutter-apk/app-debug.apk',
    ];

    int index = 0;
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (index >= mockMessages.length) {
        timer.cancel();
        return;
      }

      final msg = mockMessages[index];
      BuildLogLevel level = BuildLogLevel.info;
      if (msg.contains('[ERROR]')) level = BuildLogLevel.error;
      if (msg.contains('[WARNING]')) level = BuildLogLevel.warning;

      final newLog = BuildLogEntry(
        timestamp: DateTime.now(),
        message: msg,
        level: level,
      );

      setState(() {
        _allLogs.add(newLog);
        _onSearchChanged(); // Refresh filtered view
      });

      if (_autoScroll) {
        _scrollToBottom();
      }
      index++;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.build.platform} Build Logs', style: const TextStyle(fontSize: 16)),
            Text('ID: ${widget.build.id}', style: Theme.of(context).textTheme.labelSmall),
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
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _filteredLogs.length,
          itemBuilder: (context, index) {
            return _LogLine(entry: _filteredLogs[index]);
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
