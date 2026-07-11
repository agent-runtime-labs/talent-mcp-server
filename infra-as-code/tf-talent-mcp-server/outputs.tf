output "bedrock_agentcore_gateway_id" {
  description = "Unique identifier of the Gateway"
  value       = aws_bedrockagentcore_gateway.agentcore.gateway_id
}

output "bedrock_agentcore_gateway_arn" {
  description = "ARN of the Gateway"
  value       = aws_bedrockagentcore_gateway.agentcore.gateway_arn
}

output "bedrock_agentcore_gateway_url" {
  description = "URL endpoint for the gateway"
  value       = aws_bedrockagentcore_gateway.agentcore.gateway_url
}