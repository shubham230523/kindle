import { buildService } from '../workspace/build.service.js';
import { BuildResult } from '../../models/build.js';

export class BuildAgent {

  async buildProject(projectId: string, technology: string): Promise<BuildResult> {
    let command = '';
    let args: string[] = [];
    let platform = 'generic';

    // Determine build command based on technology
    const tech = technology.toLowerCase();

    if (tech.includes('flutter')) {
      command = 'flutter';
      args = ['build', 'apk', '--debug']; // Simple apk build for verification
      platform = 'android';
    } else if (tech.includes('web') || tech.includes('react') || tech.includes('node')) {
      command = 'npm';
      args = ['run', 'build'];
      platform = 'web';
    } else {
      command = 'echo';
      args = ['"Build not implemented for this technology"'];
    }

    return buildService.runBuild(projectId, command, args, platform);
  }
}

export const buildAgent = new BuildAgent();
