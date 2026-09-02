import { FastifyInstance } from 'fastify';
import { codingAgent } from '../../services/ai/coding.agent.js';
import { socketService } from '../../services/workspace/socket.service.js';
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
      return reply.status(400).send({ error: 'Missing required fields' });
    }

    try {
      await checkOwnership(codingRequest.projectId, userId);

      // Set headers for Server-Sent Events (SSE)
      reply.raw.setHeader('Content-Type', 'text/event-stream');
      reply.raw.setHeader('Cache-Control', 'no-cache');
      reply.raw.setHeader('Connection', 'keep-alive');
      reply.raw.setHeader('Access-Control-Allow-Origin', '*');

      const result = await codingAgent.executeTask(codingRequest, (chunk) => {
        // Stream chunks to the client
        const data = JSON.stringify({ type: 'chunk', content: chunk });
        reply.raw.write(`data: ${data}\n\n`);

        // Also keep emitting via WebSocket for other listeners
        socketService.emit(codingRequest.projectId, 'AGENT_STREAM_CHUNK', {
          taskId: codingRequest.task.id,
          chunk
        });
      });

      // Send the final result
      const finalData = JSON.stringify({ type: 'result', content: result });
      reply.raw.write(`data: ${finalData}\n\n`);
      reply.raw.end();

    } catch (error: any) {
      fastify.log.error(error);
      const errorData = JSON.stringify({ type: 'error', message: error.message });

      if (!reply.raw.writableEnded) {
        if (!reply.raw.headersSent) {
          reply.status(error.statusCode || 500).send({ error: error.message });
        } else {
          reply.raw.write(`data: ${errorData}\n\n`);
          reply.raw.end();
        }
      }
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
