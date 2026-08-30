import { DiscoveryResult } from './discovery.js';
import { ProductSummary } from './product.js';
import { TechnologyRecommendation } from './technology.js';
import { ArchitectureBlueprint } from './architecture.js';
import { DevelopmentPlanResult } from './plan.js';

export enum PipelineStage {
  discovery = 'discovery',
  product = 'product',
  technology = 'technology',
  architecture = 'architecture',
  planning = 'planning',
  development = 'development',
  completed = 'completed',
  failed = 'failed'
}

export interface ProjectState {
  id: string;
  stage: PipelineStage;
  discovery?: DiscoveryResult;
  product?: ProductSummary;
  technology?: TechnologyRecommendation;
  architecture?: ArchitectureBlueprint;
  plan?: DevelopmentPlanResult;
  createdAt: string;
  updatedAt: string;
}
