export interface AiChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

export interface AiChatRequest {
  messages: AiChatMessage[];
  temperature?: number;
  maxTokens?: number;
}

export interface AiChatResponse {
  content: string;
  usage?: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
  provider: string;
  model: string;
}

export class AiError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number = 500,
    public readonly provider: string = 'unknown'
  ) {
    super(message);
    this.name = 'AiError';
  }
}
