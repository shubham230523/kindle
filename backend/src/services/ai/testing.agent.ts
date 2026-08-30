import { testService } from '../workspace/test.service.js';
import { TestRunResult, TestCategory } from '../../models/test.js';

export class TestingAgent {

  async executeTestStrategy(projectId: string, technology: string): Promise<TestRunResult[]> {
    const tech = technology.toLowerCase();
    const results: TestRunResult[] = [];

    // 1. Determine Framework & Commands
    if (tech.includes('flutter')) {
      // Run unit and widget tests
      results.push(await testService.runTests(projectId, 'flutter', ['test'], TestCategory.unit));
    } else if (tech.includes('web') || tech.includes('react') || tech.includes('node')) {
      results.push(await testService.runTests(projectId, 'npm', ['test'], TestCategory.unit));
    } else {
      // Default / Generic
      results.push(await testService.runTests(projectId, 'echo', ['"No testing framework detected"'], TestCategory.unit));
    }

    return results;
  }

  async generateTest(projectId: string, sourceFile: string, content: string): Promise<string> {
    // This would call LLM to generate a test file for the given source
    // Placeholder for now
    return `// Generated test for ${sourceFile}\nimport 'package:flutter_test/flutter_test.dart';\n\nvoid main() {\n  test('Base test', () => expect(true, isTrue));\n}`;
  }
}

export const testingAgent = new TestingAgent();
