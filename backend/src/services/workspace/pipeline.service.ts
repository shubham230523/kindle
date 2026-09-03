import { promises as fs } from 'fs';
import path from 'path';
import { workspaceService } from './workspace.service.js';
import { discoveryAgent } from '../ai/discovery.agent.js';
import { productAgent } from '../ai/product.agent.js';
import { technologyAgent } from '../ai/technology.agent.js';
import { architectureAgent } from '../ai/architecture.agent.js';
import { planningAgent } from '../ai/planning.agent.js';
import { developmentOrchestrator } from './orchestrator.service.js';
import { ProjectState, PipelineStage } from '../../models/pipeline.js';
import { storageService } from '../storage/storage.service.js';

export class KindlePipelineService {

  async getProjectState(projectId: string, userId: string): Promise<ProjectState | null> {
    const state = await storageService.load<ProjectState>('projects', projectId);
    if (state && state.userId !== userId) {
      throw new Error('Unauthorized access to project');
    }
    return state;
  }

  async saveProjectState(state: ProjectState): Promise<void> {
    state.updatedAt = new Date().toISOString();
    await storageService.save('projects', state.id, state);
  }

  async initializeProject(id: string, idea: string, userId: string): Promise<ProjectState> {
    const now = new Date().toISOString();
    const state: ProjectState = {
      id,
      userId,
      stage: PipelineStage.discovery,
      createdAt: now,
      updatedAt: now,
    };

    // Create workspace if it doesn't exist
    await workspaceService.createProjectWorkspace({
      id,
      name: 'Sparked Project',
      description: idea,
      technology: 'pending',
      createdAt: now,
    });

    // Run first discovery pass
    const discoveryOutput = await discoveryAgent.processIdea(idea);
    state.discovery = discoveryOutput.result;
    await this.saveProjectState(state);
    return state;
  }

  async advancePipeline(projectId: string, userId: string, userInput?: string, isLocalMode: boolean = false): Promise<ProjectState> {
    const state = await this.getProjectState(projectId, userId);
    if (!state) throw new Error('Project state not found');

    const delegate = isLocalMode;

    switch (state.stage) {
      case PipelineStage.discovery:
        if (userInput && !state.discovery?.isDiscoveryComplete) {
          const discoveryOutput = await discoveryAgent.processIdea(userInput, []); // Would need full history in production
          state.discovery = discoveryOutput.result;
        }

        if (state.discovery?.isDiscoveryComplete) {
          state.stage = PipelineStage.product;
          state.product = await productAgent.generateProductSummary({
            discoveryResult: state.discovery
          });
        }
        break;

      case PipelineStage.product:
        state.stage = PipelineStage.technology;
        state.technology = await technologyAgent.recommendStack({
          requirements: state.discovery!.discoveredRequirements,
          platforms: ['android', 'ios', 'web'] // Mock platforms for now
        });
        break;

      case PipelineStage.technology:
        state.stage = PipelineStage.architecture;
        state.architecture = await architectureAgent.generateBlueprint({
          requirements: state.discovery!.discoveredRequirements,
          technology: state.technology!.recommendedTech,
          platforms: ['android', 'ios', 'web'],
          backend: state.technology!.recommendedBackend,
          database: state.technology!.recommendedDatabase
        }, delegate);
        break;

      case PipelineStage.architecture:
        state.stage = PipelineStage.planning;
        state.plan = await planningAgent.generatePlan({
          product: {
            name: state.product!.nameSuggestions[0],
            description: state.product!.description,
            coreFeatures: state.product!.coreFeatures
          },
          architecture: {
            pattern: state.architecture!.pattern,
            layers: state.architecture!.layers,
            modules: state.architecture!.modules
          }
        }, delegate);
        break;

      case PipelineStage.planning:
        state.stage = PipelineStage.development;
        // Start background development orchestration
        this.runFullDevelopment(state, isLocalMode);
        break;

      default:
        // Already at final stage or development in progress
        break;
    }

    await this.saveProjectState(state);
    return state;
  }

  private async runFullDevelopment(state: ProjectState, isLocalMode: boolean = false) {
    if (!state.plan) return;

    for (const phase of state.plan.phases) {
      for (const task of phase.tasks) {
        await developmentOrchestrator.runTask(state.id, task, state.architecture, isLocalMode);
      }
    }

    state.stage = PipelineStage.completed;
    await this.saveProjectState(state);
  }
}

export const kindlePipeline = new KindlePipelineService();
