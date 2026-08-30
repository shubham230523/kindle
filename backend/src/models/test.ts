export enum TestStatus {
  passed = 'passed',
  failed = 'failed',
  skipped = 'skipped',
  running = 'running',
  queued = 'queued'
}

export enum TestCategory {
  unit = 'unit',
  widget = 'widget',
  integration = 'integration'
}

export interface TestCaseResult {
  id: string;
  name: string;
  suite: string;
  status: TestStatus;
  durationMs?: number;
  errorMessage?: string;
  stackTrace?: string;
}

export interface TestRunResult {
  id: string;
  projectId: string;
  category: TestCategory;
  status: TestStatus;
  startedAt: string;
  completedAt?: string;
  totalCount: number;
  passedCount: number;
  failedCount: number;
  skippedCount: number;
  coverage?: number;
  output: string;
  testCases: TestCaseResult[];
}
