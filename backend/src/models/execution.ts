export enum ExecutionStatus {
  idle = 'idle',
  waiting = 'waiting',
  planning = 'planning',
  running = 'running',
  completed = 'completed',
  failed = 'failed'
}

export interface ExecutionLog {
  timestamp: string;
  message: string;
  details?: string;
}

export interface AgentExecution {
  id: string;
  projectId: string;
  taskId: string;
  agentId: string;
  status: ExecutionStatus;
  startedAt: string;
  completedAt?: string;
  logs: ExecutionLog[];
  checkpointId?: string;
}
