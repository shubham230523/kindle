import { FastifyInstance } from 'fastify';
import { codingAgent } from '../../services/ai/coding.agent.js';
import { CodingRequest } from '../../models/coding.js';

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
}
