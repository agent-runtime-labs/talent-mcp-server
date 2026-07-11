variable "docker_image_tag" {
  type        = string
  description = "Docker image tag for pre-built images (from CI/CD). Empty string uses computed hash."
  default     = ""
}

variable "ecr_urls" {
  type        = string
  description = "Base64-encoded JSON object with ECR repository URLs for pre-built images (from CI/CD)."
  default     = ""
}

variable "talent_kb_bedrock_model_arn" {
  description = "ARN of the Bedrock model to use for the knowledge base."
  type        = string
  default     = "arn:aws:bedrock:us-east-1:756375699536:inference-profile/global.anthropic.claude-haiku-4-5-20251001-v1:0"
}

variable "talent_kb_ssm_kb_id_path" {
  description = "SSM Parameter Store path for the knowledge base ID."
  type        = string
  default     = "/dev/talent-knowledge-base/knowledge-base/tkb-kb-vector-index/id"
}