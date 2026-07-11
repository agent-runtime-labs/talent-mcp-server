# ============================================================================
# IAM Policy for Bedrock Knowledge Base Access
# ============================================================================
resource "aws_iam_policy" "bedrock_kb_access" {
  name        = "${var.project_name}-${var.env}-bedrock-kb-access"
  description = "Allow Bedrock KB retrieve and retrieve_and_generate for ${var.project_name} in ${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockKBRetrieve"
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
        ]
      },
      {
        Sid    = "BedrockModelInvoke"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:GetInferenceProfile"
        ]
        Resource = toset([

          var.talent_kb_bedrock_model_arn,
          # Cross-region inference profiles (e.g. jp.*) route internally to foundation
          # models across multiple regions. Those calls are authorized separately.
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-*",
        ])
      }
    ]
  })
}

# ============================================================================
# IAM Policy for cross-account SSM access to KB IDs stored in KB repos
# Grants read to the talent KB SSM paths
# ============================================================================
resource "aws_iam_policy" "kb_id_ssm_access" {
  name        = "${var.project_name}-${var.env}-kb-id-ssm-access"
  description = "Allow reading KB IDs from cross-service SSM paths"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KBIdSSMAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter${var.talent_kb_ssm_kb_id_path}",
        ]
      }
    ]
  })
}
