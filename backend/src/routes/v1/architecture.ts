import { FastifyInstance } from 'fastify';
import { architectureAgent } from '../../services/ai/architecture.agent.js';
import { ArchitectureRequest } from '../../models/architecture.js';

export default async function architectureRoutes(fastify: FastifyInstance) {
  fastify.post('/architecture/generate', async (request, reply) => {
    const archRequest = request.body as ArchitectureRequest;

    if (!archRequest.technology || !archRequest.requirements) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Technology and requirements are required',
      });
    }

    try {
      const result = await architectureAgent.generateBlueprint(archRequest);
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
