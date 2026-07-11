"""Shared Bedrock Knowledge Base client — retrieve and retrieve_and_generate operations."""
import os

import boto3
from botocore.exceptions import ClientError

from utils.logging_config import get_logger

logger = get_logger(__name__)

_kb_id_cache: dict = {}
PROFILE_CATEGORY_METADATA_KEY = "profile_category"


def _profile_category_metadata(metadata: dict | None) -> dict:
    """Return only the metadata currently maintained for talent profiles."""
    if not metadata:
        return {}
    profile_category = metadata.get(PROFILE_CATEGORY_METADATA_KEY)
    if profile_category is None:
        return {}
    return {PROFILE_CATEGORY_METADATA_KEY: profile_category}


def get_kb_id(ssm_path_env: str = "SSM_KB_ID_PATH") -> str:
    """Resolve KB ID from the given SSM path environment variable."""
    ssm_path = os.getenv(ssm_path_env, "").strip()
    if not ssm_path:
        raise ValueError(f"{ssm_path_env} environment variable is not set")

    if ssm_path in _kb_id_cache:
        return _kb_id_cache[ssm_path]

    region = os.getenv("AWS_REGION", "ap-northeast-1")
    ssm = boto3.client("ssm", region_name=region)
    try:
        resp = ssm.get_parameter(Name=ssm_path, WithDecryption=True)
        kb_id = resp["Parameter"]["Value"]
        _kb_id_cache[ssm_path] = kb_id
        logger.info("Resolved KB ID from SSM %s", ssm_path)
        return kb_id
    except ClientError as e:
        raise RuntimeError(f"Failed to read KB ID from SSM {ssm_path}: {e}") from e


def retrieve(query: str, retrieval_configuration: dict, region: str | None = None) -> dict:
    """Semantic search against the knowledge base. Returns ranked chunks with relevance scores.

    `retrieval_configuration` must include a top-level `knowledgeBaseId` key alongside the
    standard Bedrock `retrievalConfiguration` fields — callers own the full config.
    """
    if region is None:
        region = os.getenv("AWS_REGION", "ap-northeast-1")

    kb_id = retrieval_configuration["knowledgeBaseId"]
    retrieval_config = {k: v for k, v in retrieval_configuration.items() if k != "knowledgeBaseId"}
    client = boto3.client("bedrock-agent-runtime", region_name=region)
    try:
        response = client.retrieve(
            knowledgeBaseId=kb_id,
            retrievalQuery={"text": query},
            retrievalConfiguration=retrieval_config,
        )
    except ClientError as e:
        raise RuntimeError(f"Bedrock KB retrieve failed: {e}") from e

    results = [
        {
            "content": item["content"]["text"],
            "score": item.get("score", 0.0),
            "source": item.get("location", {}),
            "metadata": _profile_category_metadata(item.get("metadata")),
        }
        for item in response.get("retrievalResults", [])
    ]
    return {"query": query, "results": results}


def retrieve_and_generate(query: str, kb_configuration: dict, region: str | None = None) -> dict:
    """RAG: retrieve relevant chunks then synthesise an answer with citations using the configured model.

    `kb_configuration` is passed directly as the Bedrock `knowledgeBaseConfiguration` field —
    callers own the full config including `knowledgeBaseId` and `modelArn`.
    """
    if region is None:
        region = os.getenv("AWS_REGION", "ap-northeast-1")

    client = boto3.client("bedrock-agent-runtime", region_name=region)
    try:
        response = client.retrieve_and_generate(
            input={"text": query},
            retrieveAndGenerateConfiguration={
                "type": "KNOWLEDGE_BASE",
                "knowledgeBaseConfiguration": kb_configuration,
            },
        )
    except ClientError as e:
        raise RuntimeError(f"Bedrock KB retrieve_and_generate failed: {e}") from e

    sources = []
    for citation in response.get("citations", []):
        for ref in citation.get("retrievedReferences", []):
            loc = ref.get("location", {})
            meta = _profile_category_metadata(ref.get("metadata"))
            sources.append({"location": loc, "metadata": meta})

    return {
        "answer": response["output"]["text"],
        "sources": sources,
        "session_id": response.get("sessionId", ""),
    }
