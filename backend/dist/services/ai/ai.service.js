import { AiError } from '../../models/ai.js';
import { OllamaProvider } from './ollama.provider.js';
import { OpenRouterProvider } from './openrouter.provider.js';
import { SimulationProvider } from './simulation.provider.js';
import { LocalLlamaProvider } from './local.provider.js';
import { env } from '../../config/env.js';
import { promises as fs } from 'fs';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';
const __dirname = path.dirname(fileURLToPath(import.meta.url));
export class AiService {
    providers = new Map();
    defaultProvider = 'openrouter';
    cacheDir;
    constructor() {
        this.registerProvider(new OllamaProvider());
        this.registerProvider(new OpenRouterProvider());
        this.registerProvider(new SimulationProvider());
        this.registerProvider(new LocalLlamaProvider());
        // Cache is located in the backend root
        this.cacheDir = path.resolve(__dirname, '../../../../.cache/ai');
    }
    registerProvider(provider) {
        this.providers.set(provider.name, provider);
    }
    async chat(request, onChunk, providerName) {
        // Check Cache first if enabled and NOT in simulation mode
        if (env.ENABLE_AI_CACHE && !env.isSimulation) {
            const cachedResponse = await this.getCachedResponse(request);
            if (cachedResponse) {
                console.log('[AI_SERVICE] 📦 Serving response from CACHE');
                return cachedResponse;
            }
        }
        const isSimulation = env.isSimulation;
        // Determine provider: Explicitly requested > Local (if path set) > Simulation > Default
        let name = providerName || this.defaultProvider;
        if (providerName) {
            name = providerName;
        }
        else if (env.LOCAL_MODEL_PATH && !providerName) {
            name = 'local';
        }
        else if (isSimulation) {
            name = 'simulation';
        }
        if (isSimulation && name === 'simulation') {
            // Don't log "REDIRECTING TO SIMULATION" if it's actually just being used as a fallback for missing keys
            // while delegation is handled at the Agent layer.
            const taskMatch = request.messages.find(m => m.role === 'user')?.content.match(/TASK: (.*)/);
            if (taskMatch) {
                console.log(`[AI_SERVICE] 📝 Processing task: ${taskMatch[1]}`);
            }
        }
        const provider = this.providers.get(name);
        if (!provider) {
            throw new AiError(`AI Provider "${name}" not found`, 404);
        }
        const response = await provider.chat(request, onChunk);
        // Save to cache if enabled and successful
        if (env.ENABLE_AI_CACHE && !env.isSimulation) {
            await this.saveToCache(request, response);
        }
        return response;
    }
    async getCachedResponse(request) {
        try {
            const hash = this.generateHash(request);
            const filePath = path.join(this.cacheDir, `${hash}.json`);
            const data = await fs.readFile(filePath, 'utf-8');
            return JSON.parse(data);
        }
        catch {
            return null;
        }
    }
    async saveToCache(request, response) {
        try {
            await fs.mkdir(this.cacheDir, { recursive: true });
            const hash = this.generateHash(request);
            const filePath = path.join(this.cacheDir, `${hash}.json`);
            await fs.writeFile(filePath, JSON.stringify(response, null, 2));
        }
        catch (err) {
            console.error('[AI_SERVICE] Failed to save cache:', err);
        }
    }
    generateHash(request) {
        const data = JSON.stringify(request.messages) + request.model + (request.temperature || 0);
        return crypto.createHash('md5').update(data).digest('hex');
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
