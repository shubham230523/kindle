import { storageService } from '../storage/storage.service.js';
import { AgentExecution, ExecutionStatus, ExecutionLog } from '../../models/execution.js';

export class ExecutionService {

  async recordExecution(execution: AgentExecution): Promise<void> {
    await storageService.save('executions', execution.id, execution);
  }

  async getExecution(projectId: string, executionId: string): Promise<AgentExecution | null> {
    return storageService.load<AgentExecution>('executions', executionId);
  }

  async listExecutions(projectId: string): Promise<AgentExecution[]> {
    const all = await storageService.list<AgentExecution>('executions');
    return all
      .filter(e => e.projectId === projectId)
      .sort((a, b) => b.startedAt.localeCompare(a.startedAt));
  }

  createLog(message: string, details?: string): ExecutionLog {
    return {
      timestamp: new Date().toISOString(),
      message,
      details,
    };
  }
}

export const executionService = new ExecutionService();
