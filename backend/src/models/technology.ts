export interface TechnologyRecommendation {
  recommendedTech: string;
  alternatives: string[];
  reasoning: string;
  tradeoffs: string[];
  recommendedBackend: string;
  recommendedDatabase: string;
  confidence: number;
}

export interface TechnologyRequest {
  requirements: string[];
  platforms: string[];
  preferredTech?: string;
  preferredBackend?: string;
  preferredDatabase?: string;
}
