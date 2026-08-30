import { FastifyInstance } from 'fastify';
import { technologyAgent } from '../../services/ai/technology.agent.js';
import { TechnologyRequest } from '../../models/technology.js';

export default async function technologyRoutes(fastify: FastifyInstance) {
  fastify.post('/technology/recommend', async (request, reply) => {
    const techRequest = request.body as TechnologyRequest;

    if (!techRequest.requirements || !techRequest.platforms) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Requirements and platforms are required',
      });
    }

    try {
      const result = await technologyAgent.recommendStack(techRequest);
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
