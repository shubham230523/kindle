import { promises as fs } from 'fs';
import path from 'path';
import { workspaceService } from './workspace.service.js';
import { AgentExecution, ExecutionStatus, ExecutionLog } from '../../models/execution.js';

export class ExecutionService {

  async recordExecution(execution: AgentExecution): Promise<void> {
    const projectPath = workspaceService.getProjectPath(execution.projectId);
    const historyDir = path.join(projectPath, 'history');

    await fs.mkdir(historyDir, { recursive: true });

    const filePath = path.join(historyDir, `${execution.id}.json`);
    await fs.writeFile(filePath, JSON.stringify(execution, null, 2));
  }

  async getExecution(projectId: string, executionId: string): Promise<AgentExecution | null> {
    const projectPath = workspaceService.getProjectPath(projectId);
    const filePath = path.join(projectPath, 'history', `${executionId}.json`);

    try {
      const content = await fs.readFile(filePath, 'utf-8');
      return JSON.parse(content);
    } catch {
      return null;
    }
  }

  async listExecutions(projectId: string): Promise<AgentExecution[]> {
    const projectPath = workspaceService.getProjectPath(projectId);
    const historyDir = path.join(projectPath, 'history');

    try {
      const files = await fs.readdir(historyDir);
      const executions: AgentExecution[] = [];

      for (const file of files) {
        if (file.endsWith('.json')) {
          const content = await fs.readFile(path.join(historyDir, file), 'utf-8');
          executions.push(JSON.parse(content));
        }
      }

      return executions.sort((a, b) => b.startedAt.localeCompare(a.startedAt));
    } catch {
      return [];
    }
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
