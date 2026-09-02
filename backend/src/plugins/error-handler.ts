import { FastifyInstance, FastifyPluginAsync } from 'fastify';
import fp from 'fastify-plugin';

const errorHandler: FastifyPluginAsync = async (fastify: FastifyInstance) => {
  fastify.setErrorHandler((error: any, request, reply) => {
    fastify.log.error(error);

    if (error.validation) {
      reply.status(400).send({
        error: 'Bad Request',
        message: error.message,
      });
      return;
    }

    reply.status(error.statusCode || 500).send({
      error: error.name || 'Internal Server Error',
      message: error.message || 'Something went wrong on our side',
    });
  });
};

export default fp(errorHandler);
