import { describe, it, expect, vi } from 'vitest';
import { graphService } from '../../services/workspace/graph.service.js';
import { PlanTask } from '../../models/plan.js';
import { ArchitectureBlueprint } from '../../models/architecture.js';
import { env } from '../../config/env.js';

describe('Todo App Generation (Atomic Decomposition)', () => {
  it('should decompose a Todo App task into atomic sub-tasks', async () => {
    // 1. Setup Mock Task
    const todoTask: PlanTask = {
      id: 't_todo',
      title: 'Implement Todo Feature',
      description: 'Create a complete Todo feature with listing, adding, and deleting tasks.',
      phaseId: 'p2',
      dependencies: [],
      expectedOutput: 'Full Todo feature code',
      acceptanceCriteria: ['Can add todos', 'Can see list', 'Can delete'],
      complexity: 'medium'
    };

    const architecture: ArchitectureBlueprint = {
      pattern: 'CLEAN_ARCH_BLOC',
      layers: ['Presentation', 'Domain', 'Data'],
      modules: [{ name: 'Features', responsibility: 'Feature logic', dependencies: [] }],
      dependencies: [{ name: 'flutter_bloc', purpose: 'state', category: 'UI' }],
      dataFlow: 'unidirectional',
      apiStrategy: 'REST'
    };

    // 2. Force Local Mode Simulation for testing
    vi.stubEnv('OPENROUTER_API_KEY', 'open-router-api-key');
    vi.stubEnv('OPENROUTER_MODEL', 'model');

    // 3. Execute Graph
    const result = await graphService.executeTaskGraph(
      'test_project',
      todoTask,
      architecture,
      'LOCAL_OPTIMIZED' // Atomic strategy
    );

    // 4. Assertions
    expect(result).toBeDefined();
    expect(result.changes.length).toBeGreaterThan(0);
    expect(result.explanation).toContain('Integrated');

    console.log('Generated Files in Todo Mock Run:', result.changes.map(c => c.path));
  });
});
