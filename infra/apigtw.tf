resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project-name}-api"
  description = "API to orchestrate integration between Trello and Github"

  body = templatefile(local.openapi_path, {
    api-name                       = var.project-name,
    send_to_topic_lambda_arn       = aws_lambda_function.send_to_topic.invoke_arn,
    lambda_invoke_role_arn         = aws_iam_role.lamba_invoke_role.arn
  })


  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev"
  triggers = {
    redeployment = sha1(file(local.openapi_path))
  }
}