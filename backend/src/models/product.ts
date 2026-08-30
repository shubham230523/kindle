export interface FeatureDefinition {
  name: string;
  description: string;
  priority: 'high' | 'medium' | 'low';
}

export interface UserStoryDefinition {
  actor: string;
  action: string;
  benefit: string;
}

export interface ProductSummary {
  nameSuggestions: string[];
  description: string;
  targetUsers: string[];
  coreFeatures: FeatureDefinition[];
  optionalFeatures: FeatureDefinition[];
  userStories: UserStoryDefinition[];
}

export interface ProductRequest {
  discoveryResult: {
    understandingSummary: string;
    discoveredRequirements: string[];
  };
}
