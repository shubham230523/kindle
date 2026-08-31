import { workspaceService } from '../../services/workspace/workspace.service.js';
import { storageService } from '../../services/storage/storage.service.js';
import { authGuard } from '../../plugins/auth-guard.js';
export default async function projectRoutes(fastify) {
    async function checkOwnership(projectId, userId) {
        const project = await storageService.load('projects', projectId);
        if (!project)
            throw new Error('Project not found');
        if (project.userId !== userId)
            throw new Error('Unauthorized');
    }
    fastify.post('/projects', { preHandler: [authGuard] }, async (request, reply) => {
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
    fastify.get('/projects/:id/files', { preHandler: [authGuard] }, async (request, reply) => {
        const { id } = request.params;
        const userId = request.user.id;
        try {
            await checkOwnership(id, userId);
            const files = await workspaceService.listProjectFiles(id);
            return { files };
        }
        catch (error) {
            return reply.status(error.message === 'Unauthorized' ? 403 : (error.message === 'Project not found' ? 404 : 500)).send({
                error: error.message,
            });
        }
    });
    fastify.get('/projects/:id/files/content', { preHandler: [authGuard] }, async (request, reply) => {
        const { id } = request.params;
        const { path } = request.query;
        const userId = request.user.id;
        if (!path) {
            return reply.status(400).send({
                error: 'Bad Request',
                message: 'File path is required',
            });
        }
        try {
            await checkOwnership(id, userId);
            const content = await workspaceService.readSourceFile(id, path);
            return { content };
        }
        catch (error) {
            return reply.status(error.message === 'Unauthorized' ? 403 : (error.message === 'Project not found' ? 404 : 500)).send({
                error: error.message,
            });
        }
    });
}
