# Kindle Backend

A high-performance, multi-agent AI orchestration engine built with Fastify and TypeScript.

## Core Architecture

- **Task-Based Agent Graph**: Manages complex asynchronous execution of AI agents with dependency resolution and parallel wave processing.
- **Granular Decomposition Engine**: Splits high-level features into layer-specific sub-tasks for targeted code generation.
- **Hybrid AI Orchestrator**: Supports OpenRouter, Ollama, and a zero-load Deep Simulation Provider.
- **Intelligent MD5 Caching**: Persistent disk-based caching for AI responses to optimize API costs.
- **Fastify**: High-performance web framework for low-latency agent coordination.
- **Prisma & PostgreSQL**: Robust data persistence and schema management.
- **Pino**: Structured logging with enhanced traceability for multi-agent workflows.

## Environment Configuration

Key settings in `.env`:
- `OPENROUTER_API_KEY`: Set to `open-router-api-key` for Simulation Mode.
- `OPENROUTER_MODEL`: Set to `model` for Simulation Mode.
- `ENABLE_AI_CACHE`: Enable disk-based response caching.
- `MOCK_AI_RESPONSE_DELAY`: Simulated "thinking" time for mock responses.

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start development server (defaults to Simulation Mode):
   ```bash
   npm run dev
   ```
