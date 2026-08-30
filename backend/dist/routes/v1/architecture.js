"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = architectureRoutes;
const architecture_agent_js_1 = require("../../services/ai/architecture.agent.js");
async function architectureRoutes(fastify) {
    fastify.post('/architecture/generate', async (request, reply) => {
        const archRequest = request.body;
        if (!archRequest.technology || !archRequest.requirements) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Technology and requirements are required',
            });
        }
        try {
            const result = await architecture_agent_js_1.architectureAgent.generateBlueprint(archRequest);
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
