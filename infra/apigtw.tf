resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project-name}-api"
  description = "API to orchestrate integration between Trello and Github"

  body = templatefile(local.openapi_path, {
    api-name                       = var.project-name,
    send_to_topic_lambda_arn       = aws_lambda_alias.alias.invoke_arn,
    apigtw_role_arn                = aws_iam_role.apigtw_role.arn,
    ssm_get_parameter_arn          = "arn:aws:apigateway:${local.aws_region}:ssm:action/GetParameter",
    ssm_put_parameter_arn          = "arn:aws:apigateway:${local.aws_region}:ssm:action/PutParameter",
    ssm_parameter_name             = aws_ssm_parameter.last_hash.name
  })


  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(file(local.openapi_path))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api-stage" {
  stage_name  = "dev"
  rest_api_id = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api-deployment.id
}