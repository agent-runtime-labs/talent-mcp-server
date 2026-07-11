# talent-mcp-server

MCP server for searching the Talent Knowledge Base from agent workflows.

## Use Case

This service lets an AI agent find relevant candidate knowledge without knowing where or how the Talent Knowledge Base is stored.

It exposes MCP tools that are expected to support:

- Semantic search across candidate profiles and talent-related documents.
- Retrieval of the most relevant profile or document details for a given hiring question.
- Integration through AWS Bedrock AgentCore Gateway.

Typical questions this server should help answer:

- "Find candidates with strong GenAI and AWS experience."
- "Retrieve context for this candidate before outreach."
- "Show profiles matching a backend platform engineering role."

## Local Testing

Use MCP Inspector to test the server once implementation and runtime configuration are available:

```bash
npx @modelcontextprotocol/inspector
```

## Status

Tool schemas, AWS Knowledge Base configuration, and candidate profile response contracts must be confirmed before implementing MCP handlers.
