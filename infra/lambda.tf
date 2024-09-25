data "archive_file" "api" {
  type        = "zip"
  source_file = "../functions/send_to_topic.py"
  output_path = "../out/send_to_topic.zip"
}

resource "aws_lambda_function" "send_to_topic" {
  filename         = data.archive_file.api.output_path
  function_name    = "send_to_topic"
  role             = aws_iam_role.send_to_topic_role.arn
  handler          = "send_to_topic.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.api.output_base64sha256
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      TOPIC_NAME = var.topic_name
    }
  }
}