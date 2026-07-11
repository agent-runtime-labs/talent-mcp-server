module "tf_lambda_talent_kb_mcp_tool" {
  source             = "../tf-modules/aws/tf-lambda"
  env                = var.env
  region             = var.resource_region
  lambda_name        = "${var.project_name}-kb-mcp-tool"
  lambda_src_dir     = "mcp-servers/talent-kb"
  lambda_timeout     = 300
  lambda_memory_size = 1024

  skip_docker_build = var.docker_image_tag != "" ? true : false
  docker_image_tag  = var.docker_image_tag

  skip_ecr_creation  = try(local.ecr_urls_decoded["mcp-server-talent-kb"], "") != "" ? true : false
  ecr_repository_url = try(local.ecr_urls_decoded["mcp-server-talent-kb"], "")

  additional_iam_policy_arns = [
    aws_iam_policy.bedrock_kb_access.arn,
    aws_iam_policy.kb_id_ssm_access.arn,
  ]

  environment_variables = {
    ENV                         = var.env
    TALENT_KB_BEDROCK_MODEL_ARN = var.talent_kb_bedrock_model_arn
    TALENT_KB_SSM_KB_ID_PATH    = var.talent_kb_ssm_kb_id_path
  }
}