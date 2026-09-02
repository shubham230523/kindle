import { FastifyInstance } from 'fastify';
import { codingAgent } from '../../services/ai/coding.agent.js';
import { codeChangeService } from '../../services/workspace/code-change.service.js';
import { storageService } from '../../services/storage/storage.service.js';
import { ProjectState } from '../../models/pipeline.js';
import { CodingRequest, FileModification } from '../../models/coding.js';
import { authGuard } from '../../plugins/auth-guard.js';
import { env } from '../../config/env.js';

export default async function codingRoutes(fastify: FastifyInstance) {

  async function checkOwnership(projectId: string, userId: string) {
    const project = await storageService.load<ProjectState>('projects', projectId);

    if (!project) {
      if (env.NODE_ENV === 'development') {
        // In dev, allow processing even if project metadata is missing from DB
        return;
      }
      const error: any = new Error('Project not found');
      error.statusCode = 404;
      throw error;
    }

    if (project.userId !== userId && env.NODE_ENV !== 'development') {
      const error: any = new Error('Unauthorized');
      error.statusCode = 403;
      throw error;
    }
  }

  fastify.post('/coding/execute', { preHandler: [authGuard] }, async (request, reply) => {
    const codingRequest = request.body as CodingRequest;
    const userId = request.user!.id;

    if (!codingRequest.projectId || !codingRequest.task || !codingRequest.architecture) {
      const missing = [];
      if (!codingRequest.projectId) missing.push('projectId');
      if (!codingRequest.task) missing.push('task');
      if (!codingRequest.architecture) missing.push('architecture');

      return reply.status(400).send({
        error: 'Bad Request',
        message: `Missing required fields: ${missing.join(', ')}`,
      });
    }

    try {
      await checkOwnership(codingRequest.projectId, userId);
      const result = await codingAgent.executeTask(codingRequest);
      return result;
    } catch (error: any) {
      const statusCode = error.statusCode || 500;
      return reply.status(statusCode).send({
        error: error.name || 'CodingError',
        message: error.message,
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
