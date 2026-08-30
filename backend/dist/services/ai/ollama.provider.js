"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OllamaProvider = void 0;
const axios_1 = __importDefault(require("axios"));
const ai_js_1 = require("../../models/ai.js");
const env_js_1 = require("../../config/env.js");
class OllamaProvider {
    name = 'ollama';
    client;
    constructor() {
        this.client = axios_1.default.create({
            baseURL: env_js_1.env.OLLAMA_API_URL,
            timeout: 30000, // 30 seconds
        });
    }
    async chat(request) {
        try {
            const response = await this.client.post('', {
                model: env_js_1.env.OLLAMA_MODEL,
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
                model: env_js_1.env.OLLAMA_MODEL,
            };
        }
        catch (error) {
            if (axios_1.default.isAxiosError(error)) {
                throw new ai_js_1.AiError(`Ollama API Error: ${error.response?.data?.error || error.message}`, error.response?.status || 500, this.name);
            }
            throw new ai_js_1.AiError(error.message, 500, this.name);
        }
    }
}
exports.OllamaProvider = OllamaProvider;
