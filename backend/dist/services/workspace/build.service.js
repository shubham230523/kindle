import { spawn } from 'child_process';
import { workspaceService } from './workspace.service.js';
import { BuildStatus } from '../../models/build.js';
export class BuildService {
    async runBuild(projectId, command, args, platform) {
        const buildId = `build_${Date.now()}`;
        const startedAt = new Date().toISOString();
        const startTime = Date.now();
        const projectPath = workspaceService.getProjectPath(projectId);
        const sourcePath = workspaceService.getSourcePath(projectId);
        return new Promise((resolve) => {
            let output = '';
            const child = spawn(command, args, {
                cwd: sourcePath,
                env: {
                    ...process.env,
                    // Basic isolation: restrict some env vars if needed
                    KINDLE_BUILD_ID: buildId,
                    KINDLE_PROJECT_ID: projectId,
                },
                shell: true, // Use shell for platform-specific commands
            });
            // 5-minute timeout as a strict resource limit
            const timeout = setTimeout(() => {
                child.kill();
                resolve({
                    id: buildId,
                    projectId,
                    platform,
                    status: BuildStatus.failed,
                    output: output + '\n[ERROR] Build timed out after 5 minutes.',
                    startedAt,
                    completedAt: new Date().toISOString(),
                    durationMs: Date.now() - startTime,
                });
            }, 300000);
            child.stdout.on('data', (data) => {
                output += data.toString();
            });
            child.stderr.on('data', (data) => {
                output += data.toString();
            });
            child.on('close', (code) => {
                clearTimeout(timeout);
                const completedAt = new Date().toISOString();
                resolve({
                    id: buildId,
                    projectId,
                    platform,
                    status: code === 0 ? BuildStatus.successful : BuildStatus.failed,
                    output,
                    startedAt,
                    completedAt,
                    durationMs: Date.now() - startTime,
                });
            });
            child.on('error', (err) => {
                clearTimeout(timeout);
                resolve({
                    id: buildId,
                    projectId,
                    platform,
                    status: BuildStatus.failed,
                    output: output + `\n[ERROR] Failed to start build process: ${err.message}`,
                    startedAt,
                    completedAt: new Date().toISOString(),
                    durationMs: Date.now() - startTime,
                });
            });
        });
    }
}
export const buildService = new BuildService();
