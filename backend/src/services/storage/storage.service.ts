import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export class StorageService {
  private readonly rootDir: string;

  constructor() {
    this.rootDir = path.resolve(__dirname, '../../../../data');
  }

  async initialize(): Promise<void> {
    const entities = [
      'users', 'projects', 'discovery', 'requirements',
      'architecture', 'plans', 'executions', 'builds',
      'tests', 'fixes'
    ];

    for (const entity of entities) {
      await fs.mkdir(path.join(this.rootDir, entity), { recursive: true });
    }
  }

  private getPath(entity: string, id: string): string {
    return path.join(this.rootDir, entity, `${id}.json`);
  }

  async save<T>(entity: string, id: string, data: T): Promise<void> {
    const filePath = this.getPath(entity, id);
    await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf-8');
  }

  async load<T>(entity: string, id: string): Promise<T | null> {
    const filePath = this.getPath(entity, id);
    try {
      const content = await fs.readFile(filePath, 'utf-8');
      return JSON.parse(content);
    } catch {
      return null;
    }
  }

  async list<T>(entity: string): Promise<T[]> {
    const entityDir = path.join(this.rootDir, entity);
    try {
      const files = await fs.readdir(entityDir);
      const results: T[] = [];
      for (const file of files) {
        if (file.endsWith('.json')) {
          const content = await fs.readFile(path.join(entityDir, file), 'utf-8');
          results.push(JSON.parse(content));
        }
      }
      return results;
    } catch {
      return [];
    }
  }

  async delete(entity: string, id: string): Promise<void> {
    const filePath = this.getPath(entity, id);
    try {
      await fs.unlink(filePath);
    } catch {}
  }
}

export const storageService = new StorageService();
