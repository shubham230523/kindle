"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.planningAgent = exports.PlanningAgent = void 0;
const ai_service_js_1 = require("./ai.service.js");
const ai_js_1 = require("../../models/ai.js");
class PlanningAgent {
    systemPrompt = `
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
    async generatePlan(request) {
        const userInput = `
      PRODUCT: ${request.product.name}
      DESCRIPTION: ${request.product.description}
      FEATURES: ${request.product.coreFeatures.map(f => f.name).join(', ')}
      ARCHITECTURE: ${request.architecture.pattern}
      LAYERS: ${request.architecture.layers.join(', ')}
      MODULES: ${request.architecture.modules.map(m => m.name).join(', ')}
    `;
        const messages = [
            { role: 'system', content: this.systemPrompt },
            { role: 'user', content: userInput }
        ];
        try {
            const response = await ai_service_js_1.aiService.chat({
                messages,
                temperature: 0.2
            });
            try {
                const result = JSON.parse(response.content);
                return result;
            }
            catch (parseError) {
                const jsonMatch = response.content.match(/\{[\s\S]*\}/);
                if (jsonMatch) {
                    return JSON.parse(jsonMatch[0]);
                }
                throw new Error('AI failed to provide a structured development plan');
            }
        }
        catch (error) {
            throw new ai_js_1.AiError(`Planning Agent Error: ${error.message}`, 500, 'planning-agent');
        }
    }
}
exports.PlanningAgent = PlanningAgent;
exports.planningAgent = new PlanningAgent();
