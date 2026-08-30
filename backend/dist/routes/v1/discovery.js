import { discoveryAgent } from '../../services/ai/discovery.agent.js';
export default async function discoveryRoutes(fastify) {
    fastify.post('/discovery/process', async (request, reply) => {
        const { idea, previousHistory } = request.body;
        if (!idea) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Application idea is required',
            });
        }
        try {
            const history = previousHistory || [];
            const result = await discoveryAgent.processIdea(idea, history);
            return result;
        }
        catch (error) {
            fastify.log.error(error);
            return reply.status(500).send({
                error: 'Internal Server Error',
                message: error.message,
            });
        }
    });
}
