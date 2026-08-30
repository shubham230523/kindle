import fastify from 'fastify';
import cors from '@fastify/cors';
import healthRoutes from './routes/v1/health.js';
import aiRoutes from './routes/v1/ai.js';
import discoveryRoutes from './routes/v1/discovery.js';
import productRoutes from './routes/v1/product.js';
import technologyRoutes from './routes/v1/technology.js';
import architectureRoutes from './routes/v1/architecture.js';
import planRoutes from './routes/v1/plan.js';
import projectRoutes from './routes/v1/projects.js';
import codingRoutes from './routes/v1/coding.js';
import developmentRoutes from './routes/v1/development.js';
import pipelineRoutes from './routes/v1/pipeline.js';
import errorHandler from './plugins/error-handler.js';
import { workspaceService } from './services/workspace/workspace.service.js';
export async function buildApp() {
    // Initialize Workspace Root
    await workspaceService.initialize();
    const app = fastify({
        logger: {
            transport: {
                target: 'pino-pretty',
                options: {
                    translateTime: 'HH:MM:ss Z',
                    ignore: 'pid,hostname',
                },
            },
        },
    });
    // Plugins
    await app.register(cors);
    await app.register(errorHandler);
    // Routes
    await app.register(healthRoutes, { prefix: '/api/v1' });
    await app.register(aiRoutes, { prefix: '/api/v1' });
    await app.register(discoveryRoutes, { prefix: '/api/v1' });
    await app.register(productRoutes, { prefix: '/api/v1' });
    await app.register(technologyRoutes, { prefix: '/api/v1' });
    await app.register(architectureRoutes, { prefix: '/api/v1' });
    await app.register(planRoutes, { prefix: '/api/v1' });
    await app.register(projectRoutes, { prefix: '/api/v1' });
    await app.register(codingRoutes, { prefix: '/api/v1' });
    await app.register(developmentRoutes, { prefix: '/api/v1' });
    await app.register(pipelineRoutes, { prefix: '/api/v1' });
    return app;
}
