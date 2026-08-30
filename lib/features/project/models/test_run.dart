enum TestStatus { passed, failed, skipped, running, queued }

enum TestCategory { unit, widget, integration }

class TestCase {
  final String id;
  final String name;
  final String suite;
  final TestStatus status;
  final Duration? duration;
  final String? errorMessage;
  final String? stackTrace;

  const TestCase({
    required this.id,
    required this.name,
    required this.suite,
    required this.status,
    this.duration,
    this.errorMessage,
    this.stackTrace,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'suite': suite,
      'status': status.name,
      'duration': duration?.inMilliseconds,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
    };
  }

  factory TestCase.fromMap(Map<String, dynamic> map) {
    return TestCase(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      suite: map['suite'] ?? '',
      status: TestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TestStatus.queued,
      ),
      duration: map['duration'] != null ? Duration(milliseconds: map['duration']) : null,
      errorMessage: map['errorMessage'],
      stackTrace: map['stackTrace'],
    );
  }
}

class TestRun {
  final String id;
  final TestCategory category;
  final TestStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalCount;
  final int passedCount;
  final int failedCount;
  final int skippedCount;
  final double coverage; // 0.0 to 1.0
  final List<TestCase> testCases;

  const TestRun({
    required this.id,
    required this.category,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.totalCount,
    required this.passedCount,
    required this.failedCount,
    required this.skippedCount,
    this.coverage = 0.0,
    this.testCases = const [],
  });

  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalCount': totalCount,
      'passedCount': passedCount,
      'failedCount': failedCount,
      'skippedCount': skippedCount,
      'coverage': coverage,
      'testCases': testCases.map((x) => x.toMap()).toList(),
    };
  }

  factory TestRun.fromMap(Map<String, dynamic> map) {
    return TestRun(
      id: map['id'] ?? '',
      category: TestCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TestCategory.unit,
      ),
      status: TestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TestStatus.queued,
      ),
      startedAt: DateTime.tryParse(map['startedAt'] ?? '') ?? DateTime.now(),
      completedAt: DateTime.tryParse(map['completedAt'] ?? ''),
      totalCount: map['totalCount'] ?? 0,
      passedCount: map['passedCount'] ?? 0,
      failedCount: map['failedCount'] ?? 0,
      skippedCount: map['skippedCount'] ?? 0,
      coverage: (map['coverage'] as num? ?? 0.0).toDouble(),
      testCases: List<TestCase>.from(
        (map['testCases'] as List? ?? []).map((x) => TestCase.fromMap(x)),
      ),
    );
  }
}
