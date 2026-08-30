"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = discoveryRoutes;
const discovery_agent_js_1 = require("../../services/ai/discovery.agent.js");
async function discoveryRoutes(fastify) {
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
            const result = await discovery_agent_js_1.discoveryAgent.processIdea(idea, history);
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
