import 'dotenv/config';
export const env = {
    NODE_ENV: process.env.NODE_ENV || 'development',
    PORT: parseInt(process.env.PORT || '3000', 10),
    HOST: process.env.HOST || '0.0.0.0',
    OLLAMA_API_URL: process.env.OLLAMA_API_URL || 'http://localhost:11434/api/chat',
    OLLAMA_MODEL: process.env.OLLAMA_MODEL || 'llama2',
    OPENROUTER_API_KEY: process.env.OPENROUTER_API_KEY || '',
    OPENROUTER_MODEL: process.env.OPENROUTER_MODEL || 'minimax/minimax-m3:free',
};
