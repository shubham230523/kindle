export enum BuildStatus {
  queued = 'queued',
  running = 'running',
  successful = 'successful',
  failed = 'failed'
}

export interface BuildResult {
  id: string;
  projectId: string;
  platform: string;
  status: BuildStatus;
  output: string;
  startedAt: string;
  completedAt?: string;
  durationMs?: number;
}
