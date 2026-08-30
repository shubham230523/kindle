"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.architectureAgent = exports.ArchitectureAgent = void 0;
const ai_service_js_1 = require("./ai.service.js");
const ai_js_1 = require("../../models/ai.js");
class ArchitectureAgent {
    systemPrompt = `
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
    async generateBlueprint(request) {
        const userInput = `
      REQUIREMENTS: ${request.requirements.join(', ')}
      TECHNOLOGY: ${request.technology}
      PLATFORMS: ${request.platforms.join(', ')}
      BACKEND: ${request.backend}
      DATABASE: ${request.database}
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
                throw new Error('AI failed to provide a structured architecture blueprint');
            }
        }
        catch (error) {
            throw new ai_js_1.AiError(`Architecture Agent Error: ${error.message}`, 500, 'architecture-agent');
        }
    }
}
exports.ArchitectureAgent = ArchitectureAgent;
exports.architectureAgent = new ArchitectureAgent();
