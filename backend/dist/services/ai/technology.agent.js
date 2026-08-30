import { aiService } from './ai.service.js';
import { AiError } from '../../models/ai.js';
export class TechnologyAgent {
    systemPrompt = `
    You are the Kindle Technology Agent. Your goal is to recommend the most suitable technology stack for a given application based on its requirements and target platforms.

    Guidelines:
    1. If the user provides a preferred technology, backend, or database, you MUST prioritize and use them in your recommendation unless they are technically impossible for the requested platforms.
    2. Consider the target platforms (Android, iOS, Web, Windows, macOS, Linux).
    3. Evaluate requirements (e.g., real-time, offline support, high performance, SEO).
    4. Provide clear reasoning and honest trade-offs for your recommendation.
    5. Suggest 1-2 viable alternatives.
    6. Recommend a modern, industry-standard backend and database that pairs well with the primary technology.

    OUTPUT FORMAT:
    You must output your response as a valid JSON object with the following structure:
    {
      "recommendedTech": "Primary framework/language",
      "alternatives": ["Alternative 1", "Alternative 2"],
      "reasoning": "Detailed explanation of why this stack was chosen",
      "tradeoffs": ["Trade-off 1", "Trade-off 2"],
      "recommendedBackend": "Backend technology",
      "recommendedDatabase": "Database technology",
      "confidence": 0.9
    }
  `;
    async recommendStack(request) {
        const userInput = `
      REQUIREMENTS: ${request.requirements.join(', ')}
      PLATFORMS: ${request.platforms.join(', ')}
      PREFERRED TECH: ${request.preferredTech || 'None'}
      PREFERRED BACKEND: ${request.preferredBackend || 'None'}
      PREFERRED DATABASE: ${request.preferredDatabase || 'None'}
    `;
        const messages = [
            { role: 'system', content: this.systemPrompt },
            { role: 'user', content: userInput }
        ];
        try {
            const response = await aiService.chat({
                messages,
                temperature: 0.2
            });
            try {
                const result = JSON.parse(response.content);
                return result;
            }
            catch (parseError) {
                const jsonMatch = response.content.match(/\{[\s\S]*\}/);
                if (jsonMatch) {
                    return JSON.parse(jsonMatch[0]);
                }
                throw new Error('AI failed to provide a structured technology recommendation');
            }
        }
        catch (error) {
            throw new AiError(`Technology Agent Error: ${error.message}`, 500, 'technology-agent');
        }
    }
}
export const technologyAgent = new TechnologyAgent();
