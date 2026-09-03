import { aiService } from './ai.service.js';
import { extractJson } from './ai-utils.js';
import { AiChatMessage, AiError } from '../../models/ai.js';
import { CodingResult, FileModification } from '../../models/coding.js';
import { ArchitectureBlueprint } from '../../models/architecture.js';

export class IntegratorAgent {
  private readonly systemPrompt = `
    You are the Kindle Integrator Agent. Your goal is to take multiple sets of code changes from specialized agents and merge them into a cohesive, production-ready system.

    CRITICAL RULE: YOU MUST ONLY OUTPUT VALID JSON.
    YOUR ENTIRE RESPONSE MUST BE A SINGLE JSON OBJECT.

    Responsibilities:
    1. CONFLICT RESOLUTION: If two agents modified the same file, merge their changes logically.
    2. WIRING: Ensure Dependency Injection (DI) is correctly set up between layers (e.g., UI connecting to BLoCs, BLoCs connecting to Repositories).
    3. NAVIGATION: Register any new screens in the app's routing/navigation system.
    4. BOILERPLATE: Add necessary exports and imports to keep the project compilable.

    OUTPUT FORMAT:
    {
      "changes": [
        {
          "path": "relative/path/to/file.ext",
          "content": "Full source code content here...",
          "type": "create" | "modify" | "delete"
        }
      ],
      "explanation": "Summary of how the components were integrated and wired up"
    }
  `;

  async integrate(
    allResults: CodingResult[],
    architecture: ArchitectureBlueprint,
    existingFiles: string[]
  ): Promise<CodingResult> {
    const userInput = `
      ARCHITECTURE: ${architecture.pattern}
      LAYERS: ${architecture.layers.join(', ')}

      COMPONENTS TO INTEGRATE:
      ${allResults.map((r, i) => `Agent Result #${i+1} Explanation: ${r.explanation}`).join('\n')}

      EXISTING FILES: ${existingFiles.join(', ')}
    `;

    const messages: AiChatMessage[] = [
      { role: 'system', content: this.systemPrompt },
      { role: 'user', content: userInput }
    ];

    try {
      const response = await aiService.chat({
        messages,
        temperature: 0,
        maxTokens: 16384
      });

      const result = extractJson<CodingResult>(response.content);
      return result;
    } catch (error: any) {
      if (error instanceof AiError) throw error;
      throw new AiError(`Integrator Agent Error: ${error.message}`, 500, 'integrator-agent');
    }
  }
}

export const integratorAgent = new IntegratorAgent();
