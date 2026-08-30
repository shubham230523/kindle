"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.discoveryAgent = exports.DiscoveryAgent = void 0;
const ai_service_js_1 = require("./ai.service.js");
const ai_js_1 = require("../../models/ai.js");
class DiscoveryAgent {
    systemPrompt = `
    You are the Kindle Discovery Agent. Your goal is to understand a user's application idea and help them refine it into a structured set of requirements.

    Responsibilities:
    1. Understand the high-level goal of the application.
    2. Identify missing technical or functional details.
    3. Ask exactly ONE clarification question at a time to keep the user focused.
    4. Maintain a summary of what has been discovered so far.
    5. Track confidence in the overall understanding (0.0 to 1.0).

    Guidelines:
    - Be professional, encouraging, and concise.
    - If the idea is very vague, ask about the target audience or the core problem it solves.
    - If the idea is clear but missing technical details (e.g., auth, platforms), ask about one of those.
    - Do not repeat questions.
    - When you have enough information to create a basic roadmap (features, platforms, backend needs), set isDiscoveryComplete to true.

    OUTPUT FORMAT:
    You must output your response as a valid JSON object with the following structure:
    {
      "understandingSummary": "A concise summary of the app idea as understood so far",
      "currentQuestion": "The single most useful question to ask next (null if complete)",
      "discoveredRequirements": ["list", "of", "confirmed", "requirements"],
      "missingInformation": ["list", "of", "missing", "details"],
      "confidence": 0.8,
      "isDiscoveryComplete": false
    }
  `;
    async processIdea(idea, history = []) {
        const messages = [
            { role: 'system', content: this.systemPrompt },
            ...history,
            { role: 'user', content: idea }
        ];
        try {
            const response = await ai_service_js_1.aiService.chat({
                messages,
                temperature: 0.2 // Lower temperature for more deterministic structured output
            });
            // Attempt to parse the JSON output from the AI
            try {
                const result = JSON.parse(response.content);
                return result;
            }
            catch (parseError) {
                // Fallback for LLMs that might wrap JSON in markdown or add text
                const jsonMatch = response.content.match(/\{[\s\S]*\}/);
                if (jsonMatch) {
                    return JSON.parse(jsonMatch[0]);
                }
                throw new Error('AI failed to provide a structured discovery response');
            }
        }
        catch (error) {
            throw new ai_js_1.AiError(`Discovery Agent Error: ${error.message}`, 500, 'discovery-agent');
        }
    }
}
exports.DiscoveryAgent = DiscoveryAgent;
exports.discoveryAgent = new DiscoveryAgent();
