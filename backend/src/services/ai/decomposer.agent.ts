import { aiService } from './ai.service.js';
import { extractJson } from './ai-utils.js';
import { AiChatMessage, AiError } from '../../models/ai.js';
import { PlanTask, DecompositionResult } from '../../models/plan.js';
import { ArchitectureBlueprint } from '../../models/architecture.js';

export class DecomposerAgent {
  private readonly systemPrompt = `
    You are the Kindle Decomposer Agent. Your goal is to break down a high-level development task into granular, layer-specific sub-tasks.

    CRITICAL RULE: YOU MUST ONLY OUTPUT VALID JSON.
    YOUR ENTIRE RESPONSE MUST BE A SINGLE JSON OBJECT.

    Guidelines for Decomposition:
    1. STACK-AWARE: Divide the task into sub-tasks based on architecture layers (UI, DOMAIN, DATA, INTEGRATION).
    2. CHUNKING (LOAD BALANCING):
       - No single sub-task should handle more than 20% of the overall feature complexity.
       - UI tasks: Limit to 1-2 screens or 5 reusable components per sub-task.
       - Data/Domain: Split complex logic into multiple interfaces or repositories if needed.
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
          "expectedOutput": "Specific files or functionality",
          "acceptanceCriteria": ["criterion 1"],
          "estimatedComplexity": "low" | "medium" | "high"
        }
      ],
      "explanation": "Brief reasoning for this specific decomposition"
    }
  `;

  async decomposeTask(task: PlanTask, architecture: ArchitectureBlueprint): Promise<DecompositionResult> {
    const userInput = `
      TASK TO DECOMPOSE:
      Title: ${task.title}
      Description: ${task.description}
      Expected Output: ${task.expectedOutput}
      Architecture Pattern: ${architecture.pattern}
      Layers: ${architecture.layers.join(', ')}
      Modules: ${architecture.modules.map(m => m.name).join(', ')}
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

      const result = extractJson<DecompositionResult>(response.content);
      return result;
    } catch (error: any) {
      if (error instanceof AiError) throw error;
      throw new AiError(`Decomposer Agent Error: ${error.message}`, 500, 'decomposer-agent');
    }
  }
}

export const decomposerAgent = new DecomposerAgent();
