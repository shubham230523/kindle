import { AiChatRequest, AiChatResponse } from '../../models/ai.js';

export interface AiProvider {
  name: string;
  chat(request: AiChatRequest, onChunk?: (chunk: string) => void): Promise<AiChatResponse>;
}
