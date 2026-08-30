# Kindle Backend

A high-performance Node.js backend built with Fastify and TypeScript.

## Architecture

- **Fastify**: Web framework focused on performance and low overhead.
- **TypeScript**: Type-safe development with ESM support (`NodeNext`).
- **Pino**: Structured logging with `pino-pretty` for development.
- **Centralized Error Handling**: Custom error handler plugin for consistent API responses.
- **API Versioning**: Foundation set with `/api/v1` prefix.

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start development server:
   ```bash
   npm run dev
   ```

3. Build for production:
   ```bash
   npm run build
   ```

4. Start production server:
   ```bash
   npm start
   ```

## API Endpoints

- `GET /api/v1/health`: Returns system health, timestamp, and uptime.
