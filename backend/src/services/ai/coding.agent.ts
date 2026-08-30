import { aiService } from './ai.service.js';
import { AiChatMessage, AiError } from '../../models/ai.js';
import { CodingResult, CodingRequest } from '../../models/coding.js';

export class CodingAgent {
  private readonly systemPrompt = `
    You are the Kindle Coding Agent. Your goal is to generate high-quality, production-ready source code based on a specific development task and architectural blueprint.

    Guidelines:
    1. Strictly follow the provided Architecture Pattern and Module structure.
    2. Use the specified technical layers (e.g., Domain, Data, Presentation).
    3. Respect existing files and ensure new code integrates seamlessly.
    4. Provide clear explanations for your changes.
    5. Ensure all file paths are relative to the project "src" root.
    6. Do NOT include extraneous text outside of the required JSON format.

    OUTPUT FORMAT:
    You must output your response as a valid JSON object with the following structure:
    {
      "changes": [
        {
          "path": "relative/path/to/file.ext",
          "content": "Full source code content here...",
          "type": "create" | "modify" | "delete"
        }
      ],
      "explanation": "Brief summary of what was implemented and why",
      "confidence": 0.95
    }
  `;

  async executeTask(request: CodingRequest): Promise<CodingResult> {
    const userInput = `
      ARCHITECTURE PATTERN: ${request.architecture.pattern}
      LAYERS: ${request.architecture.layers.join(', ')}
      TASK: ${request.task.title}
      DESCRIPTION: ${request.task.description}
      EXPECTED OUTPUT: ${request.task.expectedOutput}
      ACCEPTANCE CRITERIA: ${request.task.acceptanceCriteria.join(' | ')}
      EXISTING FILES: ${request.existingFiles.join(', ')}
    `;

    const messages: AiChatMessage[] = [
      { role: 'system', content: this.systemPrompt },
      { role: 'user', content: userInput }
    ];

    try {
      const response = await aiService.chat({
        messages,
        temperature: 0.1
      });

      try {
        const result = JSON.parse(response.content) as CodingResult;

        result.changes.forEach(change => {
          if (change.path.startsWith('/') || change.path.includes('..')) {
            throw new Error(`Security Error: Invalid file path detected: ${change.path}`);
          }
        });

        return result;
      } catch (parseError: any) {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const result = JSON.parse(jsonMatch[0]) as CodingResult;
          return result;
        }
        throw new Error(`AI failed to provide structured coding output: ${parseError.message}`);
      }
    } catch (error: any) {
      throw new AiError(`Coding Agent Error: ${error.message}`, 500, 'coding-agent');
    }
  }
}

export const codingAgent = new CodingAgent();
