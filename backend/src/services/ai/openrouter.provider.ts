import axios, { AxiosInstance } from 'axios';
import { AiChatRequest, AiChatResponse, AiError } from '../../models/ai.js';
import { AiProvider } from './ai-provider.interface.js';
import { env } from '../../config/env.js';

export class OpenRouterProvider implements AiProvider {
  public readonly name = 'openrouter';
  private readonly client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: 'https://openrouter.ai/api/v1',
      headers: {
        'Authorization': `Bearer ${env.OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
      },
      timeout: 60000, // 60 seconds
    });
  }

  async chat(request: AiChatRequest): Promise<AiChatResponse> {
    try {
      const response = await this.client.post('/chat/completions', {
        model: env.OPENROUTER_MODEL,
        messages: request.messages.map(msg => ({
          role: msg.role,
          content: msg.content,
          reasoning_details: msg.reasoning_details,
        })),
        temperature: request.temperature ?? 0.3,
        max_tokens: request.maxTokens || 4096,
        reasoning: { enabled: true },
      });

      if (!response.data || !response.data.choices || response.data.choices.length === 0) {
        throw new Error('OpenRouter returned an empty response.');
      }

      const { choices, usage } = response.data;
      const message = choices[0].message;

      return {
        content: message.content,
        reasoningDetails: message.reasoning_details,
        usage: {
          promptTokens: usage?.prompt_tokens || 0,
          completionTokens: usage?.completion_tokens || 0,
          totalTokens: usage?.total_tokens || 0,
        },
        provider: this.name,
        model: env.OPENROUTER_MODEL,
      };
    } catch (error: any) {
      if (axios.isAxiosError(error)) {
        throw new AiError(
          `OpenRouter API Error: ${error.response?.data?.error?.message || error.message}`,
          error.response?.status || 500,
          this.name,
          'AI_PROVIDER_ERROR'
        );
      }
      throw new AiError(error.message, 500, this.name);
    }
  }
}
