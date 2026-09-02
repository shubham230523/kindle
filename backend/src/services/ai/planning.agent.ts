import { aiService } from './ai.service.js';
import { AiChatMessage, AiError } from '../../models/ai.js';
import { DevelopmentPlanResult, PlanningRequest } from '../../models/plan.js';

export class PlanningAgent {
  private readonly systemPrompt = `
    You are the Kindle Planning Agent. Your goal is to create a detailed, dependency-aware development plan for an application.

    Guidelines:
    1. Divide the work into logical phases (e.g., Project Setup, Foundation, Auth, Feature X, Testing, Release).
    2. Break down phases into small, actionable tasks that a Coding Agent can execute independently.
    3. Define clear dependencies between tasks (using task IDs).
    4. For each task, provide a detailed description, the expected technical output, and specific acceptance criteria.
    5. Ensure the plan follows the provided architecture pattern and module structure.
    6. Estimate complexity (low, medium, high) for each task.

    OUTPUT FORMAT:
    You must output your response as a valid JSON object with the following structure:
    {
      "phases": [
        {
          "id": "p1",
          "title": "Phase Title",
          "description": "What this phase achieves",
          "tasks": [
            {
              "id": "t1_1",
              "title": "Task Title",
              "description": "Technical details of the task",
              "phaseId": "p1",
              "dependencies": ["list_of_task_ids"],
              "expectedOutput": "The files or functionality created",
              "acceptanceCriteria": ["criterion 1", "criterion 2"],
              "complexity": "medium"
            }
          ]
        }
      ]
    }
  `;

  async generatePlan(request: PlanningRequest): Promise<DevelopmentPlanResult> {
    const userInput = `
      PRODUCT: ${request.product.name}
      DESCRIPTION: ${request.product.description}
      FEATURES: ${request.product.coreFeatures.map(f => f.name).join(', ')}
      ARCHITECTURE: ${request.architecture.pattern}
      LAYERS: ${request.architecture.layers.join(', ')}
      MODULES: ${request.architecture.modules.map(m => m.name).join(', ')}
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

      try {
        const result = JSON.parse(response.content) as DevelopmentPlanResult;
        result.reasoning = response.reasoningDetails;
        return result;
      } catch (parseError) {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const result = JSON.parse(jsonMatch[0]) as DevelopmentPlanResult;
          result.reasoning = response.reasoningDetails;
          return result;
        }
        throw new Error('AI failed to provide a structured development plan');
      }
    } catch (error: any) {
      throw new AiError(`Planning Agent Error: ${error.message}`, 500, 'planning-agent');
    }
  }
}

export const planningAgent = new PlanningAgent();
