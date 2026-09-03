import { decomposerAgent } from '../ai/decomposer.agent.js';
import { codingAgent } from '../ai/coding.agent.js';
import { integratorAgent } from '../ai/integrator.agent.js';
import { workspaceService } from './workspace.service.js';
import { socketService } from './socket.service.js';
export class GraphService {
    MAX_RETRIES = 3;
    INITIAL_DELAY = 1000;
    async executeTaskGraph(projectId, task, architecture, strategy = 'BALANCED', delegate = false) {
        socketService.emit(projectId, 'AGENT_PROGRESS', { message: `Decomposing task: ${task.title} using ${strategy} strategy...` });
        // 1. Decompose
        const decomposition = await decomposerAgent.decomposeTask(task, architecture, strategy);
        const subTasks = decomposition.subTasks;
        // ...
        // Pass delegate to executeSubTaskWithRetry
        socketService.emit(projectId, 'AGENT_PROGRESS', {
            message: `Decomposed into ${subTasks.length} granular sub-tasks.`,
            subTasks: subTasks.map(st => ({ id: st.id, title: st.title, role: st.role }))
        });
        const results = new Map();
        const completed = new Set();
        const inProgress = new Set();
        // 2. Execute Graph with Waves
        while (completed.size < subTasks.length) {
            const readyTasks = subTasks.filter(st => !completed.has(st.id) &&
                !inProgress.has(st.id) &&
                st.dependencies.every(depId => completed.has(depId)));
            if (readyTasks.length === 0 && inProgress.size === 0) {
                throw new Error('Deadlock detected in task graph dependencies');
            }
            if (readyTasks.length > 0) {
                console.log(`[GRAPH_SERVICE] 🌊 Executing wave of ${readyTasks.length} sub-tasks: ${readyTasks.map(t => t.title).join(', ')}`);
                socketService.emit(projectId, 'AGENT_PROGRESS', {
                    message: `Executing parallel wave: ${readyTasks.length} sub-tasks starting...`
                });
                // Execute wave in parallel
                const wavePromises = readyTasks.map(st => {
                    inProgress.add(st.id);
                    console.log(`[GRAPH_SERVICE] 🚀 Starting sub-task: ${st.title} (${st.role})`);
                    return this.executeSubTaskWithRetry(projectId, st, architecture, delegate)
                        .then(res => {
                        results.set(st.id, res);
                        completed.add(st.id);
                        inProgress.delete(st.id);
                        socketService.emit(projectId, 'AGENT_PROGRESS', {
                            message: `Sub-task completed: ${st.title}`,
                            subTaskId: st.id
                        });
                    })
                        .catch(err => {
                        socketService.emit(projectId, 'TASK_FAILED', {
                            message: `Sub-task failed: ${st.title} - ${err.message}`,
                            subTaskId: st.id
                        });
                        throw err;
                    });
                });
                await Promise.all(wavePromises);
            }
            else {
                // Wait for one of the in-progress tasks to finish
                await new Promise(resolve => setTimeout(resolve, 500));
            }
        }
        // 3. Integrate Results
        socketService.emit(projectId, 'AGENT_PROGRESS', { message: 'Integrating all sub-task results...' });
        const existingFiles = await workspaceService.listProjectFiles(projectId);
        const allCodingResults = Array.from(results.values());
        const finalResult = await integratorAgent.integrate(allCodingResults, architecture, existingFiles, delegate);
        return finalResult;
    }
    async executeSubTaskWithRetry(projectId, subTask, architecture, delegate = false) {
        let lastError;
        for (let attempt = 1; attempt <= this.MAX_RETRIES; attempt++) {
            try {
                const existingFiles = await workspaceService.listProjectFiles(projectId);
                return await codingAgent.executeTask({
                    projectId,
                    architecture,
                    task: {
                        id: subTask.id,
                        title: subTask.title,
                        description: subTask.description,
                        expectedOutput: subTask.expectedOutput,
                        acceptanceCriteria: subTask.acceptanceCriteria,
                        role: subTask.role
                    },
                    existingFiles,
                    delegate
                });
            }
            catch (error) {
                lastError = error;
                if (attempt < this.MAX_RETRIES) {
                    const delay = this.INITIAL_DELAY * Math.pow(2, attempt - 1);
                    socketService.emit(projectId, 'AGENT_PROGRESS', {
                        message: `Retrying sub-task ${subTask.title} (Attempt ${attempt + 1}/${this.MAX_RETRIES}) in ${delay}ms...`
                    });
                    await new Promise(resolve => setTimeout(resolve, delay));
                }
            }
        }
        throw lastError;
    }
}
export const graphService = new GraphService();
