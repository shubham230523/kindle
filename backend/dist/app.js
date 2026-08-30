"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildApp = buildApp;
const fastify_1 = __importDefault(require("fastify"));
const cors_1 = __importDefault(require("@fastify/cors"));
const health_js_1 = __importDefault(require("./routes/v1/health.js"));
const ai_js_1 = __importDefault(require("./routes/v1/ai.js"));
const discovery_js_1 = __importDefault(require("./routes/v1/discovery.js"));
const product_js_1 = __importDefault(require("./routes/v1/product.js"));
const error_handler_js_1 = __importDefault(require("./plugins/error-handler.js"));
async function buildApp() {
    const app = (0, fastify_1.default)({
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
    await app.register(cors_1.default);
    await app.register(error_handler_js_1.default);
    // Routes
    await app.register(health_js_1.default, { prefix: '/api/v1' });
    await app.register(ai_js_1.default, { prefix: '/api/v1' });
    await app.register(discovery_js_1.default, { prefix: '/api/v1' });
    await app.register(product_js_1.default, { prefix: '/api/v1' });
    return app;
}
