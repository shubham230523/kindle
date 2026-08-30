"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiError = void 0;
class AiError extends Error {
    statusCode;
    provider;
    constructor(message, statusCode = 500, provider = 'unknown') {
        super(message);
        this.statusCode = statusCode;
        this.provider = provider;
        this.name = 'AiError';
    }
}
exports.AiError = AiError;
