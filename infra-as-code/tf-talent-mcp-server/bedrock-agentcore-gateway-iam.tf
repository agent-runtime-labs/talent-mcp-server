resource "aws_iam_role" "bedrock_agentcore_gateway_service_role" {
  name = "${data.aws_caller_identity.current.account_id}-${var.project_name_short}-${var.resource_region_short}-gtwy-bedrock-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock-agentcore.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_agentcore_lambda_invoke_policy" {
  name = "${var.project_name_short}BedrockAgentCoreLambdaInvokePolicy"
  role = aws_iam_role.bedrock_agentcore_gateway_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:${var.resource_region}:${data.aws_caller_identity.current.account_id}:function:*"
      }
    ]
  })
}
