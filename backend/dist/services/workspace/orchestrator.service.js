import { codingAgent } from '../ai/coding.agent.js';
import { codeChangeService } from './code-change.service.js';
import { executionService } from './execution.service.js';
import { workspaceService } from './workspace.service.js';
import { ExecutionStatus } from '../../models/execution.js';
export class DevelopmentOrchestrator {
    async runTask(projectId, task, architecture) {
        const executionId = `exec_${Date.now()}`;
        let execution = {
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
            const checkpointId = await codeChangeService.applyChanges(projectId, result.changes, `Task: ${task.title} - ${result.explanation}`);
            execution.checkpointId = checkpointId;
            execution.status = ExecutionStatus.completed;
            execution.completedAt = new Date().toISOString();
            execution.logs.push(executionService.createLog('Task execution finished successfully.'));
        }
        catch (error) {
            execution.status = ExecutionStatus.failed;
            execution.completedAt = new Date().toISOString();
            execution.logs.push(executionService.createLog('Task execution failed', error.message));
        }
        await executionService.recordExecution(execution);
        return execution;
    }
}
export const developmentOrchestrator = new DevelopmentOrchestrator();
