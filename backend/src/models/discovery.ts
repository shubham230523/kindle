export interface DiscoveryResult {
  understandingSummary: string;
  currentQuestion: string | null;
  discoveredRequirements: string[];
  missingInformation: string[];
  confidence: number;
  isDiscoveryComplete: boolean;
}

export interface DiscoveryRequest {
  idea: string;
  previousHistory?: { role: 'user' | 'assistant'; content: string; reasoning_details?: string }[];
}
