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
      if (process.env.OPENROUTER_API_KEY === 'open-router-api-key') {
        console.log('[INTEGRATOR_AGENT] 🔄 SIMULATION: Consolidating sub-agent changes...');
        const consolidatedChanges = allResults.flatMap(r => r.changes);

        // Add a virtual main.dart that includes the integrated files
        consolidatedChanges.push({
          path: "lib/main.dart",
          content: `// Simulated Main\n// Integrated Files:\n${consolidatedChanges.map(c => `// - ${c.path}`).join('\n')}`,
          type: "modify"
        });

        return {
          changes: consolidatedChanges,
          explanation: `[SIMULATED] Successfully consolidated ${allResults.length} sub-agent outputs into a unified feature set.`,
          confidence: 1.0
        };
      }

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
