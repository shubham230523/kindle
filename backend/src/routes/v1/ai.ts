import { FastifyInstance } from 'fastify';
import { aiService } from '../../services/ai/ai.service.js';
import { AiChatRequest } from '../../models/ai.js';

export default async function aiRoutes(fastify: FastifyInstance) {
  fastify.post('/ai/chat', async (request, reply) => {
    const chatRequest = request.body as AiChatRequest;

    if (!chatRequest.messages || !Array.isArray(chatRequest.messages)) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Messages array is required',
      });
    }

    try {
      const response = await aiService.chat(chatRequest);
      return response;
    } catch (error: any) {
      const statusCode = error.statusCode || 500;
      return reply.status(statusCode).send({
        error: error.name || 'AI Error',
        message: error.message,
        provider: error.provider,
      });
    }
  });
}
