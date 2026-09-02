import { aiService } from './ai.service.js';
import { AiChatMessage, AiError } from '../../models/ai.js';
import { ArchitectureBlueprint, ArchitectureRequest } from '../../models/architecture.js';
import { extractJson } from './ai-utils.js';

export class ArchitectureAgent {
  private readonly systemPrompt = `
    You are the Kindle Architecture Agent. Your goal is to design a robust, scalable, and technology-specific architecture for an application.

    Guidelines:
    1. Tailor the architecture to the selected technology (e.g., Flutter -> Clean/Bloc, React -> Layered/Hooks).
    2. Define a logical module structure based on the requirements.
    3. Specify clear technical layers (e.g., Presentation, Domain, Data).
    4. Select specific, industry-standard dependencies (packages/libraries).
    5. Describe the data flow (e.g., Unidirectional, Reactive) and API strategy (e.g., REST, GraphQL, Offline-first).

    OUTPUT FORMAT:
    You must output your response as a valid JSON object with the following structure:
    {
      "pattern": "Architecture Pattern Name (e.g. CLEAN, MVVM)",
      "layers": ["Layer 1", "Layer 2"],
      "modules": [
        { "name": "Module Name", "responsibility": "What it does", "dependencies": ["Other Module Names"] }
      ],
      "dependencies": [
        { "name": "Package Name", "purpose": "Why use it", "category": "Category" }
      ],
      "dataFlow": "Short summary of how data moves through the system",
      "apiStrategy": "Summary of API communication and state sync"
    }
  `;

  async generateBlueprint(request: ArchitectureRequest): Promise<ArchitectureBlueprint> {
    const userInput = `
      REQUIREMENTS: ${request.requirements.join(', ')}
      TECHNOLOGY: ${request.technology}
      PLATFORMS: ${request.platforms.join(', ')}
      BACKEND: ${request.backend}
      DATABASE: ${request.database}
    `;

    const messages: AiChatMessage[] = [
      { role: 'system', content: this.systemPrompt },
      { role: 'user', content: userInput }
    ];

    try {
      const response = await aiService.chat({
        messages,
        temperature: 0.2
      });

      let result: ArchitectureBlueprint;
      try {
        result = extractJson<ArchitectureBlueprint>(response.content);
      } catch (e: any) {
        console.error(`Architecture Agent: Primary extraction failed: ${e.message}`);
        if (response.reasoning_details) {
          console.log('Architecture Agent: Attempting fallback to reasoning_details...');
          result = extractJson<ArchitectureBlueprint>(response.reasoning_details);
        } else {
          throw e;
        }
      }
      result.reasoning = response.reasoning_details;
      return result;
    } catch (error: any) {
      if (error instanceof AiError) throw error;
      throw new AiError(`Architecture Agent Error: ${error.message}`, 500, 'architecture-agent');
    }
  }
}

export const architectureAgent = new ArchitectureAgent();
