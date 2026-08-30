import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
const __dirname = path.dirname(fileURLToPath(import.meta.url));
export class WorkspaceService {
    workspaceRoot;
    constructor() {
        // Put workspaces in the root of the backend folder, not nested in src/dist
        this.workspaceRoot = path.resolve(__dirname, '../../../../workspaces');
    }
    async initialize() {
        try {
            await fs.mkdir(this.workspaceRoot, { recursive: true });
        }
        catch (error) {
            console.error('Failed to initialize workspace root:', error);
            throw error;
        }
    }
    async createProjectWorkspace(metadata) {
        const projectPath = this.getProjectPath(metadata.id);
        const sourcePath = path.join(projectPath, 'src');
        await fs.mkdir(projectPath, { recursive: true });
        await fs.mkdir(sourcePath, { recursive: true });
        // Store metadata
        await fs.writeFile(path.join(projectPath, 'metadata.json'), JSON.stringify(metadata, null, 2));
        return projectPath;
    }
    getProjectPath(projectId) {
        // Prevent path traversal by only using the basename of the ID
        const safeId = path.basename(projectId);
        return path.join(this.workspaceRoot, safeId);
    }
    getSourcePath(projectId) {
        return path.join(this.getProjectPath(projectId), 'src');
    }
    async writeSourceFile(projectId, relativePath, content) {
        const sourceRoot = this.getSourcePath(projectId);
        const fullPath = path.join(sourceRoot, relativePath);
        // Security check: Ensure the resolved path is within the project's source root
        if (!fullPath.startsWith(sourceRoot)) {
            throw new Error('Security Error: Attempted to write file outside of project workspace');
        }
        await fs.mkdir(path.dirname(fullPath), { recursive: true });
        await fs.writeFile(fullPath, content, 'utf-8');
    }
    async readSourceFile(projectId, relativePath) {
        const sourceRoot = this.getSourcePath(projectId);
        const fullPath = path.join(sourceRoot, relativePath);
        if (!fullPath.startsWith(sourceRoot)) {
            throw new Error('Security Error: Attempted to read file outside of project workspace');
        }
        return fs.readFile(fullPath, 'utf-8');
    }
    async listProjectFiles(projectId, currentDir = '') {
        const sourceRoot = this.getSourcePath(projectId);
        const targetDir = path.join(sourceRoot, currentDir);
        if (!targetDir.startsWith(sourceRoot)) {
            throw new Error('Security Error: Attempted to list files outside of project workspace');
        }
        try {
            const entries = await fs.readdir(targetDir, { withFileTypes: true });
            const files = [];
            for (const entry of entries) {
                const relativePath = path.join(currentDir, entry.name);
                if (entry.isDirectory()) {
                    const subFiles = await this.listProjectFiles(projectId, relativePath);
                    files.push(...subFiles);
                }
                else {
                    files.push(relativePath);
                }
            }
            return files;
        }
        catch (error) {
            // If directory doesn't exist yet, return empty list
            return [];
        }
    }
}
export const workspaceService = new WorkspaceService();
