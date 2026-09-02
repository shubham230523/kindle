import fastify from 'fastify';
import cors from '@fastify/cors';
import websocket from '@fastify/websocket';
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
import authRoutes from './routes/v1/auth.js';
import userRoutes from './routes/v1/users.js';
import errorHandler from './plugins/error-handler.js';
import { workspaceService } from './services/workspace/workspace.service.js';
import { storageService } from './services/storage/storage.service.js';
import { socketService } from './services/workspace/socket.service.js';

export async function buildApp() {
  // Initialize Workspace & Storage
  await workspaceService.initialize();
  await storageService.initialize();

  const app = fastify({
    requestTimeout: 600000, // 10 minutes
    connectionTimeout: 600000, // 10 minutes
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
  await app.register(websocket);
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
  await app.register(authRoutes, { prefix: '/api/v1' });
  await app.register(userRoutes, { prefix: '/api/v1' });

  // WebSocket Route
  app.get('/ws/:projectId', { websocket: true }, (connection, req) => {
    const { projectId } = req.params as { projectId: string };
    socketService.addConnection(projectId, connection);
    app.log.info(`WebSocket connected for project: \${projectId}`);
  });

  return app;
}
