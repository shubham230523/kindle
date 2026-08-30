import { AiError } from '../../models/ai.js';
import { OllamaProvider } from './ollama.provider.js';
export class AiService {
    providers = new Map();
    defaultProvider = 'ollama';
    constructor() {
        this.registerProvider(new OllamaProvider());
    }
    registerProvider(provider) {
        this.providers.set(provider.name, provider);
    }
    async chat(request, providerName) {
        const name = providerName || this.defaultProvider;
        const provider = this.providers.get(name);
        if (!provider) {
            throw new AiError(`AI Provider "${name}" not found`, 404);
        }
        return provider.chat(request);
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
