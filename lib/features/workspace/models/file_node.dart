class FileNode {
  final String name;
  final bool isFolder;
  final List<FileNode>? children;
  final String? content;
  bool isExpanded;

  FileNode({
    required this.name,
    this.isFolder = false,
    this.children,
    this.content,
    this.isExpanded = false,
  });
}
