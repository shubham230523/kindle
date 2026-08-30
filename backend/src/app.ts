import fastify from 'fastify';
import cors from '@fastify/cors';
import healthRoutes from './routes/v1/health.js';
import aiRoutes from './routes/v1/ai.js';
import errorHandler from './plugins/error-handler.js';

export async function buildApp() {
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

  return app;
}
