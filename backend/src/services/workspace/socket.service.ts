export type KindleEventType =
  | 'AGENT_STARTED'
  | 'AGENT_PROGRESS'
  | 'AGENT_STREAM_CHUNK'
  | 'FILE_GENERATED'
  | 'BUILD_RUNNING'
  | 'TEST_COMPLETED'
  | 'FIX_APPLIED'
  | 'TASK_FAILED'
  | 'SYSTEM_ERROR';

export interface KindleEvent {
  type: KindleEventType;
  projectId: string;
  payload: any;
  timestamp: string;
}

export class SocketService {
  private connections: Map<string, Set<any>> = new Map();

  addConnection(projectId: string, connection: any) {
    if (!this.connections.has(projectId)) {
      this.connections.set(projectId, new Set());
    }
    this.connections.get(projectId)!.add(connection);

    connection.socket.on('close', () => {
      this.connections.get(projectId)?.delete(connection);
      if (this.connections.get(projectId)?.size === 0) {
        this.connections.delete(projectId);
      }
    });
  }

  broadcast(event: KindleEvent) {
    const projectConnections = this.connections.get(event.projectId);
    if (projectConnections) {
      const message = JSON.stringify(event);
      for (const connection of projectConnections) {
        if (connection.socket.readyState === 1) { // OPEN
          connection.socket.send(message);
        }
      }
    }
  }

  emit(projectId: string, type: KindleEventType, payload: any) {
    this.broadcast({
      type,
      projectId,
      payload,
      timestamp: new Date().toISOString(),
    });
  }
}

export const socketService = new SocketService();
