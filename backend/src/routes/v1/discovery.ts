import { FastifyInstance } from 'fastify';
import { discoveryAgent } from '../../services/ai/discovery.agent.js';
import { DiscoveryRequest } from '../../models/discovery.js';

export default async function discoveryRoutes(fastify: FastifyInstance) {
  fastify.post('/discovery/process', async (request, reply) => {
    const { idea, previousHistory } = request.body as DiscoveryRequest;

    if (!idea) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Application idea is required',
      });
    }

    try {
      const history = previousHistory || [];
      const result = await discoveryAgent.processIdea(idea, history as any);
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
