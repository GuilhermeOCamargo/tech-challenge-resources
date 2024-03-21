resource "aws_sqs_queue" "tech_challenge_queue" {
  name                       = "${locals.project_name}-queue"
  fifo_queue = true
  delay_seconds              = 5
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.tech_challenge_dlq.arn
    maxReceiveCount     = 5
  })
  
}

resource "aws_sqs_queue" "tech_challenge_dlq" {
  name = "${locals.project_name}-dlq-queue"
}

resource "aws_sqs_queue_redrive_allow_policy" "tech_challenge_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.tech_challenge_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.tech_challenge_queue.arn]
  })
}