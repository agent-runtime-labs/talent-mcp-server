"""MCP tool implementations for the Talent Knowledge Base."""
import os

from utils.bedrock_kb_client import get_kb_id, retrieve_and_generate
from utils.logging_config import get_logger

logger = get_logger(__name__)


def _kb_config() -> dict:
    model_arn = os.getenv("TALENT_KB_BEDROCK_MODEL_ARN", "").strip()
    if not model_arn:
        raise ValueError("TALENT_KB_BEDROCK_MODEL_ARN environment variable is not set")
    return {
        "knowledgeBaseId": get_kb_id("TALENT_KB_SSM_KB_ID_PATH"),
        "modelArn": model_arn,
        "retrievalConfiguration": {
            "vectorSearchConfiguration": {
                "numberOfResults": 15,
            }
        },
        "generationConfiguration": {
            "inferenceConfig": {"textInferenceConfig": {"temperature": 0.2}},
        },
        "orchestrationConfiguration": {
            "queryTransformationConfiguration": {"type": "QUERY_DECOMPOSITION"},
        },
    }


def talent_kb(query: str) -> dict:
    logger.info("talent-kb: query=%s", query)
    try:
        result = retrieve_and_generate(query=query, kb_configuration=_kb_config())
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error("talent-kb failed: %s", str(e), exc_info=True)
        return {"status": "error", "error": str(e)}
