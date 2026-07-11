env                   = "dev"
resource_region       = "us-east-1"
resource_region_short = "use1"
project_name          = "talent-mcp-server"
project_name_short    = "tms"
default_tags = {
  "project"     = "talent-mcp-server"
  "environment" = "dev"
  "deployment"  = "tf"
}

talent_kb_bedrock_model_arn = "arn:aws:bedrock:us-east-1:756375699536:inference-profile/global.anthropic.claude-haiku-4-5-20251001-v1:0"
talent_kb_ssm_kb_id_path    = "/dev/talent-knowledge-base/knowledge-base/tkb-kb-vector-index/id"
# arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-haiku-4-5-20251001-v1:0