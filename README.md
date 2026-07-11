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

## Architecture

This MCP server is intended to act as the agent-facing retrieval layer for the Talent Knowledge Base. Agent clients authenticate with AWS Cognito-issued JWTs, call MCP tools through AWS Bedrock AgentCore Gateway, and the gateway invokes the Lambda-hosted MCP server to route semantic search and retrieval requests to the underlying Bedrock Knowledge Base managed by the `talent-knowledge-base` repository.

```mermaid
flowchart LR
    A[AI Agent Workflows]
    B[MCP Client]
    C[AWS Cognito\nJWT Token Issuer]

    subgraph AWS[AWS Cloud]
        D[Bedrock AgentCore Gateway\nJWT AuthN]
        E[AWS Lambda\nTalent MCP Server]
        F[Amazon Bedrock Knowledge Base]
        G[S3 Vectors Bucket and Index]
        H[S3 Source Bucket]
    end

    I[Talent Knowledge Base Repo\nCandidate Profiles]

    A --> B
    B -->|Request JWT| C
    C -->|Signed JWT| B
    B -->|MCP request + JWT| D
    D -->|Validate JWT| D
    D -->|Invoke| E
    E -->|Search and retrieve| F
    F --> G
    F --> H
    I --> H
    F -->|Relevant candidate context| E
    E -->|MCP tool result| D
    D -->|Authenticated response| B
    B --> A

    classDef client fill:#E8F1FF,stroke:#2563EB,stroke-width:2px,color:#0F172A;
    classDef server fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#78350F;
    classDef ai fill:#F3E8FF,stroke:#7C3AED,stroke-width:2px,color:#4C1D95;
    classDef storage fill:#ECFDF5,stroke:#059669,stroke-width:2px,color:#064E3B;
    classDef source fill:#FCE7F3,stroke:#DB2777,stroke-width:2px,color:#831843;

    class A,B client;
    class C source;
    class E server;
    class D,F ai;
    class G,H storage;
    class I source;
```

The diagram reflects the expected integration boundary for this repository. The Lambda function is the runtime target invoked by Bedrock AgentCore Gateway after Cognito JWT authentication succeeds. Tool schemas, Cognito user pool and app client configuration, Lambda deployment details, AWS Knowledge Base configuration, and candidate profile response contracts still need to be confirmed before MCP handlers are implemented.

## Local Testing

Use MCP Inspector to test the server once implementation and runtime configuration are available:

```bash
npx @modelcontextprotocol/inspector
```

## Status

Tool schemas, AWS Knowledge Base configuration, and candidate profile response contracts must be confirmed before implementing MCP handlers.
