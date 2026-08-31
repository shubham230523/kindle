import { FastifyInstance } from 'fastify';
import { authService } from '../../services/auth/auth.service.js';

export default async function authRoutes(fastify: FastifyInstance) {

  fastify.post('/auth/signup', async (request, reply) => {
    const { email, name } = request.body as { email: string; name: string };

    if (!email) {
      return reply.status(400).send({ error: 'Email is required' });
    }

    try {
      const existingUser = await authService.findUserByEmail(email);
      if (existingUser) {
        return reply.status(409).send({ error: 'User already exists' });
      }

      const user = await authService.createUser({ email, name });
      return {
        token: user.id, // Simulated JWT
        user,
      };
    } catch (error: any) {
      return reply.status(500).send({ error: error.message });
    }
  });

  fastify.post('/auth/login', async (request, reply) => {
    const { email } = request.body as { email: string };

    if (!email) {
      return reply.status(400).send({ error: 'Email is required' });
    }

    try {
      const user = await authService.findUserByEmail(email);
      if (!user) {
        return reply.status(401).send({ error: 'Invalid credentials' });
      }

      return {
        token: user.id, // Simulated JWT
        user,
      };
    } catch (error: any) {
      return reply.status(500).send({ error: error.message });
    }
  });
}
