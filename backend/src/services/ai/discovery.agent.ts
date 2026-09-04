import { aiService } from './ai.service.js';
import { AiChatMessage, AiError } from '../../models/ai.js';
import { DiscoveryResult } from '../../models/discovery.js';
import { extractJson } from './ai-utils.js';

export class DiscoveryAgent {
  private readonly systemPrompt = `
    You are the Kindle Discovery Agent. Your goal is to understand a user's application idea and help them refine it into a structured set of requirements.

    Responsibilities:
    1. Understand the high-level goal of the application.
    2. Identify missing technical or functional details.
    3. Ask exactly ONE clarification question at a time to keep the user focused.
    4. Maintain a summary of what has been discovered so far.
    5. Track confidence in the overall understanding (0.0 to 1.0).

    Guidelines:
    - Be professional, encouraging, and concise.
    - If the idea is very vague, ask about the target audience or the core problem it solves.
    - If the idea is clear but missing technical details (e.g., auth, platforms), ask about one of those.
    - Do not repeat questions.
    - IMPORTANT: Do not set isDiscoveryComplete to true until you have at least 3-4 distinct features and have confirmed the target platform and user needs. Even for simple apps like "calculators", ask if they need scientific mode, history, or specific UI themes.
    - When you have enough information to create a detailed roadmap (features, platforms, backend needs), set isDiscoveryComplete to true.

    OUTPUT FORMAT:
    You must output your response as a valid JSON object with the following structure:
    {
      "understandingSummary": "A concise summary of the app idea as understood so far",
      "currentQuestion": "The single most useful question to ask next (null if complete)",
      "discoveredRequirements": ["list", "of", "confirmed", "requirements"],
      "missingInformation": ["list", "of", "missing", "details"],
      "confidence": 0.8,
      "isDiscoveryComplete": false
    }

    CRITICAL: DO NOT output any text before or after the JSON object. Do not include markdown code blocks. Start your response with "{" and end with "}".
  `;

  async processIdea(idea: string, history: AiChatMessage[] = []): Promise<{ result: DiscoveryResult; reasoning?: string }> {
    // For smaller local models, we reinforce the JSON requirement in the user prompt
    const userPrompt = `${idea}\n\nIMPORTANT: Respond ONLY with the JSON object defined in the system prompt. No conversational text.`;

    const messages: AiChatMessage[] = [
      { role: 'system', content: this.systemPrompt },
      ...history,
      { role: 'user', content: userPrompt }
    ];

    try {
      const response = await aiService.chat({
        messages,
        temperature: 0.2
      });

      let result: DiscoveryResult;
      try {
        result = extractJson<DiscoveryResult>(response.content);
      } catch (e) {
        if (response.reasoning_details) {
          result = extractJson<DiscoveryResult>(response.reasoning_details);
        } else {
          throw e;
        }
      }

      return {
        result,
        reasoning: response.reasoning_details
      };
    } catch (error: any) {
      if (error instanceof AiError) throw error;
      throw new AiError(`Discovery Agent Error: ${error.message}`, 500, 'discovery-agent');
    }
  }
}

export const discoveryAgent = new DiscoveryAgent();
