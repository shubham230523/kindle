import axios, { AxiosInstance } from 'axios';
import { AiChatRequest, AiChatResponse, AiError } from '../../models/ai.js';
import { AiProvider } from './ai-provider.interface.js';
import { env } from '../../config/env.js';

export class OllamaProvider implements AiProvider {
  public readonly name = 'ollama';
  private readonly client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: env.OLLAMA_API_URL,
      timeout: 30000, // 30 seconds
    });
  }

  async chat(request: AiChatRequest, onChunk?: (chunk: string) => void): Promise<AiChatResponse> {
    try {
      const response = await this.client.post('', {
        model: env.OLLAMA_MODEL,
        messages: request.messages,
        stream: false,
        options: {
          temperature: request.temperature,
          num_predict: request.maxTokens || 4096, // Increased default to prevent truncation
          num_ctx: 8192, // Ensure context window is large enough
        },
      });

      const { message, prompt_eval_count, eval_count } = response.data;

      if (!message || message.content === null || message.content === undefined) {
        throw new Error('Ollama returned empty or null content.');
      }

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
    } catch (error: any) {
      if (axios.isAxiosError(error)) {
        if (error.code === 'ECONNABORTED') {
          throw new AiError('Ollama API Timeout: The AI provider took too long to respond.', 408, this.name, 'AI_TIMEOUT');
        }
        if (error.code === 'ECONNREFUSED') {
          throw new AiError('Ollama API Connection Refused: Ensure the AI provider is running.', 503, this.name, 'AI_NETWORK_FAILURE');
        }
        throw new AiError(
          `Ollama API Error: ${error.response?.data?.error || error.message}`,
          error.response?.status || 500,
          this.name,
          'AI_PROVIDER_ERROR'
        );
      }
      throw new AiError(error.message, 500, this.name);
    }
  }
}
