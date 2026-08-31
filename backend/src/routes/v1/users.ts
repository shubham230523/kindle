import { FastifyInstance } from 'fastify';
import { storageService } from '../../services/storage/storage.service.js';
import { User } from '../../models/user.js';

export default async function userRoutes(fastify: FastifyInstance) {
  fastify.post('/users', async (request, reply) => {
    const user = request.body as User;

    if (!user.id || !user.email) {
      return reply.status(400).send({ error: 'ID and Email are required' });
    }

    try {
      await storageService.save('users', user.id, user);
      return { message: 'User saved successfully', user };
    } catch (error: any) {
      return reply.status(500).send({ error: error.message });
    }
  });

  fastify.get('/users/:id', async (request, reply) => {
    const { id } = request.params as { id: string };

    try {
      const user = await storageService.load<User>('users', id);
      if (!user) return reply.status(404).send({ error: 'User not found' });
      return user;
    } catch (error: any) {
      return reply.status(500).send({ error: error.message });
    }
  });
}
