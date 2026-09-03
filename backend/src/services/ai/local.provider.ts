import path from 'path';
import { getLlama, Llama, LlamaModel, LlamaContext, LlamaChatSession } from "node-llama-cpp";
import { AiChatRequest, AiChatResponse, AiError } from '../../models/ai.js';
import { AiProvider } from './ai-provider.interface.js';
import { env } from '../../config/env.js';

export class LocalLlamaProvider implements AiProvider {
  public readonly name = 'local';
  private llama: Llama | null = null;
  private model: LlamaModel | null = null;
  private context: LlamaContext | null = null;
  private session: LlamaChatSession | null = null;

  async chat(request: AiChatRequest, onChunk?: (chunk: string) => void): Promise<AiChatResponse> {
    try {
      if (!env.LOCAL_MODEL_PATH) {
        throw new AiError('LOCAL_MODEL_PATH is not set in environment', 500, this.name, 'CONFIG_ERROR');
      }

      await this.initialize();

      const systemPrompt = request.messages.find(m => m.role === 'system')?.content || '';
      const userPrompt = request.messages.find(m => m.role === 'user')?.content || '';

      if (!this.session) {
        throw new AiError('Failed to initialize local LLM session', 500, this.name, 'INIT_ERROR');
      }

      let fullResponse = '';

      const response = await this.session.prompt(userPrompt, {
        onToken: (tokens) => {
          const chunk = this.model!.detokenize(tokens);
          fullResponse += chunk;
          if (onChunk) onChunk(chunk);
        },
        maxTokens: request.maxTokens || 2048,
        temperature: request.temperature || 0.2,
      });

      return {
        content: response,
        usage: {
          promptTokens: 0, // Simplified for mock usage tracking
          completionTokens: 0,
          totalTokens: 0,
        },
        provider: this.name,
        model: path.basename(env.LOCAL_MODEL_PATH),
      };
    } catch (error: any) {
      console.error('Local LLM Error:', error);
      throw new AiError(`Local LLM Error: ${error.message}`, 500, this.name, 'INFERENCE_ERROR');
    }
  }

  private async initialize() {
    if (this.session) return;

    try {
      this.llama = await getLlama();
      this.model = await this.llama.loadModel({
        modelPath: env.LOCAL_MODEL_PATH
      });

      this.context = await this.model.createContext({
        threads: env.LOCAL_MODEL_THREADS
      });

      this.session = new LlamaChatSession({
        contextSequence: this.context.getSequence()
      });
    } catch (error: any) {
      console.error('Failed to initialize Llama:', error);
      throw new Error(`Initialization failed: ${error.message}`);
    }
  }
}
