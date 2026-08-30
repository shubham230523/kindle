export interface FileModification {
  path: string;
  content: string;
  type: 'create' | 'modify' | 'delete';
}

export interface CodingResult {
  changes: FileModification[];
  explanation: string;
  confidence: number;
}

export interface CodingRequest {
  projectId: string;
  architecture: {
    pattern: string;
    layers: string[];
    modules: { name: string; responsibility: string }[];
    dependencies: { name: string; purpose: string }[];
  };
  task: {
    id: string;
    title: string;
    description: string;
    expectedOutput: string;
    acceptanceCriteria: string[];
  };
  existingFiles: string[];
  debugContext?: {
    rootCause: string;
    errorOutput: string;
    suggestedFix: string;
  };
}
