# Kindle 🔥

### AI-Powered Application Creation Platform

**Kindle** is an AI-powered application builder that transforms an idea into a complete software project.

Users describe what they want to build, and Kindle uses AI agents to understand the requirements, ask the right questions, recommend technologies, create an implementation plan, generate the application, build it, test it, and iteratively fix issues.

> **Describe your idea. Kindle brings it to life.**

## 🚧 Development Status

**Kindle is currently under active development.**

The architecture, features, supported technologies, and AI workflows are evolving as the project progresses.

## ✨ Vision

Kindle aims to provide an end-to-end agentic development workflow:

```text
Idea
 ↓
AI Discovery & Reverse Prompting
 ↓
Requirements
 ↓
Tech Stack & Platform Selection
 ↓
Architecture
 ↓
Development Plan
 ↓
Code Generation
 ↓
Build
 ↓
Automated Testing
 ↓
Bug Fixing
 ↓
Verified Application
```

## 🤖 AI Agents

Kindle is being designed around specialized agents:

* **Discovery Agent** — Understands the idea and identifies missing requirements.
* **Product Agent** — Defines features, screens, and product requirements.
* **Architecture Agent** — Designs the architecture based on the selected technology.
* **Technology Agent** — Recommends frameworks, libraries, databases, and tools.
* **Coding Agent** — Generates and modifies the application code.
* **Build Agent** — Builds the application and analyzes build failures.
* **Testing Agent** — Tests the generated application.
* **Debug Agent** — Investigates failures and iteratively fixes them.

Initial AI experimentation uses **Gemma** and **OpenAI gpt-oss models through Ollama Cloud**.

## 🛠️ Kindle Platform

Kindle itself is being developed using:

* Flutter / Dart
* Node.js / TypeScript
* PostgreSQL
* Ollama Cloud
* Gemma
* OpenAI gpt-oss

## ⚙️ User-Controlled Application Generation

Kindle will not force users into a single technology stack.

Users can choose:

### Technology

Examples:

* Flutter
* React Native
* Native Android
* Native iOS
* Web technologies
* Other supported stacks

### Target Platform

Users can choose between:

* 📱 Android
* 🍎 iOS
* 🌐 Web
* 💻 Windows
* 🍎 macOS
* 🐧 Linux
* 📲 Multiple platforms

For example:

```text
Technology: Flutter
Platforms: Android + iOS + Web
```

or:

```text
Technology: Kotlin
Platform: Android
```

or:

```text
Technology: React Native
Platforms: Android + iOS
```

Kindle adapts the architecture, implementation plan, dependencies, and testing strategy according to these choices.

## 🎯 Initial MVP

The initial MVP will focus on proving the complete agentic workflow:

**Idea → Requirements → Technology Selection → Architecture → Code → Build → Test → Fix**

The generated project should eventually include:

* Source code
* Platform-specific builds
* Documentation
* Architecture information
* Development plan
* Test results

## 🗺️ Roadmap

* [x] Project concept
* [ ] AI reverse-prompting
* [ ] Requirement generation
* [ ] App naming & product definition
* [ ] Technology & platform selection
* [ ] Architecture generation
* [ ] Development plan generation
* [ ] Code generation
* [ ] Automated builds
* [ ] Automated testing
* [ ] Self-healing/debugging
* [ ] Multi-framework support
* [ ] Multi-platform builds
* [ ] Source code & documentation export

---

**Kindle is an experimental project exploring how AI agents can transform software development from an idea into a buildable, tested, and deliverable application — while allowing users to choose how and where their application is built.**
