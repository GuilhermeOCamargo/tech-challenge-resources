data "aws_iam_policy_document" "tech_challenge_fargate_task_policy_doc" {
  statement {
    actions = [
      "sts:AssumeRole",

    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "tech_challenge_ecs_secret_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
      "s3:GetObject",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"
    ]
  }
}

resource "aws_iam_role" "tech_challenge_fargate_task_role" {
  tags               = var.tag
  name               = "${local.project_name}-fargate_task_role"
  assume_role_policy = data.aws_iam_policy_document.tech_challenge_fargate_task_policy_doc.json
}

resource "aws_iam_policy" "tech_challenge_policy" {
  tags   = var.tag
  name   = "${local.project_name}-fargate_task_policy"
  policy = data.aws_iam_policy_document.tech_challenge_ecs_secret_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "tech_challenge_task_attachment" {
  role       = aws_iam_role.tech_challenge_fargate_task_role.name
  policy_arn = aws_iam_policy.tech_challenge_policy.arn
}