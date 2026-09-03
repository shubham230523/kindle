import { AiChatRequest, AiChatResponse, AiError } from '../../models/ai.js';
import { AiProvider } from './ai-provider.interface.js';

export class SimulationProvider implements AiProvider {
  public readonly name = 'simulation';

  async chat(request: AiChatRequest, onChunk?: (chunk: string) => void): Promise<AiChatResponse> {
    const systemPrompt = request.messages.find(m => m.role === 'system')?.content || '';
    const userPrompt = request.messages.find(m => m.role === 'user')?.content || '';

    const delay = parseInt(process.env.MOCK_AI_RESPONSE_DELAY || '0', 10);
    if (delay > 0) {
      await new Promise(resolve => setTimeout(resolve, delay));
    }

    console.log(`[SIMULATION] Generating mock response for prompt...`);

    if (onChunk) {
      onChunk("Generating ");
      await new Promise(resolve => setTimeout(resolve, 50));
      onChunk("simulated ");
      await new Promise(resolve => setTimeout(resolve, 50));
      onChunk("response...");
    }

    let content = '';

    if (systemPrompt.includes('Planning Agent')) {
      content = this.simulatePlanningResponse(userPrompt);
    } else if (systemPrompt.includes('Decomposer Agent')) {
      console.log(`[SIMULATION] Decomposer detected. System prompt length: ${systemPrompt.length}`);
      content = this.simulateDecompositionResponse(systemPrompt, userPrompt);
    } else if (systemPrompt.includes('Coding Agent')) {
      content = this.simulateCodingResponse(systemPrompt, userPrompt);
    } else if (systemPrompt.includes('Integrator Agent')) {
      content = this.simulateIntegrationResponse(userPrompt);
    } else if (systemPrompt.includes('Architecture Agent')) {
      content = this.simulateArchitectureResponse(userPrompt);
    } else {
      content = JSON.stringify({
        message: "Simulated generic response",
        status: "success"
      });
    }

    return {
      content,
      usage: {
        promptTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
      },
      provider: this.name,
      model: 'mock-deep-simulation',
    };
  }

  private simulateArchitectureResponse(input: string): string {
    return JSON.stringify({
      pattern: "CLEAN_ARCH_BLOC",
      layers: ["Presentation", "Domain", "Data"],
      modules: [
        { name: "Core", responsibility: "Core utilities", dependencies: [] },
        { name: "Features", responsibility: "Business features", dependencies: ["Core"] }
      ],
      dependencies: [
        { name: "flutter_bloc", purpose: "State management", category: "UI" },
        { name: "get_it", purpose: "DI", category: "Core" }
      ],
      dataFlow: "BLOC -> UseCase -> Repository",
      apiStrategy: "REST with Repository Pattern"
    }, null, 2);
  }

  private simulatePlanningResponse(input: string): string {
    return JSON.stringify({
      phases: [
        {
          id: "p1",
          title: "Foundation",
          description: "Project setup and core layers",
          tasks: [
            {
              id: "t1_1",
              title: "Setup Core Layer",
              description: "Create directory structure and core utilities",
              phaseId: "p1",
              dependencies: [],
              expectedOutput: "lib/core directory",
              acceptanceCriteria: ["Directory exists"],
              complexity: "low"
            }
          ]
        }
      ]
    }, null, 2);
  }

  private simulateDecompositionResponse(system: string, user: string): string {
    const isAtomic = system.includes('ATOMIC') || system.includes('LOCAL_OPTIMIZED');

    if (isAtomic) {
      return JSON.stringify({
        subTasks: [
          {
            id: "st1",
            parentId: "t1",
            title: "Todo Entity",
            description: "Create todo_entity.dart",
            role: "DOMAIN",
            dependencies: [],
            expectedOutput: "todo_entity.dart",
            acceptanceCriteria: ["Valid class"],
            estimatedComplexity: "low"
          },
          {
            id: "st2",
            parentId: "t1",
            title: "Todo Repository Interface",
            description: "Create todo_repository.dart",
            role: "DOMAIN",
            dependencies: ["st1"],
            expectedOutput: "todo_repository.dart",
            acceptanceCriteria: ["Valid abstract class"],
            estimatedComplexity: "low"
          },
          {
            id: "st3",
            parentId: "t1",
            title: "Todo Local Data Source",
            description: "Create local_data_source.dart",
            role: "DATA",
            dependencies: ["st1"],
            expectedOutput: "local_data_source.dart",
            acceptanceCriteria: ["Handles persistence"],
            estimatedComplexity: "medium"
          },
          {
            id: "st4",
            parentId: "t1",
            title: "Todo Page UI",
            description: "Create todo_page.dart",
            role: "UI",
            dependencies: ["st2"],
            expectedOutput: "todo_page.dart",
            acceptanceCriteria: ["Visual list"],
            estimatedComplexity: "medium"
          },
          {
            id: "st5",
            parentId: "t1",
            title: "Integration Layer",
            description: "Wire up BLoC and DI",
            role: "INTEGRATION",
            dependencies: ["st3", "st4"],
            expectedOutput: "main.dart",
            acceptanceCriteria: ["App runs"],
            estimatedComplexity: "low"
          }
        ],
        explanation: "Atomic decomposition into single-file units for local model optimization."
      }, null, 2);
    }

    return JSON.stringify({
      subTasks: [
        {
          id: "st1",
          parentId: "t1",
          title: "Domain Model",
          description: "Create entities",
          role: "DOMAIN",
          dependencies: [],
          expectedOutput: "model.dart",
          acceptanceCriteria: ["Valid dart model"],
          estimatedComplexity: "low"
        },
        {
          id: "st2",
          parentId: "t1",
          title: "UI View",
          description: "Create screen",
          role: "UI",
          dependencies: ["st1"],
          expectedOutput: "view.dart",
          acceptanceCriteria: ["Valid widget"],
          estimatedComplexity: "medium"
        }
      ],
      explanation: "Decomposed into Domain and UI layers for clean separation."
    }, null, 2);
  }

  private simulateCodingResponse(system: string, user: string): string {
    const role = user.match(/ROLE: (\w+)/)?.[1] || 'General';
    const taskTitle = user.match(/TASK: (.*)/)?.[1] || 'Unknown Task';

    console.log(`[SIMULATION] Simulating Role: ${role} for Task: ${taskTitle}`);

    let changes = [];

    if (role === 'UI') {
      changes.push({
        path: "lib/features/home/presentation/pages/home_page.dart",
        content: `import 'package:flutter/material.dart';\n\nclass HomePage extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(appBar: AppBar(title: Text('${taskTitle}')), body: Center(child: Text('Simulated UI for ${taskTitle}')));\n  }\n}`,
        type: "create"
      });
    } else if (role === 'DOMAIN') {
      changes.push({
        path: "lib/features/home/domain/entities/user.dart",
        content: `class User {\n  final String id;\n  final String name;\n  User({required this.id, required this.name});\n}`,
        type: "create"
      });
    } else {
      changes.push({
        path: "lib/simulated_file.dart",
        content: "// Simulated content for ${taskTitle}",
        type: "create"
      });
    }

    return JSON.stringify({
      changes,
      explanation: `Simulated implementation for ${taskTitle} acting as ${role}.`,
      confidence: 1.0
    }, null, 2);
  }

  private simulateIntegrationResponse(input: string): string {
    return JSON.stringify({
      changes: [
        {
          path: "lib/main.dart",
          content: "// Simulated main.dart with integration logic",
          type: "modify"
        }
      ],
      explanation: "Integrated all simulated components and wired up DI."
    }, null, 2);
  }
}
