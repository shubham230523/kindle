import { AiError } from '../../models/ai.js';
import { OllamaProvider } from './ollama.provider.js';
import { OpenRouterProvider } from './openrouter.provider.js';
export class AiService {
    providers = new Map();
    defaultProvider = 'openrouter';
    constructor() {
        this.registerProvider(new OllamaProvider());
        this.registerProvider(new OpenRouterProvider());
    }
    registerProvider(provider) {
        this.providers.set(provider.name, provider);
    }
    async chat(request, onChunk, providerName) {
        const name = providerName || this.defaultProvider;
        const provider = this.providers.get(name);
        if (!provider) {
            throw new AiError(`AI Provider "${name}" not found`, 404);
        }
        return provider.chat(request, onChunk);
    }
    setDefaultProvider(name) {
        if (!this.providers.has(name)) {
            throw new AiError(`AI Provider "${name}" not found`, 404);
        }
        this.defaultProvider = name;
    }
}
// Export a singleton instance
export const aiService = new AiService();
