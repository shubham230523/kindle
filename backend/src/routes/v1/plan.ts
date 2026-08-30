import { FastifyInstance } from 'fastify';
import { planningAgent } from '../../services/ai/planning.agent.js';
import { PlanningRequest } from '../../models/plan.js';

export default async function planRoutes(fastify: FastifyInstance) {
  fastify.post('/plan/generate', async (request, reply) => {
    const planningRequest = request.body as PlanningRequest;

    if (!planningRequest.product || !planningRequest.architecture) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Product definition and architecture are required',
      });
    }

    try {
      const result = await planningAgent.generatePlan(planningRequest);
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
