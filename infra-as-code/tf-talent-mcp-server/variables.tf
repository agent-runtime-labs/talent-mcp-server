variable "ecr_urls" {
  type        = string
  description = "Base64-encoded JSON object with ECR repository URLs for pre-built images (from CI/CD)."
  default     = ""
}

variable "bedrock_model_arn" {
  description = "ARN of the Bedrock model to use for the knowledge base."
  type        = string
  default     = "arn:aws:bedrock:us-east-1:756375699536:inference-profile/global.anthropic.claude-haiku-4-5-20251001-v1:0"
}

