import { spawn } from 'child_process';
import { workspaceService } from './workspace.service.js';
import { TestStatus, TestRunResult, TestCategory } from '../../models/test.js';

export class TestService {

  async runTests(projectId: string, command: string, args: string[], category: TestCategory): Promise<TestRunResult> {
    const testRunId = `test_${Date.now()}`;
    const startedAt = new Date().toISOString();
    const sourcePath = workspaceService.getSourcePath(projectId);

    return new Promise((resolve) => {
      let output = '';

      const child = spawn(command, args, {
        cwd: sourcePath,
        shell: true,
      });

      // 3-minute timeout for tests
      const timeout = setTimeout(() => {
        child.kill();
        resolve(this.createFailedResult(testRunId, projectId, category, startedAt, output + '\n[ERROR] Tests timed out after 3 minutes.'));
      }, 180000);

      child.stdout.on('data', (data) => {
        output += data.toString();
      });

      child.stderr.on('data', (data) => {
        output += data.toString();
      });

      child.on('close', (code) => {
        clearTimeout(timeout);
        const completedAt = new Date().toISOString();

        // Simple mock parsing for now
        // In a real implementation, we would parse JSON or XML test reports
        const passed = !output.toLowerCase().includes('failed') && code === 0;

        resolve({
          id: testRunId,
          projectId,
          category,
          status: passed ? TestStatus.passed : TestStatus.failed,
          startedAt,
          completedAt,
          totalCount: 0, // Would be parsed from real output
          passedCount: passed ? 1 : 0,
          failedCount: passed ? 0 : 1,
          skippedCount: 0,
          output,
          testCases: [], // Would be populated from real output
        });
      });
    });
  }

  private createFailedResult(id: string, projectId: string, category: TestCategory, startedAt: string, output: string): TestRunResult {
    return {
      id,
      projectId,
      category,
      status: TestStatus.failed,
      startedAt,
      completedAt: new Date().toISOString(),
      totalCount: 0,
      passedCount: 0,
      failedCount: 1,
      skippedCount: 0,
      output,
      testCases: [],
    };
  }
}

export const testService = new TestService();
