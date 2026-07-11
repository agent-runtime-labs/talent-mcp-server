ARG PYTHON_VERSION=3.12

# ============================================
# Base stage
# ============================================
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-slim AS base

WORKDIR /workspace

RUN pip install --no-cache-dir \
    fastapi>=0.115.0 \
    fastmcp>=3.0.0b1 \
    mcp>=1.0.0 \
    boto3>=1.35.0 \
    uvicorn>=0.30.0

RUN useradd -m -u 1000 mcp_user

# ============================================
# Build stage
# ============================================
FROM base AS build

COPY --chown=mcp_user:mcp_user mcp-servers/talent-kb/src/ .
COPY --chown=mcp_user:mcp_user shared/utils/ /workspace/utils/

USER mcp_user
WORKDIR /workspace

# ============================================
# Localdev stage
# ============================================
FROM build AS localdev

USER root
RUN pip install --no-cache-dir watchdog
USER mcp_user

CMD ["python", "local_mcp.py", "--http"]

# ============================================
# Dist stage
# ============================================
FROM build AS dist

EXPOSE 8000
CMD ["python", "local_mcp.py", "--http"]
