# AGENTS

## Project Purpose
This is an **MCP server** (Model Context Protocol) that exposes semantic search and retrieval tools for the Talent Knowledge Base. It's powered by AWS Bedrock AgentCore Gateway and integrates with the broader agent-runtime-labs ecosystem (see sister repos: `talent-knowledge-base`, `automation-hub`, `aws-commons`).

## Current State
- Repository is at initial commit; no source code, build artifacts, dependencies, or CI config yet exist.
- Only the README and this guidance file are committed.
- Before implementing, coordinate with `talent-knowledge-base` team on:
  - Exact MCP tool schema and signatures
  - AWS Bedrock Knowledge Base configuration and endpoints
  - Candidate profile structure that MCP tools will search/retrieve

## Workspace Conventions
- Related projects use `AGENTS.md` for agent guidance and `opencode.json` for OpenCode configuration.
- The `automation-hub` project (see `../automation-hub/AGENTS.md`) demonstrates the workspace patterns for OpenCode integration.
- Code changes should follow conventions established in `talent-knowledge-base` (see `../talent-knowledge-base/CLAUDE.md` for behavioral guardrails: think before coding, simplicity first, surgical changes, goal-driven execution).

## Before Starting Implementation
1. **Inspect existing MCP servers and tools** in automation-hub and aws-commons to understand how semantic search tools are exposed.
2. **Coordinate on data contracts**: Confirm the exact structure of Talent Knowledge Base retrieval responses and required search parameters.
3. **Verify AWS setup**: Confirm Bedrock AgentCore Gateway credentials, Knowledge Base ID, and deployment region are documented in team setup guides.
4. **No speculative code**: Do not implement tool definitions, MCP protocol handlers, or AWS clients without explicit requirements.

## Git & Testing
- Do not assume build, test, lint, or package-manager config exists until manifests are added.
- Run `git status` before making changes; check for untracked or team-local files outside the committed tree.
- After any implementation, ensure MCP protocol compliance via local testing and integration with automation-hub or related systems.
