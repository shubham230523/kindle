import { workspaceService } from '../../services/workspace/workspace.service.js';
export default async function projectRoutes(fastify) {
    fastify.post('/projects', async (request, reply) => {
        const metadata = request.body;
        if (!metadata.id || !metadata.name) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'Project ID and name are required',
            });
        }
        try {
            const projectPath = await workspaceService.createProjectWorkspace(metadata);
            return {
                message: 'Project workspace created successfully',
                id: metadata.id,
                path: projectPath,
            };
        }
        catch (error) {
            fastify.log.error(error);
            return reply.status(500).send({
                error: 'Internal Server Error',
                message: error.message,
            });
        }
    });
    fastify.get('/projects/:id/files', async (request, reply) => {
        const { id } = request.params;
        try {
            const files = await workspaceService.listProjectFiles(id);
            return { files };
        }
        catch (error) {
            fastify.log.error(error);
            return reply.status(500).send({
                error: 'Internal Server Error',
                message: error.message,
            });
        }
    });
    fastify.get('/projects/:id/files/content', async (request, reply) => {
        const { id } = request.params;
        const { path } = request.query;
        if (!path) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'File path is required',
            });
        }
        try {
            const content = await workspaceService.readSourceFile(id, path);
            return { content };
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
