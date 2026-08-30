import { promises as fs } from 'fs';
import path from 'path';
import { workspaceService } from './workspace.service.js';
import { FileModification } from '../../models/coding.js';

export interface Checkpoint {
  id: string;
  projectId: string;
  description: string;
  timestamp: string;
  files: string[]; // paths relative to src
}

export class CodeChangeService {

  async applyChanges(projectId: string, changes: FileModification[], description: string): Promise<string> {
    // 1. Create a checkpoint before applying changes
    const checkpointId = await this.createCheckpoint(projectId, `Before: ${description}`);

    try {
      for (const change of changes) {
        if (change.type === 'create' || change.type === 'modify') {
          await workspaceService.writeSourceFile(projectId, change.path, change.content);
        } else if (change.type === 'delete') {
          await this.deleteSourceFile(projectId, change.path);
        }
      }
      return checkpointId;
    } catch (error) {
      // 2. If something fails, we should ideally rollback immediately
      await this.rollbackToCheckpoint(projectId, checkpointId);
      throw new Error(`Failed to apply changes. Rollback triggered: ${error}`);
    }
  }

  private async deleteSourceFile(projectId: string, relativePath: string): Promise<void> {
    const sourceRoot = workspaceService.getSourcePath(projectId);
    const fullPath = path.join(sourceRoot, relativePath);

    if (!fullPath.startsWith(sourceRoot)) {
      throw new Error('Security Error: Attempted to delete file outside of project workspace');
    }

    try {
      await fs.unlink(fullPath);
    } catch (error: any) {
      if (error.code !== 'ENOENT') throw error; // Ignore if file doesn't exist
    }
  }

  async createCheckpoint(projectId: string, description: string): Promise<string> {
    const projectPath = workspaceService.getProjectPath(projectId);
    const sourcePath = workspaceService.getSourcePath(projectId);
    const checkpointId = `cp_${Date.now()}`;
    const checkpointPath = path.join(projectPath, 'checkpoints', checkpointId);

    await fs.mkdir(checkpointPath, { recursive: true });

    // Copy all current source files to the checkpoint directory
    await this.copyDirectory(sourcePath, checkpointPath);

    // Record checkpoint metadata
    const metadata: Checkpoint = {
      id: checkpointId,
      projectId,
      description,
      timestamp: new Date().toISOString(),
      files: await workspaceService.listProjectFiles(projectId)
    };

    await fs.writeFile(
      path.join(checkpointPath, 'metadata.json'),
      JSON.stringify(metadata, null, 2)
    );

    return checkpointId;
  }

  async rollbackToCheckpoint(projectId: string, checkpointId: string): Promise<void> {
    const projectPath = workspaceService.getProjectPath(projectId);
    const sourcePath = workspaceService.getSourcePath(projectId);
    const checkpointPath = path.join(projectPath, 'checkpoints', checkpointId);

    // Verify checkpoint exists
    try {
      await fs.access(checkpointPath);
    } catch {
      throw new Error(`Checkpoint ${checkpointId} not found`);
    }

    // 1. Clear current source
    await fs.rm(sourcePath, { recursive: true, force: true });
    await fs.mkdir(sourcePath, { recursive: true });

    // 2. Restore from checkpoint
    await this.copyDirectory(checkpointPath, sourcePath);

    // Cleanup metadata.json from source root if it was copied (it would be in checkpoint root)
    const extraMetadata = path.join(sourcePath, 'metadata.json');
    try { await fs.unlink(extraMetadata); } catch {}
  }

  private async copyDirectory(src: string, dest: string): Promise<void> {
    try {
      const entries = await fs.readdir(src, { withFileTypes: true });

      for (const entry of entries) {
        const srcPath = path.join(src, entry.name);
        const destPath = path.join(dest, entry.name);

        if (entry.isDirectory()) {
          if (entry.name === 'checkpoints') continue; // Don't backup backups
          await fs.mkdir(destPath, { recursive: true });
          await this.copyDirectory(srcPath, destPath);
        } else {
          await fs.copyFile(srcPath, destPath);
        }
      }
    } catch (error: any) {
      if (error.code !== 'ENOENT') throw error;
    }
  }

  async listCheckpoints(projectId: string): Promise<Checkpoint[]> {
    const projectPath = workspaceService.getProjectPath(projectId);
    const checkpointsDir = path.join(projectPath, 'checkpoints');

    try {
      const entries = await fs.readdir(checkpointsDir, { withFileTypes: true });
      const checkpoints: Checkpoint[] = [];

      for (const entry of entries) {
        if (entry.isDirectory()) {
          const metaPath = path.join(checkpointsDir, entry.name, 'metadata.json');
          const content = await fs.readFile(metaPath, 'utf-8');
          checkpoints.push(JSON.parse(content));
        }
      }

      return checkpoints.sort((a, b) => b.timestamp.localeCompare(a.timestamp));
    } catch {
      return [];
    }
  }
}

export const codeChangeService = new CodeChangeService();
