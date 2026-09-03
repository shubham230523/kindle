import { FastifyInstance } from 'fastify';
import { developmentOrchestrator } from '../../services/workspace/orchestrator.service.js';
import { executionService } from '../../services/workspace/execution.service.js';
import { storageService } from '../../services/storage/storage.service.js';
import { ProjectState } from '../../models/pipeline.js';
import { authGuard } from '../../plugins/auth-guard.js';

export default async function developmentRoutes(fastify: FastifyInstance) {

  async function checkOwnership(projectId: string, userId: string) {
    const project = await storageService.load<ProjectState>('projects', projectId);
    if (!project) throw new Error('Project not found');
    if (project.userId !== userId) throw new Error('Unauthorized');
  }

  fastify.post('/development/run-task', { preHandler: [authGuard] }, async (request, reply) => {
    const { projectId, task, architecture, isLocalMode } = request.body as {
      projectId: string;
      task: any;
      architecture: any;
      isLocalMode?: boolean;
    };
    const userId = request.user!.id;

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
    } catch (error: any) {
      return reply.status(error.message === 'Unauthorized' ? 403 : 500).send({
        error: error.message,
      });
    }
  });

  fastify.get('/development/:projectId/history', { preHandler: [authGuard] }, async (request, reply) => {
    const { projectId } = request.params as { projectId: string };
    const userId = request.user!.id;

    try {
      await checkOwnership(projectId, userId);
      const history = await executionService.listExecutions(projectId);
      return { history };
    } catch (error: any) {
      return reply.status(error.message === 'Unauthorized' ? 403 : 500).send({
        error: error.message,
      });
    }
  });
}
