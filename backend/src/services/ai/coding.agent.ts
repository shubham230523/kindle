import { aiService } from './ai.service.js';
import { extractJson } from './ai-utils.js';
import { AiChatMessage, AiError } from '../../models/ai.js';
import { CodingResult, CodingRequest } from '../../models/coding.js';

export class CodingAgent {
  private getSystemPrompt(role?: string) {
    const roleInstruction = role ? `You are acting in the ${role} role. Focus strictly on ${role}-related implementation details.` : '';

    return `
    You are the Kindle Coding Agent. Your goal is to generate high-quality, production-ready source code based on a specific development task and architectural blueprint.
    ${roleInstruction}

    CRITICAL RULE: YOU MUST ONLY OUTPUT VALID JSON.
    NO CONVERSATION. NO EXPLANATIONS. NO THINKING PROCESS.
    YOUR ENTIRE RESPONSE MUST BE A SINGLE JSON OBJECT.

    Guidelines:
    1. Strictly follow the provided Architecture Pattern and Module structure.
    2. Use the specified technical layers (e.g., Domain, Data, Presentation).
    3. Respect existing files and ensure new code integrates seamlessly.
    4. Provide clear explanations for your changes inside the JSON "explanation" field.
    5. Ensure all file paths are relative to the project "src" root.
    6. If a "DEBUG CONTEXT" is provided, you must fix the reported issue while still respecting the original task and architecture.
    7. START WITH BRACE: Your response MUST start with "{" and end with "}".
    8. FULL CODE MANDATORY: Every file in the "changes" array must contain the COMPLETE, production-ready source code.
    9. NO PLACEHOLDERS: Do NOT use "TODO", "// implementation here", "...", or any other placeholders.
    10. COMPILABLE: The code must be fully functional and ready to be compiled immediately.

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
  }

  async executeTask(request: CodingRequest, onChunk?: (chunk: string) => void, providerName?: string): Promise<CodingResult> {
    let userInput = `
      ARCHITECTURE PATTERN: ${request.architecture.pattern}
      LAYERS: ${request.architecture.layers.join(', ')}
      TASK: ${request.task.title}
      ROLE: ${request.task.role || 'General'}
      DESCRIPTION: ${request.task.description}
      EXPECTED OUTPUT: ${request.task.expectedOutput}
      ACCEPTANCE CRITERIA: ${request.task.acceptanceCriteria.join(' | ')}
      EXISTING FILES: ${request.existingFiles.join(', ')}
    `;

    if (request.debugContext) {
      userInput += `

      DEBUG CONTEXT:
      ROOT CAUSE: ${request.debugContext.rootCause}
      ERROR OUTPUT: ${request.debugContext.errorOutput}
      SUGGESTED FIX: ${request.debugContext.suggestedFix}
      `;
    }

    const messages: AiChatMessage[] = [
      { role: 'system', content: this.getSystemPrompt(request.task.role) },
      { role: 'user', content: userInput }
    ];

    try {
      const response = await aiService.chat({
        messages,
        temperature: 0,
        maxTokens: 16384,
        reasoning: false
      }, onChunk, providerName);

      try {
        let result: CodingResult;

        try {
          result = extractJson<CodingResult>(response.content);
        } catch (initialError: any) {
          console.error(`Coding Agent: Primary JSON extraction failed: ${initialError.message}`);

          // If content is empty but we have reasoning, try extracting from reasoning
          if (response.reasoning_details) {
            try {
              console.log('Coding Agent: Attempting fallback to reasoning_details...');
              result = extractJson<CodingResult>(response.reasoning_details);
            } catch (innerError) {
              console.error('Coding Agent: Reasoning fallback also failed.');
              throw initialError;
            }
          } else {
            // Log a snippet of the failed content for debugging
            console.error('Coding Agent: No reasoning_details available. Content snippet:', response.content?.substring(0, 500));
            throw initialError;
          }
        }

        if (!result) {
          throw new Error('Parsed coding result is null.');
        }

        result.reasoning = response.reasoning_details;

        if (result.changes && Array.isArray(result.changes)) {
          result.changes.forEach(change => {
            if (change.path && (change.path.startsWith('/') || change.path.includes('..'))) {
              throw new Error(`Security Error: Invalid file path detected: ${change.path}`);
            }
          });
        }

        return result;
      } catch (parseError: any) {
        console.error('Coding Agent JSON Extraction Error:', parseError.message);
        console.error('Raw AI Content:', response.content);
        throw new Error(`Invalid AI Output: ${parseError.message}`);
      }
    } catch (error: any) {
      if (error instanceof AiError) throw error;
      throw new AiError(`Coding Agent Failure: ${error.message}`, 500, 'coding-agent', 'INVALID_AI_OUTPUT');
    }
  }
}

export const codingAgent = new CodingAgent();
