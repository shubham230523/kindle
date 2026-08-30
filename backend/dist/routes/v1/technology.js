"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = technologyRoutes;
const technology_agent_js_1 = require("../../services/ai/technology.agent.js");
async function technologyRoutes(fastify) {
    fastify.post('/technology/recommend', async (request, reply) => {
        const techRequest = request.body;
        if (!techRequest.requirements || !techRequest.platforms) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Requirements and platforms are required',
            });
        }
        try {
            const result = await technology_agent_js_1.technologyAgent.recommendStack(techRequest);
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
