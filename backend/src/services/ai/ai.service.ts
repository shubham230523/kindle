import { AiChatRequest, AiChatResponse, AiError } from '../../models/ai.js';
import { AiProvider } from './ai-provider.interface.js';
import { OllamaProvider } from './ollama.provider.js';
import { OpenRouterProvider } from './openrouter.provider.js';

export class AiService {
  private providers: Map<string, AiProvider> = new Map();
  private defaultProvider: string = 'openrouter';

  constructor() {
    this.registerProvider(new OllamaProvider());
    this.registerProvider(new OpenRouterProvider());
  }

  registerProvider(provider: AiProvider) {
    this.providers.set(provider.name, provider);
  }

  async chat(request: AiChatRequest, onChunk?: (chunk: string) => void, providerName?: string): Promise<AiChatResponse> {
    const name = providerName || this.defaultProvider;
    const provider = this.providers.get(name);

    if (!provider) {
      throw new AiError(`AI Provider "${name}" not found`, 404);
    }

    return provider.chat(request, onChunk);
  }

  setDefaultProvider(name: string) {
    if (!this.providers.has(name)) {
      throw new AiError(`AI Provider "${name}" not found`, 404);
    }
    this.defaultProvider = name;
  }
}

// Export a singleton instance
export const aiService = new AiService();
