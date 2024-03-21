# Provides an SES email identity resource
resource "aws_ses_email_identity" "tech_challenge_ses_email_identity" {
  email = var.ses_email
}