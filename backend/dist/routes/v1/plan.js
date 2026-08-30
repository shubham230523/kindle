"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = planRoutes;
const planning_agent_js_1 = require("../../services/ai/planning.agent.js");
async function planRoutes(fastify) {
    fastify.post('/plan/generate', async (request, reply) => {
        const planningRequest = request.body;
        if (!planningRequest.product || !planningRequest.architecture) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Product definition and architecture are required',
            });
        }
        try {
            const result = await planning_agent_js_1.planningAgent.generatePlan(planningRequest);
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
