import { FastifyInstance } from 'fastify';
import { productAgent } from '../../services/ai/product.agent.js';
import { ProductRequest } from '../../models/product.js';

export default async function productRoutes(fastify: FastifyInstance) {
  fastify.post('/product/generate', async (request, reply) => {
    const productRequest = request.body as ProductRequest;

    if (!productRequest.discoveryResult) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Discovery result is required',
      });
    }

    try {
      const result = await productAgent.generateProductSummary(productRequest);
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
