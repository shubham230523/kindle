import axios from 'axios';
import { AiError } from '../../models/ai.js';
import { env } from '../../config/env.js';
export class OllamaProvider {
    name = 'ollama';
    client;
    constructor() {
        this.client = axios.create({
            baseURL: env.OLLAMA_API_URL,
            timeout: 30000, // 30 seconds
        });
    }
    async chat(request) {
        try {
            const response = await this.client.post('', {
                model: env.OLLAMA_MODEL,
                messages: request.messages,
                stream: false,
                options: {
                    temperature: request.temperature,
                    num_predict: request.maxTokens,
                },
            });
            const { message, prompt_eval_count, eval_count } = response.data;
            return {
                content: message.content,
                usage: {
                    promptTokens: prompt_eval_count || 0,
                    completionTokens: eval_count || 0,
                    totalTokens: (prompt_eval_count || 0) + (eval_count || 0),
                },
                provider: this.name,
                model: env.OLLAMA_MODEL,
            };
        }
        catch (error) {
            if (axios.isAxiosError(error)) {
                throw new AiError(`Ollama API Error: ${error.response?.data?.error || error.message}`, error.response?.status || 500, this.name);
            }
            throw new AiError(error.message, 500, this.name);
        }
    }
}
