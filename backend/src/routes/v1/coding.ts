import { FastifyInstance } from 'fastify';
import { codingAgent } from '../../services/ai/coding.agent.js';
import { codeChangeService } from '../../services/workspace/code-change.service.js';
import { CodingRequest, FileModification } from '../../models/coding.js';

export default async function codingRoutes(fastify: FastifyInstance) {
  fastify.post('/coding/execute', async (request, reply) => {
    const codingRequest = request.body as CodingRequest;

    if (!codingRequest.projectId || !codingRequest.task || !codingRequest.architecture) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Project ID, Task, and Architecture are required',
      });
    }

    try {
      const result = await codingAgent.executeTask(codingRequest);
      return result;
    } catch (error: any) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: 'Internal Server Error',
        message: error.message,
      });
    }
  });

  fastify.post('/coding/apply', async (request, reply) => {
    const { projectId, changes, explanation } = request.body as {
      projectId: string;
      changes: FileModification[];
      explanation: string;
    };

    if (!projectId || !changes) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Project ID and changes are required',
      });
    }

    try {
      const checkpointId = await codeChangeService.applyChanges(projectId, changes, explanation);
      return {
        message: 'Changes applied successfully',
        checkpointId
      };
    } catch (error: any) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: 'Application Error',
        message: error.message,
      });
    }
  });

  fastify.post('/coding/rollback', async (request, reply) => {
    const { projectId, checkpointId } = request.body as {
      projectId: string;
      checkpointId: string;
    };

    if (!projectId || !checkpointId) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Project ID and Checkpoint ID are required',
      });
    }

    try {
      await codeChangeService.rollbackToCheckpoint(projectId, checkpointId);
      return { message: 'Rollback successful' };
    } catch (error: any) {
      return reply.status(500).send({
        error: 'Rollback Error',
        message: error.message,
      });
    }
  });

  fastify.get('/coding/checkpoints/:projectId', async (request, reply) => {
    const { projectId } = request.params as { projectId: string };

    try {
      const checkpoints = await codeChangeService.listCheckpoints(projectId);
      return { checkpoints };
    } catch (error: any) {
      return reply.status(500).send({
        error: 'Internal Server Error',
        message: error.message,
      });
    }
  });
}
