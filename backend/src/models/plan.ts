export interface PlanTask {
  id: string;
  title: string;
  description: string;
  phaseId: string;
  dependencies: string[];
  expectedOutput: string;
  acceptanceCriteria: string[];
  complexity: 'low' | 'medium' | 'high';
}

export interface PlanPhase {
  id: string;
  title: string;
  description: string;
  tasks: PlanTask[];
}

export interface DevelopmentPlanResult {
  phases: PlanPhase[];
}

export interface PlanningRequest {
  product: {
    name: string;
    description: string;
    coreFeatures: { name: string; description: string }[];
  };
  architecture: {
    pattern: string;
    layers: string[];
    modules: { name: string; responsibility: string }[];
  };
}
