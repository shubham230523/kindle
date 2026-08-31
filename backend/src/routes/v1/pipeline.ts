import { FastifyInstance } from 'fastify';
import { kindlePipeline } from '../../services/workspace/pipeline.service.js';
import { authGuard } from '../../plugins/auth-guard.js';

export default async function pipelineRoutes(fastify: FastifyInstance) {

  fastify.post('/pipeline/init', { preHandler: [authGuard] }, async (request, reply) => {
    const { id, idea } = request.body as { id: string; idea: string };
    const userId = request.user!.id;

    if (!id || !idea) {
      return reply.status(400).send({ error: 'Project ID and Idea are required' });
    }

    try {
      const state = await kindlePipeline.initializeProject(id, idea, userId);
      return state;
    } catch (error: any) {
      return reply.status(500).send({ error: error.message });
    }
  });

  fastify.post('/pipeline/advance', { preHandler: [authGuard] }, async (request, reply) => {
    const { projectId, userInput } = request.body as { projectId: string; userInput?: string };
    const userId = request.user!.id;

    if (!projectId) {
      return reply.status(400).send({ error: 'Project ID is required' });
    }

    try {
      const state = await kindlePipeline.advancePipeline(projectId, userId, userInput);
      return state;
    } catch (error: any) {
      return reply.status(error.message === 'Unauthorized access to project' ? 403 : 500).send({ error: error.message });
    }
  });

  fastify.get('/pipeline/:projectId/state', { preHandler: [authGuard] }, async (request, reply) => {
    const { projectId } = request.params as { projectId: string };
    const userId = request.user!.id;

    try {
      const state = await kindlePipeline.getProjectState(projectId, userId);
      if (!state) return reply.status(404).send({ error: 'Project not found' });
      return state;
    } catch (error: any) {
      return reply.status(error.message === 'Unauthorized access to project' ? 403 : 500).send({ error: error.message });
    }
  });
}
