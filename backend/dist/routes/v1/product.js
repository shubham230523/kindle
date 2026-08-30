"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = productRoutes;
const product_agent_js_1 = require("../../services/ai/product.agent.js");
async function productRoutes(fastify) {
    fastify.post('/product/generate', async (request, reply) => {
        const productRequest = request.body;
        if (!productRequest.discoveryResult) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Discovery result is required',
            });
        }
        try {
            const result = await product_agent_js_1.productAgent.generateProductSummary(productRequest);
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
