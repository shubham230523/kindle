import { FastifyInstance } from 'fastify';
import { codingAgent } from '../../services/ai/coding.agent.js';
import { codeChangeService } from '../../services/workspace/code-change.service.js';
import { storageService } from '../../services/storage/storage.service.js';
import { ProjectState } from '../../models/pipeline.js';
import { CodingRequest, FileModification } from '../../models/coding.js';
import { authGuard } from '../../plugins/auth-guard.js';

export default async function codingRoutes(fastify: FastifyInstance) {

  async function checkOwnership(projectId: string, userId: string) {
    const project = await storageService.load<ProjectState>('projects', projectId);
    if (!project) throw new Error('Project not found');
    if (project.userId !== userId) throw new Error('Unauthorized');
  }

  fastify.post('/coding/execute', { preHandler: [authGuard] }, async (request, reply) => {
    const codingRequest = request.body as CodingRequest;
    const userId = request.user!.id;

    if (!codingRequest.projectId || !codingRequest.task || !codingRequest.architecture) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Project ID, Task, and Architecture are required',
      });
    }

    try {
      await checkOwnership(codingRequest.projectId, userId);
      const result = await codingAgent.executeTask(codingRequest);
      return result;
    } catch (error: any) {
      return reply.status(error.message === 'Unauthorized' ? 403 : 500).send({
        error: error.message,
      });
    }
  });

  fastify.post('/coding/apply', { preHandler: [authGuard] }, async (request, reply) => {
    const { projectId, changes, explanation } = request.body as {
      projectId: string;
      changes: FileModification[];
      explanation: string;
    };
    const userId = request.user!.id;

    if (!projectId || !changes) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Project ID and changes are required',
      });
    }

    try {
      await checkOwnership(projectId, userId);
      const checkpointId = await codeChangeService.applyChanges(projectId, changes, explanation);
      return {
        message: 'Changes applied successfully',
        checkpointId
      };
    } catch (error: any) {
      return reply.status(error.message === 'Unauthorized' ? 403 : 500).send({
        error: error.message,
      });
    }
  });

  fastify.post('/coding/rollback', { preHandler: [authGuard] }, async (request, reply) => {
    const { projectId, checkpointId } = request.body as {
      projectId: string;
      checkpointId: string;
    };
    const userId = request.user!.id;

    if (!projectId || !checkpointId) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Project ID and Checkpoint ID are required',
      });
    }

    try {
      await checkOwnership(projectId, userId);
      await codeChangeService.rollbackToCheckpoint(projectId, checkpointId);
      return { message: 'Rollback successful' };
    } catch (error: any) {
      return reply.status(error.message === 'Unauthorized' ? 403 : 500).send({
        error: error.message,
      });
    }
  });

  fastify.get('/coding/checkpoints/:projectId', { preHandler: [authGuard] }, async (request, reply) => {
    const { projectId } = request.params as { projectId: string };
    const userId = request.user!.id;

    try {
      await checkOwnership(projectId, userId);
      const checkpoints = await codeChangeService.listCheckpoints(projectId);
      return { checkpoints };
    } catch (error: any) {
      return reply.status(error.message === 'Unauthorized' ? 403 : 500).send({
        error: error.message,
      });
    }
  });
}
