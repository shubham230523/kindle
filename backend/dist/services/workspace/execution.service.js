import { storageService } from '../storage/storage.service.js';
export class ExecutionService {
    async recordExecution(execution) {
        await storageService.save('executions', execution.id, execution);
    }
    async getExecution(projectId, executionId) {
        return storageService.load('executions', executionId);
    }
    async listExecutions(projectId) {
        const all = await storageService.list('executions');
        return all
            .filter(e => e.projectId === projectId)
            .sort((a, b) => b.startedAt.localeCompare(a.startedAt));
    }
    createLog(message, details) {
        return {
            timestamp: new Date().toISOString(),
            message,
            details,
        };
    }
}
export const executionService = new ExecutionService();
