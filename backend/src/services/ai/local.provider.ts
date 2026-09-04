import path from 'path';
import { getLlama, Llama, LlamaModel, LlamaContext, LlamaChatSession, LlamaContextSequence, ChatHistoryItem } from "node-llama-cpp";
import { AiChatRequest, AiChatResponse, AiError } from '../../models/ai.js';
import { AiProvider } from './ai-provider.interface.js';
import { env } from '../../config/env.js';

export class LocalLlamaProvider implements AiProvider {
  public readonly name = 'local';
  private llama: Llama | null = null;
  private model: LlamaModel | null = null;
  private context: LlamaContext | null = null;
  private sequence: LlamaContextSequence | null = null;
  private session: LlamaChatSession | null = null;

  async chat(request: AiChatRequest, onChunk?: (chunk: string) => void): Promise<AiChatResponse> {
    try {
      if (!env.LOCAL_MODEL_PATH) {
        throw new AiError('LOCAL_MODEL_PATH is not set in environment', 500, this.name, 'CONFIG_ERROR');
      }

      console.log(`[LOCAL_LLM] 🤖 Processing request with model: ${path.basename(env.LOCAL_MODEL_PATH)}`);
      await this.initialize();

      if (!this.session || !this.model) {
        throw new AiError('Failed to initialize local LLM session', 500, this.name, 'INIT_ERROR');
      }

      const systemMessage = request.messages.find(m => m.role === 'system');

      const otherMessages = request.messages.filter(m => m.role !== 'system');
      const lastMessage = otherMessages.pop();

      if (!lastMessage || lastMessage.role !== 'user') {
        throw new AiError('No user message found in request', 400, this.name, 'VALIDATION_ERROR');
      }

      console.log(`[LOCAL_LLM] 🔄 Setting chat history. Length: ${otherMessages.length}`);

      // Construct history in node-llama-cpp format
      const history: ChatHistoryItem[] = [];

      if (systemMessage) {
        history.push({ type: 'system', text: systemMessage.content });
      }

      for (const msg of otherMessages) {
        if (msg.role === 'user') {
          history.push({ type: 'user', text: msg.content });
        } else if (msg.role === 'assistant') {
          history.push({ type: 'model', response: [msg.content] });
        }
      }

      this.session.setChatHistory(history);

      console.log(`[LOCAL_LLM] 🧠 Thinking...`);
      let fullResponse = '';

      const response = await this.session.prompt(lastMessage.content, {
        onToken: (tokens) => {
          const chunk = this.model!.detokenize(tokens);
          fullResponse += chunk;
          if (onChunk) onChunk(chunk);
        },
        maxTokens: request.maxTokens || 4096,
        temperature: request.temperature || 0.2,
      });

      console.log(`[LOCAL_LLM] ✅ Response generated (${fullResponse.length} chars)`);

      return {
        content: response,
        usage: {
          promptTokens: 0,
          completionTokens: 0,
          totalTokens: 0,
        },
        provider: this.name,
        model: path.basename(env.LOCAL_MODEL_PATH),
      };
    } catch (error: any) {
      console.error('[LOCAL_LLM] ❌ Error:', error);
      throw new AiError(`Local LLM Error: ${error.message}`, 500, this.name, 'INFERENCE_ERROR');
    }
  }

  private async initialize() {
    if (this.session) return;

    try {
      console.log('[LOCAL_LLM] ⚙️ Initializing Llama (CPU Mode)...');
      this.llama = await getLlama({
        gpu: false
      });

      console.log(`[LOCAL_LLM] 📂 Loading model from ${env.LOCAL_MODEL_PATH}...`);
      this.model = await this.llama.loadModel({
        modelPath: env.LOCAL_MODEL_PATH,
        gpuLayers: 0
      });

      console.log('[LOCAL_LLM] 🧠 Creating context...');
      this.context = await this.model.createContext({
        threads: env.LOCAL_MODEL_THREADS
      });

      console.log('[LOCAL_LLM] 🎫 Reserving sequence...');
      this.sequence = this.context.getSequence();

      console.log('[LOCAL_LLM] 💬 Creating persistent session...');
      this.session = new LlamaChatSession({
        contextSequence: this.sequence
      });

      console.log('[LOCAL_LLM] ✨ Initialization complete.');

    } catch (error: any) {
      console.error('[LOCAL_LLM] ❌ Initialization failed:', error);
      throw new Error(`Initialization failed: ${error.message}`);
    }
  }
}
