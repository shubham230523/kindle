import { storageService } from '../storage/storage.service.js';
import { User } from '../../models/user.js';

export class AuthService {

  async createUser(userData: any): Promise<User> {
    const user: User = {
      id: `user_${Date.now()}`,
      email: userData.email,
      name: userData.name,
      createdAt: new Date().toISOString(),
    };

    await storageService.save('users', user.id, user);
    return user;
  }

  async findUserByEmail(email: string): Promise<User | null> {
    const users = await storageService.list<User>('users');
    return users.find(u => u.email === email) || null;
  }

  async findUserById(id: string): Promise<User | null> {
    return storageService.load<User>('users', id);
  }
}

export const authService = new AuthService();
