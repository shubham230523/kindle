import { aiService } from './ai.service.js';
import { extractJson } from './ai-utils.js';
import { AiError } from '../../models/ai.js';
export class DecomposerAgent {
    getSystemPrompt(strategy = 'BALANCED') {
        const strategyInstruction = strategy === 'LOCAL_OPTIMIZED'
            ? `STRATEGY: ATOMIC (LOCAL MODEL OPTIMIZED)
         - MANDATORY: Break down tasks into ATOMIC units.
         - One sub-task should typically result in only 1 or 2 specific source files.
         - Do not group multiple screens or large repositories into a single sub-task.
         - The goal is to keep the output small enough for a low-parameter local model to generate without logical errors.`
            : `STRATEGY: BALANCED
         - No single sub-task should handle more than 20% of the overall feature complexity.
         - UI tasks: Limit to 1-2 screens or 5 reusable components per sub-task.`;
        return `
    You are the Kindle Decomposer Agent. Your goal is to break down a high-level development task into granular, layer-specific sub-tasks.

    CRITICAL RULE: YOU MUST ONLY OUTPUT VALID JSON.
    YOUR ENTIRE RESPONSE MUST BE A SINGLE JSON OBJECT.

    Guidelines for Decomposition:
    1. STACK-AWARE: Divide the task into sub-tasks based on architecture layers (UI, DOMAIN, DATA, INTEGRATION).
    2. CHUNKING & STRATEGY:
       ${strategyInstruction}
    3. DEPENDENCY GRAPH: Clearly define dependencies between sub-tasks (e.g., UI depends on DOMAIN).
    4. INTEGRATION FOCUS: Always include at least one INTEGRATION sub-task to wire everything together (DI, Routing).
    5. NO CONVERSATION: Return only the JSON object.

    OUTPUT FORMAT:
    {
      "subTasks": [
        {
          "id": "st1",
          "parentId": "task_id",
          "title": "Sub-task Title",
          "description": "Granular technical details",
          "role": "UI" | "DOMAIN" | "DATA" | "INTEGRATION",
          "dependencies": ["list_of_subtask_ids"],
          "expectedOutput": "Specific files or functionality (e.g., user_model.dart)",
          "acceptanceCriteria": ["criterion 1"],
          "estimatedComplexity": "low" | "medium" | "high"
        }
      ],
      "explanation": "Brief reasoning for this specific decomposition"
    }
  `;
    }
    async decomposeTask(task, architecture, strategy = 'BALANCED', delegate) {
        const userInput = `
      TASK TO DECOMPOSE:
      Title: ${task.title}
      Description: ${task.description}
      Expected Output: ${task.expectedOutput}
      Architecture Pattern: ${architecture.pattern}
      Layers: ${architecture.layers.join(', ')}
      Modules: ${architecture.modules.map(m => m.name).join(', ')}
    `;
        const systemPrompt = this.getSystemPrompt(strategy);
        if (delegate) {
            console.log(`[DECOMPOSER_AGENT] 🚩 Delegating prompt to client for task: ${task.title}`);
            return {
                subTasks: [],
                explanation: 'Delegating to client-side local LLM.',
                promptDelegation: {
                    systemPrompt,
                    userPrompt: userInput
                }
            };
        }
        const messages = [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userInput }
        ];
        try {
            const response = await aiService.chat({
                messages,
                temperature: 0.2
            });
            const result = extractJson(response.content);
            return result;
        }
        catch (error) {
            if (error instanceof AiError)
                throw error;
            throw new AiError(`Decomposer Agent Error: ${error.message}`, 500, 'decomposer-agent');
        }
    }
}
export const decomposerAgent = new DecomposerAgent();
