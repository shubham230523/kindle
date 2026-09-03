import { codingAgent } from '../ai/coding.agent.js';
import { buildAgent } from '../ai/build.agent.js';
import { testingAgent } from '../ai/testing.agent.js';
import { debugAgent } from '../ai/debug.agent.js';
import { graphService } from './graph.service.js';
import { codeChangeService } from './code-change.service.js';
import { executionService } from './execution.service.js';
import { workspaceService } from './workspace.service.js';
import { socketService } from './socket.service.js';
import { AgentExecution, ExecutionStatus } from '../../models/execution.js';
import { BuildStatus } from '../../models/build.js';
import { TestStatus } from '../../models/test.js';
import { AiError } from '../../models/ai.js';

export class DevelopmentOrchestrator {
  private readonly MAX_RETRIES = 3;

  async runTask(projectId: string, task: any, architecture: any): Promise<AgentExecution> {
    const executionId = `exec_${Date.now()}`;
    let execution: AgentExecution = {
      id: executionId,
      projectId,
      taskId: task.id,
      agentId: 'kindle-orchestrator-v2',
      status: ExecutionStatus.planning,
      startedAt: new Date().toISOString(),
      logs: [executionService.createLog(`Initiating autonomous execution for: ${task.title}`)],
    };

    socketService.emit(projectId, 'AGENT_STARTED', { taskId: task.id, title: task.title });

    let retryCount = 0;
    let isVerified = false;
    let debugContext: any = null;

    try {
      await executionService.recordExecution(execution);

      while (retryCount <= this.MAX_RETRIES && !isVerified) {
        try {
          if (retryCount > 0) {
            const healMsg = `Self-healing attempt #${retryCount} started...`;
            execution.logs.push(executionService.createLog(healMsg));
            socketService.emit(projectId, 'AGENT_PROGRESS', { message: healMsg });
            await executionService.recordExecution(execution);
          }

          // 1. Generate Code (using Graph Service)
          execution.status = ExecutionStatus.running;
          const progressMsg = debugContext ? 'Generating targeted fix...' : 'Executing multi-agent task graph...';
          execution.logs.push(executionService.createLog(progressMsg));
          socketService.emit(projectId, 'AGENT_PROGRESS', { status: execution.status, message: progressMsg });
          await executionService.recordExecution(execution);

          let codingResult;
          if (debugContext) {
            // If we are healing, we might still use the coding agent directly for the fix
            // or we could re-run a specific sub-task if we tracked them.
            // For now, let's use the coding agent for targeted fixes.
            const existingFiles = await workspaceService.listProjectFiles(projectId);
            codingResult = await codingAgent.executeTask({
              projectId,
              architecture,
              task,
              existingFiles,
              debugContext,
            });
          } else {
            codingResult = await graphService.executeTaskGraph(projectId, task, architecture);
          }

          // 2. Apply Changes
          const applyMsg = 'Applying integrated modifications...';
          execution.logs.push(executionService.createLog(applyMsg, codingResult.explanation));
          socketService.emit(projectId, 'AGENT_PROGRESS', { message: applyMsg });

          const checkpointId = await codeChangeService.applyChanges(
            projectId,
            codingResult.changes,
            `Retry ${retryCount}: ${codingResult.explanation}`
          );
          execution.checkpointId = checkpointId;
          await executionService.recordExecution(execution);

          // 4. Verify Build
          const buildMsg = 'Verifying build integrity...';
          execution.logs.push(executionService.createLog(buildMsg));
          socketService.emit(projectId, 'AGENT_PROGRESS', { message: buildMsg });

          const buildResult = await buildAgent.buildProject(projectId, architecture.technology || 'flutter');

          if (buildResult.status !== BuildStatus.successful) {
            if (buildResult.output.includes('timed out')) {
              throw new Error('BUILD_TIMEOUT: The build process exceeded the time limit.');
            }
            execution.logs.push(executionService.createLog('Build failed. Analyzing logs...', buildResult.output));
            debugContext = await this._getDebugContext(projectId, buildResult.output, task);
            retryCount++;
            continue;
          }

          // 5. Verify Behavior (Tests)
          const testMsg = 'Build stable. Running test suite...';
          execution.logs.push(executionService.createLog(testMsg));
          socketService.emit(projectId, 'AGENT_PROGRESS', { message: testMsg });

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

        } catch (stepError: any) {
          // Handle specific failures within the loop
          const errorType = this._categorizeError(stepError);
          const errorMsg = `Critical Step Failure [${errorType}]: ${stepError.message}`;

          execution.logs.push(executionService.createLog(errorMsg));
          socketService.emit(projectId, 'TASK_FAILED', { type: errorType, message: stepError.message });

          if (this._isFatal(errorType)) throw stepError; // Stop the loop for fatal errors

          retryCount++;
          if (retryCount > this.MAX_RETRIES) throw stepError;
        }
      }

      if (isVerified) {
        execution.status = ExecutionStatus.completed;
        const finalMsg = 'Autonomous verification successful. Task finalized.';
        execution.logs.push(executionService.createLog(finalMsg));
        socketService.emit(projectId, 'AGENT_PROGRESS', { status: execution.status, message: finalMsg });
      } else {
        execution.status = ExecutionStatus.failed;
        execution.logs.push(executionService.createLog('Maximum self-healing retries reached. Human intervention required.'));
      }

    } catch (criticalError: any) {
      execution.status = ExecutionStatus.failed;
      const failMsg = `Orchestration Critical Failure: ${criticalError.message}`;
      execution.logs.push(executionService.createLog(failMsg));
      socketService.emit(projectId, 'SYSTEM_ERROR', { message: failMsg });
    }

    execution.completedAt = new Date().toISOString();
    await executionService.recordExecution(execution);
    return execution;
  }

  private _categorizeError(error: any): string {
    if (error instanceof AiError) return error.code;
    if (error.message.includes('Security Error')) return 'SECURITY_VIOLATION';
    if (error.message.includes('BUILD_TIMEOUT')) return 'BUILD_TIMEOUT';
    if (error.message.includes('Invalid AI Output')) return 'INVALID_AI_OUTPUT';
    return 'UNKNOWN_AGENT_CRASH';
  }

  private _isFatal(errorType: string): boolean {
    const fatalTypes = ['AI_NETWORK_FAILURE', 'SECURITY_VIOLATION', 'SYSTEM_ERROR'];
    return fatalTypes.includes(errorType);
  }

  private async _getDebugContext(projectId: string, errorOutput: string, task: any) {
    try {
      const analysis = await debugAgent.analyzeFailure(projectId, errorOutput, task.description);
      return {
        rootCause: analysis.rootCause,
        errorOutput: errorOutput,
        suggestedFix: analysis.suggestedFix
      };
    } catch (e) {
      return {
        rootCause: 'Failed to analyze logs automatically.',
        errorOutput: errorOutput,
        suggestedFix: 'Manual review required.'
      };
    }
  }
}

export const developmentOrchestrator = new DevelopmentOrchestrator();
