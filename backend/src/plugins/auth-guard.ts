import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';

export async function authGuard(request: FastifyRequest, reply: FastifyReply) {
  const { env } = await import('../config/env.js');
  const authHeader = request.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    if (env.NODE_ENV === 'development') {
      // Provide a default dev user for testing
      request.user = { id: 'dev_user' };
      return;
    }
    return reply.status(401).send({
      error: 'Unauthorized',
      message: 'Missing or invalid authorization token',
    });
  }

  // For this implementation, we assume the token is the User ID (Simulated JWT)
  const token = authHeader.split(' ')[1];

  // In a real app, we would verify the JWT here
  // For now, we verify the user exists in storage
  try {
    const { storageService } = await import('../services/storage/storage.service.js');
    const user = await storageService.load<any>('users', token);

    if (!user) {
      return reply.status(401).send({
        error: 'Unauthorized',
        message: 'User not found',
      });
    }

    request.user = { id: user.id };
  } catch (error) {
    return reply.status(500).send({ error: 'Internal Server Error' });
  }
}
