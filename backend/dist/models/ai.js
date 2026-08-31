export class AiError extends Error {
    statusCode;
    provider;
    code;
    constructor(message, statusCode = 500, provider = 'unknown', code = 'AI_GENERAL_ERROR') {
        super(message);
        this.statusCode = statusCode;
        this.provider = provider;
        this.code = code;
        this.name = 'AiError';
    }
}
