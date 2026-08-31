export class SocketService {
    connections = new Map();
    addConnection(projectId, connection) {
        if (!this.connections.has(projectId)) {
            this.connections.set(projectId, new Set());
        }
        this.connections.get(projectId).add(connection);
        connection.socket.on('close', () => {
            this.connections.get(projectId)?.delete(connection);
            if (this.connections.get(projectId)?.size === 0) {
                this.connections.delete(projectId);
            }
        });
    }
    broadcast(event) {
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
    emit(projectId, type, payload) {
        this.broadcast({
            type,
            projectId,
            payload,
            timestamp: new Date().toISOString(),
        });
    }
}
export const socketService = new SocketService();
