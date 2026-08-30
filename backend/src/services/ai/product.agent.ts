import { aiService } from './ai.service.js';
import { AiChatMessage, AiError } from '../../models/ai.js';
import { ProductSummary, ProductRequest } from '../../models/product.js';

export class ProductAgent {
  private readonly systemPrompt = `
    You are the Kindle Product Agent. Your goal is to take a structured discovery output and transform it into a professional product specification.

    Inputs provided:
    1. A summary of the application idea.
    2. A list of discovered requirements.

    Your Tasks:
    1. Suggest 3-5 creative and relevant names for the application.
    2. Write a professional product description (1-2 paragraphs).
    3. Identify specific target user personas.
    4. Define a set of "Core Features" (MVP) with detailed descriptions and "high" priority.
    5. Define "Optional Features" (Future iterations) with "medium" or "low" priority.
    6. Generate 3-5 high-impact User Stories in the format: "As a [actor], I want to [action] so that [benefit]".

    OUTPUT FORMAT:
    You must output your response as a valid JSON object with the following structure:
    {
      "nameSuggestions": ["Name 1", "Name 2", "Name 3"],
      "description": "Professional description here...",
      "targetUsers": ["Persona 1", "Persona 2"],
      "coreFeatures": [
        { "name": "Feature Name", "description": "Detail...", "priority": "high" }
      ],
      "optionalFeatures": [
        { "name": "Feature Name", "description": "Detail...", "priority": "medium" }
      ],
      "userStories": [
        { "actor": "Persona", "action": "do something", "benefit": "get value" }
      ]
    }
  `;

  async generateProductSummary(request: ProductRequest): Promise<ProductSummary> {
    const userInput = `
      SUMMARY: ${request.discoveryResult.understandingSummary}
      REQUIREMENTS: ${request.discoveryResult.discoveredRequirements.join(', ')}
    `;

    const messages: AiChatMessage[] = [
      { role: 'system', content: this.systemPrompt },
      { role: 'user', content: userInput }
    ];

    try {
      const response = await aiService.chat({
        messages,
        temperature: 0.3
      });

      try {
        const result = JSON.parse(response.content) as ProductSummary;
        return result;
      } catch (parseError) {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          return JSON.parse(jsonMatch[0]) as ProductSummary;
        }
        throw new Error('AI failed to provide a structured product summary');
      }
    } catch (error: any) {
      throw new AiError(`Product Agent Error: ${error.message}`, 500, 'product-agent');
    }
  }
}

export const productAgent = new ProductAgent();
