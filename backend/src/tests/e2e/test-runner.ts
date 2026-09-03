import { graphService } from '../../services/workspace/graph.service.js';
import { PlanTask } from '../../models/plan.js';
import { ArchitectureBlueprint } from '../../models/architecture.js';
import { env } from '../../config/env.js';

async function runTest() {
  console.log('🚀 Starting Todo App Generation Test (Atomic Strategy)...');

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

  try {
    // 1. Force Simulation Mode
    process.env.OPENROUTER_API_KEY = 'open-router-api-key';
    process.env.OPENROUTER_MODEL = 'model';

    // 2. Execute Graph
    const result = await graphService.executeTaskGraph(
      'test_project',
      todoTask,
      architecture,
      'LOCAL_OPTIMIZED'
    );

    // 3. Verify
    console.log('\n✅ Test Completed Successfully!');
    console.log('Explanation:', result.explanation);
    console.log('Files Generated:', result.changes.length);
    result.changes.forEach(c => console.log(`  - [${c.type}] ${c.path}`));

    if (result.changes.length > 0) {
      process.exit(0);
    } else {
      console.error('❌ Error: No files were generated.');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Test Failed with Error:', error);
    process.exit(1);
  }
}

runTest();
