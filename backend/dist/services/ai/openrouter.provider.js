import { AiError } from '../../models/ai.js';
import { env } from '../../config/env.js';
export class OpenRouterProvider {
    name = 'openrouter';
    async chat(request, onChunk) {
        try {
            const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${env.OPENROUTER_API_KEY}`,
                    'Content-Type': 'application/json',
                    'HTTP-Referer': 'https://kindle.ai', // Required by OpenRouter
                    'X-Title': 'Kindle AI IDE',
                },
                body: JSON.stringify({
                    model: env.OPENROUTER_MODEL,
                    messages: request.messages.map(msg => ({
                        role: msg.role,
                        content: msg.content,
                        reasoning_details: msg.reasoning_details,
                    })),
                    temperature: request.temperature ?? 0.3,
                    max_tokens: request.maxTokens || 16384,
                    stream: true, // Enable streaming
                    reasoning: request.reasoning !== false ? { enabled: true } : undefined,
                    response_format: { type: 'json_object' },
                }),
            });
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new AiError(`OpenRouter API Error: ${errorData.error?.message || response.statusText}`, response.status, this.name, 'AI_PROVIDER_ERROR');
            }
            if (!response.body) {
                throw new Error('OpenRouter returned an empty response body.');
            }
            const reader = response.body.getReader();
            const decoder = new TextDecoder();
            let fullContent = '';
            let fullReasoning = '';
            let usage = null;
            let lineBuffer = '';
            while (true) {
                const { done, value } = await reader.read();
                if (done)
                    break;
                const decoded = decoder.decode(value, { stream: true });
                lineBuffer += decoded;
                const lines = lineBuffer.split('\n');
                lineBuffer = lines.pop() || ''; // Keep the incomplete line in the buffer
                for (const line of lines) {
                    const trimmedLine = line.trim();
                    if (!trimmedLine)
                        continue;
                    if (trimmedLine.startsWith(':'))
                        continue; // Comment line
                    if (!trimmedLine.startsWith('data: ')) {
                        // Unexpected line format in stream, but we'll try to keep going
                        continue;
                    }
                    const dataStr = trimmedLine.slice(6).trim();
                    if (dataStr === '[DONE]')
                        continue;
                    try {
                        const data = JSON.parse(dataStr);
                        if (data.error) {
                            console.error('OpenRouter Stream Data Error:', data.error);
                            throw new Error(`OpenRouter Stream Error: ${data.error.message || JSON.stringify(data.error)}`);
                        }
                        if (data.choices && data.choices[0].delta) {
                            const delta = data.choices[0].delta;
                            if (delta.content) {
                                fullContent += delta.content;
                                if (onChunk)
                                    onChunk(delta.content);
                            }
                            if (delta.reasoning_details) {
                                fullReasoning += delta.reasoning_details;
                            }
                            if (delta.refusal) {
                                throw new Error(`OpenRouter Refusal: ${delta.refusal}`);
                            }
                        }
                        if (data.usage) {
                            usage = data.usage;
                        }
                    }
                    catch (e) {
                        // Partial JSON chunk or parse error, usually safe to ignore in SSE
                    }
                }
            }
            // Handle any remaining data in the buffer after the stream ends
            if (lineBuffer.trim().startsWith('data: ')) {
                const dataStr = lineBuffer.trim().slice(6).trim();
                if (dataStr !== '[DONE]') {
                    try {
                        const data = JSON.parse(dataStr);
                        if (data.choices && data.choices[0].delta?.content) {
                            fullContent += data.choices[0].delta.content;
                            if (onChunk)
                                onChunk(data.choices[0].delta.content);
                        }
                    }
                    catch (e) { }
                }
            }
            if (!fullContent && !fullReasoning) {
                throw new Error('OpenRouter returned null content. The model might have encountered an issue, a safety filter, or max tokens were exceeded during reasoning.');
            }
            return {
                content: fullContent,
                reasoning_details: fullReasoning || undefined,
                usage: {
                    promptTokens: usage?.prompt_tokens || 0,
                    completionTokens: usage?.completion_tokens || 0,
                    totalTokens: usage?.total_tokens || 0,
                },
                provider: this.name,
                model: env.OPENROUTER_MODEL,
            };
        }
        catch (error) {
            if (error instanceof AiError)
                throw error;
            throw new AiError(error.message, 500, this.name);
        }
    }
}
