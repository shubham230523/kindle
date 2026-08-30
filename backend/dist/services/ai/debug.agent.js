import { aiService } from './ai.service.js';
import { AiError } from '../../models/ai.js';
export class DebugAgent {
    async analyzeFailure(projectId, errorOutput, taskDescription) {
        const systemPrompt = `
      You are the Kindle Debug Agent. Your goal is to analyze build failures and suggest technical fixes.

      OUTPUT FORMAT:
      Return a valid JSON object:
      {
        "rootCause": "Detailed technical reason for failure",
        "suggestedFix": "Code modification plan",
        "filesToModify": ["relative/path/to/file.ext"]
      }
    `;
        const userInput = `
      TASK: ${taskDescription}
      ERROR OUTPUT: ${errorOutput}
    `;
        try {
            const response = await aiService.chat({
                messages: [
                    { role: 'system', content: systemPrompt },
                    { role: 'user', content: userInput }
                ],
                temperature: 0.1
            });
            const result = JSON.parse(response.content);
            return result;
        }
        catch (error) {
            throw new AiError(`Debug Agent Error: ${error.message}`, 500, 'debug-agent');
        }
    }
}
export const debugAgent = new DebugAgent();
