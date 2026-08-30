import { codingAgent } from '../ai/coding.agent.js';
import { buildAgent } from '../ai/build.agent.js';
import { debugAgent } from '../ai/debug.agent.js';
import { codeChangeService } from './code-change.service.js';
import { executionService } from './execution.service.js';
import { workspaceService } from './workspace.service.js';
import { AgentExecution, ExecutionStatus } from '../../models/execution.js';
import { BuildStatus } from '../../models/build.js';

export class DevelopmentOrchestrator {

  async runTask(projectId: string, task: any, architecture: any): Promise<AgentExecution> {
    const executionId = `exec_${Date.now()}`;
    let execution: AgentExecution = {
      id: executionId,
      projectId,
      taskId: task.id,
      agentId: 'coding-agent-v1',
      status: ExecutionStatus.planning,
      startedAt: new Date().toISOString(),
      logs: [executionService.createLog(`Starting execution for task: ${task.title}`)],
    };

    try {
      await executionService.recordExecution(execution);

      // 1. Get existing files
      execution.logs.push(executionService.createLog('Scanning existing file structure...'));
      const existingFiles = await workspaceService.listProjectFiles(projectId);

      // 2. Generate changes using Coding Agent
      execution.status = ExecutionStatus.running;
      execution.logs.push(executionService.createLog('Coding Agent generating implementation...'));
      await executionService.recordExecution(execution);

      const result = await codingAgent.executeTask({
        projectId,
        architecture,
        task,
        existingFiles,
      });

      execution.logs.push(executionService.createLog('Validation successful. Applying changes...', result.explanation));

      // 3. Apply changes via CodeChangeService
      const checkpointId = await codeChangeService.applyChanges(
        projectId,
        result.changes,
        `Task: ${task.title} - ${result.explanation}`
      );

      execution.checkpointId = checkpointId;

      // 4. Trigger Build Agent
      execution.logs.push(executionService.createLog('Triggering Build Agent for verification...'));
      await executionService.recordExecution(execution);

      const buildResult = await buildAgent.buildProject(projectId, architecture.technology || 'flutter');

      if (buildResult.status === BuildStatus.successful) {
        execution.logs.push(executionService.createLog('Build successful. Verification complete.'));
        execution.status = ExecutionStatus.completed;
      } else {
        execution.logs.push(executionService.createLog('Build failed. Triggering Debug Agent...', buildResult.output));

        // 5. Trigger Debug Agent
        const debugResult = await debugAgent.analyzeFailure(projectId, buildResult.output, task.description);
        execution.logs.push(executionService.createLog('Debug Analysis Complete', debugResult.rootCause));
        execution.status = ExecutionStatus.failed; // Still mark as failed for this run, fix will be next task
      }

      execution.completedAt = new Date().toISOString();

    } catch (error: any) {
      execution.status = ExecutionStatus.failed;
      execution.completedAt = new Date().toISOString();
      execution.logs.push(executionService.createLog('Task execution failed', error.message));
    }

    await executionService.recordExecution(execution);
    return execution;
  }
}

export const developmentOrchestrator = new DevelopmentOrchestrator();
