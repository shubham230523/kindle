import { developmentOrchestrator } from '../../services/workspace/orchestrator.service.js';
import { executionService } from '../../services/workspace/execution.service.js';
import { storageService } from '../../services/storage/storage.service.js';
import { authGuard } from '../../plugins/auth-guard.js';
export default async function developmentRoutes(fastify) {
    async function checkOwnership(projectId, userId) {
        const project = await storageService.load('projects', projectId);
        if (!project)
            throw new Error('Project not found');
        if (project.userId !== userId)
            throw new Error('Unauthorized');
    }
    fastify.post('/development/run-task', { preHandler: [authGuard] }, async (request, reply) => {
        const { projectId, task, architecture, isLocalMode } = request.body;
        const userId = request.user.id;
        if (!projectId || !task || !architecture) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Project ID, Task, and Architecture are required',
            });
        }
        try {
            await checkOwnership(projectId, userId);
            const execution = await developmentOrchestrator.runTask(projectId, task, architecture, isLocalMode);
            return execution;
        }
        catch (error) {
            return reply.status(error.message === 'Unauthorized' ? 403 : 500).send({
                error: error.message,
            });
        }
    });
    fastify.get('/development/:projectId/history', { preHandler: [authGuard] }, async (request, reply) => {
        const { projectId } = request.params;
        const userId = request.user.id;
        try {
            await checkOwnership(projectId, userId);
            const history = await executionService.listExecutions(projectId);
            return { history };
        }
        catch (error) {
            return reply.status(error.message === 'Unauthorized' ? 403 : 500).send({
                error: error.message,
            });
        }
    });
}
