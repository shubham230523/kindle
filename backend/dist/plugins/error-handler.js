"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const fastify_plugin_1 = __importDefault(require("fastify-plugin"));
const errorHandler = async (fastify) => {
    fastify.setErrorHandler((error, request, reply) => {
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
exports.default = (0, fastify_plugin_1.default)(errorHandler);
