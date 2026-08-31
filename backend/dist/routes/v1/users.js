import { storageService } from '../../services/storage/storage.service.js';
export default async function userRoutes(fastify) {
    fastify.post('/users', async (request, reply) => {
        const user = request.body;
        if (!user.id || !user.email) {
            return reply.status(400).send({ error: 'ID and Email are required' });
        }
        try {
            await storageService.save('users', user.id, user);
            return { message: 'User saved successfully', user };
        }
        catch (error) {
            return reply.status(500).send({ error: error.message });
        }
    });
    fastify.get('/users/:id', async (request, reply) => {
        const { id } = request.params;
        try {
            const user = await storageService.load('users', id);
            if (!user)
                return reply.status(404).send({ error: 'User not found' });
            return user;
        }
        catch (error) {
            return reply.status(500).send({ error: error.message });
        }
    });
}
