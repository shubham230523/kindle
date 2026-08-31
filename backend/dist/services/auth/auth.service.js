import { storageService } from '../storage/storage.service.js';
export class AuthService {
    async createUser(userData) {
        const user = {
            id: `user_${Date.now()}`,
            email: userData.email,
            name: userData.name,
            createdAt: new Date().toISOString(),
        };
        await storageService.save('users', user.id, user);
        return user;
    }
    async findUserByEmail(email) {
        const users = await storageService.list('users');
        return users.find(u => u.email === email) || null;
    }
    async findUserById(id) {
        return storageService.load('users', id);
    }
}
export const authService = new AuthService();
