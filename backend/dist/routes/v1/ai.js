import { aiService } from '../../services/ai/ai.service.js';
export default async function aiRoutes(fastify) {
    fastify.post('/ai/chat', async (request, reply) => {
        const chatRequest = request.body;
        if (!chatRequest.messages || !Array.isArray(chatRequest.messages)) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Messages array is required',
            });
        }
        try {
            const response = await aiService.chat(chatRequest);
            return response;
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            return reply.status(statusCode).send({
                error: error.name || 'AI Error',
                message: error.message,
                provider: error.provider,
            });
        }
    });
}
