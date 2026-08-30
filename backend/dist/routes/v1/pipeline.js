import { kindlePipeline } from '../../services/workspace/pipeline.service.js';
export default async function pipelineRoutes(fastify) {
    fastify.post('/pipeline/init', async (request, reply) => {
        const { id, idea } = request.body;
        if (!id || !idea) {
            return reply.status(400).send({ error: 'Project ID and Idea are required' });
        }
        try {
            const state = await kindlePipeline.initializeProject(id, idea);
            return state;
        }
        catch (error) {
            return reply.status(500).send({ error: error.message });
        }
    });
    fastify.post('/pipeline/advance', async (request, reply) => {
        const { projectId, userInput } = request.body;
        if (!projectId) {
            return reply.status(400).send({ error: 'Project ID is required' });
        }
        try {
            const state = await kindlePipeline.advancePipeline(projectId, userInput);
            return state;
        }
        catch (error) {
            return reply.status(500).send({ error: error.message });
        }
    });
    fastify.get('/pipeline/:projectId/state', async (request, reply) => {
        const { projectId } = request.params;
        try {
            const state = await kindlePipeline.getProjectState(projectId);
            if (!state)
                return reply.status(404).send({ error: 'Project not found' });
            return state;
        }
        catch (error) {
            return reply.status(500).send({ error: error.message });
        }
    });
}
