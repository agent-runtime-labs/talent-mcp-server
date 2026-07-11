locals {
  api_spec_talent_kb_mcp_tools   = jsondecode(file("../../backend/mcp-servers/talent-kb/api_spec.json"))


  # Merge all tools from all KB servers keyed by name
  all_mcp_tools = merge(
    { for tool in local.api_spec_talent_kb_mcp_tools : tool.name => merge(tool, { lambda_arn = module.tf_lambda_talent_kb_mcp_tool.lambda_function_arn }) },  )
}

resource "aws_bedrockagentcore_gateway" "agentcore" {
  name     = "${var.project_name}-${var.env}-gateway"
  role_arn = aws_iam_role.bedrock_agentcore_gateway_service_role.arn

  authorizer_type = "CUSTOM_JWT"
  authorizer_configuration {
    custom_jwt_authorizer {
      discovery_url    = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_vpcJtdeVX/.well-known/openid-configuration"
      allowed_scopes = ["default-m2m-resource-server-5f796/read"]
    }
  }

  protocol_type = "MCP"
}

resource "aws_ssm_parameter" "agentcore_gateway_id" {
  name        = "${local.ssm_param_prefix}/gateway-id"
  description = "Bedrock AgentCore Gateway ID for ${var.project_name} in ${var.env}"
  type        = "String"
  value       = aws_bedrockagentcore_gateway.agentcore.gateway_id
}

resource "aws_bedrockagentcore_gateway_target" "agentcore" {
  for_each           = local.all_mcp_tools
  name               = replace(each.key, "_", "-")
  gateway_identifier = aws_bedrockagentcore_gateway.agentcore.gateway_id
  description        = each.value.description

  credential_provider_configuration {
    gateway_iam_role {}
  }

  target_configuration {
    mcp {
      lambda {
        lambda_arn = each.value.lambda_arn

        tool_schema {
          inline_payload {
            name        = each.value.name
            description = each.value.description

            input_schema {
              type        = lookup(each.value.inputSchema, "type", "object")
              description = lookup(each.value.inputSchema, "description", null)

              dynamic "property" {
                for_each = lookup(each.value.inputSchema, "properties", {})

                content {
                  name        = property.key
                  type        = lookup(property.value, "type", "string")
                  description = lookup(property.value, "description", null)
                  required    = contains(lookup(each.value.inputSchema, "required", []), property.key)

                  dynamic "items" {
                    for_each = lookup(property.value, "type", "") == "array" && lookup(property.value, "items", null) != null ? [property.value.items] : []
                    content {
                      type        = lookup(items.value, "type", "string")
                      description = lookup(items.value, "description", null)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
