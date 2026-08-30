import { FastifyInstance } from 'fastify';
import { developmentOrchestrator } from '../../services/workspace/orchestrator.service.js';
import { executionService } from '../../services/workspace/execution.service.js';

export default async function developmentRoutes(fastify: FastifyInstance) {
  fastify.post('/development/run-task', async (request, reply) => {
    const { projectId, task, architecture } = request.body as {
      projectId: string;
      task: any;
      architecture: any;
    };

    if (!projectId || !task || !architecture) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Project ID, Task, and Architecture are required',
      });
    }

    try {
      // Start in background and return immediate response?
      // For now, simple wait and return to keep it easy for initial integration
      const execution = await developmentOrchestrator.runTask(projectId, task, architecture);
      return execution;
    } catch (error: any) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: 'Internal Server Error',
        message: error.message,
      });
    }
  });

  fastify.get('/development/:projectId/history', async (request, reply) => {
    const { projectId } = request.params as { projectId: string };

    try {
      const history = await executionService.listExecutions(projectId);
      return { history };
    } catch (error: any) {
      return reply.status(500).send({
        error: 'Internal Server Error',
        message: error.message,
      });
    }
  });
}
