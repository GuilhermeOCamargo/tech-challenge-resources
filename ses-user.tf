
# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_user" "tech_challenge_ses_iam_user" {
  name = "tech-challenge-ses-user"
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_access_key" "tech_challenge_ses_iam_access_key" {
  user = aws_iam_user.tech_challenge_ses_iam_user.name
}

# Attaches a Managed IAM Policy to SES Email Identity resource
data "aws_iam_policy_document" "tech_challenge_ses_policy_document" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }
}

# Provides an IAM policy attached to a user.
resource "aws_iam_policy" "tech_challenge_ses_policy" {
  name   = "${local.project_name}-ses-iam-user-policy"
  policy = data.aws_iam_policy_document.tech_challenge_ses_policy_document.json
}

# Attaches a Managed IAM Policy to an IAM user
resource "aws_iam_user_policy_attachment" "tech_challenge_ses_user_policy" {
  user       = aws_iam_user.tech_challenge_ses_iam_user.name
  policy_arn = aws_iam_policy.tech_challenge_ses_policy.arn
}