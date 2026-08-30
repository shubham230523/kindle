"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.aiService = exports.AiService = void 0;
const ai_js_1 = require("../../models/ai.js");
const ollama_provider_js_1 = require("./ollama.provider.js");
class AiService {
    providers = new Map();
    defaultProvider = 'ollama';
    constructor() {
        this.registerProvider(new ollama_provider_js_1.OllamaProvider());
    }
    registerProvider(provider) {
        this.providers.set(provider.name, provider);
    }
    async chat(request, providerName) {
        const name = providerName || this.defaultProvider;
        const provider = this.providers.get(name);
        if (!provider) {
            throw new ai_js_1.AiError(`AI Provider "${name}" not found`, 404);
        }
        return provider.chat(request);
    }
    setDefaultProvider(name) {
        if (!this.providers.has(name)) {
            throw new ai_js_1.AiError(`AI Provider "${name}" not found`, 404);
        }
        this.defaultProvider = name;
    }
}
exports.AiService = AiService;
// Export a singleton instance
exports.aiService = new AiService();
