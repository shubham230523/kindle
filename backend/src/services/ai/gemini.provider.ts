import { AiChatRequest, AiChatResponse, AiError } from '../../models/ai.js';
import { AiProvider } from './ai-provider.interface.js';
import { env } from '../../config/env.js';

export class GeminiProvider implements AiProvider {
  public readonly name = 'gemini';

  async chat(request: AiChatRequest, onChunk?: (chunk: string) => void): Promise<AiChatResponse> {
    try {
      if (!env.GEMINI_API_KEY) {
        throw new AiError('GEMINI_API_KEY is not configured in environment', 500, this.name, 'CONFIG_ERROR');
      }

      // Try GoogleGenAI SDK dynamically if available
      try {
        const { GoogleGenAI } = await import('@google/genai');
        const client = new GoogleGenAI({ apiKey: env.GEMINI_API_KEY });

        const systemMessage = request.messages.find(m => m.role === 'system')?.content;
        const userMessages = request.messages.filter(m => m.role !== 'system');

        const contents: any[] = userMessages.map(m => ({
          role: m.role === 'assistant' ? 'model' : 'user',
          parts: [{ text: m.content }]
        }));

        if (contents.length === 0) {
          contents.push({ role: 'user', parts: [{ text: '' }] });
        }

        const model = env.GEMINI_MODEL || 'gemini-2.5-flash';

        if (onChunk) {
          const responseStream = await client.models.generateContentStream({
            model,
            systemInstruction: systemMessage || undefined,
            contents,
            config: {
              temperature: request.temperature ?? 0.2,
              maxOutputTokens: request.maxTokens || 16384,
              responseMimeType: 'application/json',
            }
          });

          let fullContent = '';
          for await (const chunk of responseStream) {
            const text = chunk.text;
            if (text) {
              fullContent += text;
              onChunk(text);
            }
          }

          return {
            content: fullContent,
            provider: this.name,
            model,
          };
        } else {
          const response = await client.models.generateContent({
            model,
            systemInstruction: systemMessage || undefined,
            contents,
            config: {
              temperature: request.temperature ?? 0.2,
              maxOutputTokens: request.maxTokens || 16384,
              responseMimeType: 'application/json',
            }
          });

          return {
            content: response.text?.trim() || '',
            provider: this.name,
            model,
          };
        }
      } catch (sdkError: any) {
        // Fall back to direct REST API if SDK is not installed or fails
        return await this.chatViaRest(request, onChunk);
      }
    } catch (error: any) {
      if (error instanceof AiError) throw error;
      throw new AiError(`Gemini Error: ${error.message}`, 500, this.name);
    }
  }

  private async chatViaRest(request: AiChatRequest, onChunk?: (chunk: string) => void): Promise<AiChatResponse> {
    const model = env.GEMINI_MODEL || 'gemini-2.5-flash';
    const apiKey = env.GEMINI_API_KEY;

    const systemMessage = request.messages.find(m => m.role === 'system')?.content;
    const contents = request.messages
      .filter(m => m.role !== 'system')
      .map(m => ({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: m.content }]
      }));

    if (contents.length === 0) {
      contents.push({ role: 'user', parts: [{ text: '' }] });
    }

    const payload: any = {
      contents,
      generationConfig: {
        temperature: request.temperature ?? 0.2,
        maxOutputTokens: request.maxTokens || 16384,
        responseMimeType: 'application/json',
      }
    };

    if (systemMessage) {
      payload.systemInstruction = {
        parts: [{ text: systemMessage }]
      };
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new AiError(
        `Gemini API Error (${response.status}): ${JSON.stringify(errorData.error || errorData)}`,
        response.status,
        this.name,
        'AI_PROVIDER_ERROR'
      );
    }

    const data = await response.json();
    const content = data.candidates?.[0]?.content?.parts?.map((p: any) => p.text).join('') || '';

    if (onChunk && content) {
      onChunk(content);
    }

    return {
      content,
      usage: {
        promptTokens: data.usageMetadata?.promptTokenCount || 0,
        completionTokens: data.usageMetadata?.candidatesTokenCount || 0,
        totalTokens: data.usageMetadata?.totalTokenCount || 0,
      },
      provider: this.name,
      model,
    };
  }
}
