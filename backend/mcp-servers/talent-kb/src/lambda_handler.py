"""AWS Lambda handler — serves as MCP tool endpoint for Bedrock AgentCore Gateway."""

import json
import logging

from tools.registry import TOOLS

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Event: %s", json.dumps(event))
    logger.info("Request ID: %s", getattr(context, "aws_request_id", None))

    try:
        resource = None
        if context and hasattr(context, "client_context") and context.client_context:
            extended = context.client_context.custom.get("bedrockAgentCoreToolName", "")
            if extended and "___" in extended:
                resource = extended.split("___")[1]
        if not resource:
            resource = event.get("tool_name") or event.get("toolName")

        parameters = event.get("parameters", {}) or event.get("params", {}) or event
        logger.info("Tool: %s | Params: %s", resource, json.dumps(parameters))

        if resource not in TOOLS:
            return {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({
                    "error": f"Tool '{resource}' not found",
                    "available_tools": list(TOOLS.keys()),
                }),
            }

        result = TOOLS[resource](**parameters)
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "tool_name": resource,
                "result": result,
                "request_id": getattr(context, "aws_request_id", None),
            }),
        }

    except Exception as e:
        logger.error("Error executing tool: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "error": str(e),
                "request_id": getattr(context, "aws_request_id", None),
            }),
        }
