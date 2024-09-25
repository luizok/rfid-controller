data "aws_iam_policy_document" "lambda_policy" {
    version = "2012-10-17"
    statement {
        sid = "Logging"
        effect = "Allow"
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = [
            "arn:aws:logs:*:*:*"
        ]
    }

    statement {
        sid = "PublishToTopic"
        effect = "Allow"
        actions = [
            "iot:Publish"
        ]
        resources = [
            "arn:aws:iot:${local.aws_region}:${local.aws_account_id}:topic/${var.topic_name}"
        ]
    }
}

resource "aws_iam_policy" "lambda_policy" {
    name = "${var.project-name}-lambda-policy"
    policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role" "send_to_topic_role" {
    name = "${var.project-name}-lambda-role"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {
    role       = aws_iam_role.send_to_topic_role.name
    policy_arn = aws_iam_policy.lambda_policy.arn
}

data "aws_iam_policy_document" "aws_iot_thing_policy" {
    version = "2012-10-17"
    statement {
        sid = "ClientConnectRestrictred"
        effect = "Allow"
        actions = [
            "iot:Connect"
        ]
        resources = [
            "arn:aws:iot:${local.aws_region}:${local.aws_account_id}:client/${var.client_id}"
        ]
    }
    statement {
        sid = "PublishReceivePermissions"
        effect = "Allow"
        actions = [
            "iot:Publish",
            "iot:Receive"
        ]
        resources = [
            "arn:aws:iot:${local.aws_region}:${local.aws_account_id}:topic/${var.topic_name}"
        ]
    }
    statement {
        sid = "SubscribePermissions"
        effect = "Allow"
        actions = [
            "iot:Subscribe"
        ]
        resources = [
            "arn:aws:iot:${local.aws_region}:${local.aws_account_id}:topicfilter/${var.topic_name}"
        ]
    }
}

resource "aws_iot_policy" "thing" {
    name = "${var.project-name}-thing-policy"
    policy = data.aws_iam_policy_document.aws_iot_thing_policy.json
}
