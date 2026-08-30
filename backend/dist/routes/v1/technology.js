import { technologyAgent } from '../../services/ai/technology.agent.js';
export default async function technologyRoutes(fastify) {
    fastify.post('/technology/recommend', async (request, reply) => {
        const techRequest = request.body;
        if (!techRequest.requirements || !techRequest.platforms) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Requirements and platforms are required',
            });
        }
        try {
            const result = await technologyAgent.recommendStack(techRequest);
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
