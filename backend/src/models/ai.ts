export interface AiChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
  reasoning_details?: string;
}

export interface AiChatRequest {
  messages: AiChatMessage[];
  temperature?: number;
  maxTokens?: number;
}

export interface AiChatResponse {
  content: string;
  reasoningDetails?: string;
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
    public readonly provider: string = 'unknown',
    public readonly code: string = 'AI_GENERAL_ERROR'
  ) {
    super(message);
    this.name = 'AiError';
  }
}
