import { codingAgent } from '../ai/coding.agent.js';
import { buildAgent } from '../ai/build.agent.js';
import { testingAgent } from '../ai/testing.agent.js';
import { debugAgent } from '../ai/debug.agent.js';
import { codeChangeService } from './code-change.service.js';
import { executionService } from './execution.service.js';
import { workspaceService } from './workspace.service.js';
import { ExecutionStatus } from '../../models/execution.js';
import { BuildStatus } from '../../models/build.js';
import { TestStatus } from '../../models/test.js';
export class DevelopmentOrchestrator {
    MAX_RETRIES = 3;
    async runTask(projectId, task, architecture) {
        const executionId = `exec_${Date.now()}`;
        let execution = {
            id: executionId,
            projectId,
            taskId: task.id,
            agentId: 'kindle-orchestrator-v1',
            status: ExecutionStatus.planning,
            startedAt: new Date().toISOString(),
            logs: [executionService.createLog(`Initiating autonomous execution for: ${task.title}`)],
        };
        let retryCount = 0;
        let isVerified = false;
        let debugContext = null;
        try {
            await executionService.recordExecution(execution);
            while (retryCount <= this.MAX_RETRIES && !isVerified) {
                if (retryCount > 0) {
                    execution.logs.push(executionService.createLog(`Self-healing attempt #${retryCount} started...`));
                    await executionService.recordExecution(execution);
                }
                // 1. Get Context
                const existingFiles = await workspaceService.listProjectFiles(projectId);
                // 2. Generate Code
                execution.status = ExecutionStatus.running;
                execution.logs.push(executionService.createLog(debugContext ? 'Generating targeted fix...' : 'Generating implementation...'));
                await executionService.recordExecution(execution);
                const codingResult = await codingAgent.executeTask({
                    projectId,
                    architecture,
                    task,
                    existingFiles,
                    debugContext,
                });
                // 3. Apply Changes
                execution.logs.push(executionService.createLog('Applying file modifications...', codingResult.explanation));
                const checkpointId = await codeChangeService.applyChanges(projectId, codingResult.changes, `Retry ${retryCount}: ${codingResult.explanation}`);
                execution.checkpointId = checkpointId;
                await executionService.recordExecution(execution);
                // 4. Verify Build
                execution.logs.push(executionService.createLog('Verifying build integrity...'));
                const buildResult = await buildAgent.buildProject(projectId, architecture.technology || 'flutter');
                if (buildResult.status !== BuildStatus.successful) {
                    execution.logs.push(executionService.createLog('Build failed. Analyzing logs...', buildResult.output));
                    debugContext = await this._getDebugContext(projectId, buildResult.output, task);
                    retryCount++;
                    continue;
                }
                // 5. Verify Behavior (Tests)
                execution.logs.push(executionService.createLog('Build stable. Running test suite...'));
                const testResults = await testingAgent.executeTestStrategy(projectId, architecture.technology || 'flutter');
                const allPassed = testResults.every(r => r.status === TestStatus.passed);
                if (!allPassed) {
                    const failedOutput = testResults.filter(r => r.status === TestStatus.failed).map(t => t.output).join('\n');
                    execution.logs.push(executionService.createLog('Test failures detected. Analyzing...', failedOutput));
                    debugContext = await this._getDebugContext(projectId, failedOutput, task);
                    retryCount++;
                    continue;
                }
                // Success!
                isVerified = true;
            }
            if (isVerified) {
                execution.status = ExecutionStatus.completed;
                execution.logs.push(executionService.createLog('Autonomous verification successful. Task finalized.'));
            }
            else {
                execution.status = ExecutionStatus.failed;
                execution.logs.push(executionService.createLog('Maximum self-healing retries reached. Human intervention required.'));
            }
        }
        catch (error) {
            execution.status = ExecutionStatus.failed;
            execution.logs.push(executionService.createLog('Orchestration critical failure', error.message));
        }
        execution.completedAt = new Date().toISOString();
        await executionService.recordExecution(execution);
        return execution;
    }
    async _getDebugContext(projectId, errorOutput, task) {
        const analysis = await debugAgent.analyzeFailure(projectId, errorOutput, task.description);
        return {
            rootCause: analysis.rootCause,
            errorOutput: errorOutput,
            suggestedFix: analysis.suggestedFix
        };
    }
}
export const developmentOrchestrator = new DevelopmentOrchestrator();
