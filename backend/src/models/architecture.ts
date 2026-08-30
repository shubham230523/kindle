export interface ArchitectureModule {
  name: string;
  responsibility: string;
  dependencies: string[];
}

export interface ArchitectureDependency {
  name: string;
  purpose: string;
  category: string;
}

export interface ArchitectureBlueprint {
  pattern: string;
  layers: string[];
  modules: ArchitectureModule[];
  dependencies: ArchitectureDependency[];
  dataFlow: string;
  apiStrategy: string;
}

export interface ArchitectureRequest {
  requirements: string[];
  technology: string;
  platforms: string[];
  backend: string;
  database: string;
}
