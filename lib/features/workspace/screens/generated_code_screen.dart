import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/file_node.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class GeneratedCodeScreen extends StatefulWidget {
  final List<FileNode> fileSystem;
  const GeneratedCodeScreen({super.key, required this.fileSystem});

  @override
  State<GeneratedCodeScreen> createState() => _GeneratedCodeScreenState();
}

class _GeneratedCodeScreenState extends State<GeneratedCodeScreen> {
  final List<FileNode> _openFiles = [];
  int _activeTabIndex = -1;

  void _openFile(FileNode node) {
    if (node.isFolder) return;
    
    final existingIndex = _openFiles.indexWhere((f) => f.name == node.name);
    if (existingIndex != -1) {
      setState(() {
        _activeTabIndex = existingIndex;
      });
    } else {
      setState(() {
        _openFiles.add(node);
        _activeTabIndex = _openFiles.length - 1;
      });
    }
  }

  void _closeFile(int index) {
    setState(() {
      _openFiles.removeAt(index);
      if (_activeTabIndex >= _openFiles.length) {
        _activeTabIndex = _openFiles.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Explorer
          SizedBox(
            width: isDesktop ? 260 : 180,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text('EXPLORER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: widget.fileSystem.map<Widget>((node) => _FileTreeItem(
                        node: node,
                        level: 0,
                        onSelected: _openFile,
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Code Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_openFiles.isNotEmpty) _buildTabBar(),
                Expanded(
                  child: Container(
                    color: const Color(0xFFFCFCFC),
                    child: _activeTabIndex == -1
                        ? _buildEmptyState()
                        : _CodeViewer(file: _openFiles[_activeTabIndex]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      color: Colors.grey.shade100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _openFiles.length,
        itemBuilder: (context, index) {
          final isSelected = index == _activeTabIndex;
          return GestureDetector(
            onTap: () => setState(() => _activeTabIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                  top: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code, size: 14, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    _openFiles[index].name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _closeFile(index),
                    child: Icon(Icons.close, size: 14, color: isSelected ? Colors.black : Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('Select a file from the explorer to view the generated spark.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _CodeViewer extends StatelessWidget {
  final FileNode file;
  const _CodeViewer({required this.file});

  @override
  Widget build(BuildContext context) {
    final lines = (file.content ?? '').split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                file.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy Code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: file.content ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Code Area
        Expanded(
          child: Container(
            color: const Color(0xFFFCFCFC),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Line Numbers
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            color: Colors.grey.shade50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                lines.length,
                                (i) => Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    height: 1.5,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(width: 1, color: Colors.grey.shade200),
                          // Content
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: SelectableText(
                              file.content ?? '',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF24292E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FileTreeItem extends StatefulWidget {
  final FileNode node;
  final int level;
  final Function(FileNode) onSelected;

  const _FileTreeItem({
    required this.node,
    required this.level,
    required this.onSelected,
  });

  @override
  State<_FileTreeItem> createState() => _FileTreeItemState();
}

class _FileTreeItemState extends State<_FileTreeItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (widget.node.isFolder) {
              setState(() {
                widget.node.isExpanded = !widget.node.isExpanded;
              });
            } else {
              widget.onSelected(widget.node);
            }
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0 + (widget.level * 16.0),
              top: 4,
              bottom: 4,
              right: 8,
            ),
            child: Row(
              children: [
                Icon(
                  widget.node.isFolder
                      ? (widget.node.isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right)
                      : Icons.description_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Icon(
                  widget.node.isFolder ? Icons.folder : Icons.code,
                  size: 16,
                  color: widget.node.isFolder ? Colors.amber.shade700 : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.node.name,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.node.isFolder && widget.node.isExpanded && widget.node.children != null)
          ...widget.node.children!.map((child) => _FileTreeItem(
                node: child,
                level: widget.level + 1,
                onSelected: widget.onSelected,
              )),
      ],
    );
  }
}
