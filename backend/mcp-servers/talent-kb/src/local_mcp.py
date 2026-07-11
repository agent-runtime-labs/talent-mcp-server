import logging
import os
import sys

from fastmcp import FastMCP
from tools.registry import TOOLS

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

mcp = FastMCP("Talent Knowledge Base MCP Server")

for tool_name, tool_func in TOOLS.items():
    mcp.tool(tool_func)
    logger.info("Registered tool: %s", tool_name)

if __name__ == "__main__":
    logger.info("Starting MCP server with tools: %s", list(TOOLS.keys()))

    if "--http" in sys.argv:
        host = "0.0.0.0" if os.getenv("ENV") == "local" else "127.0.0.1"
        logger.info("Starting server in HTTP mode on http://%s:8000", host)
        mcp.run(transport="http", host=host, port=8000)
    else:
        logger.info("Starting server in stdio mode")
        mcp.run()
