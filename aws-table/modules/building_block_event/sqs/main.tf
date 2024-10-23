# Provider AWS para configurar a região onde os recursos serão criados
provider "aws" {
  region = var.aws_region
}

resource "aws_sqs_queue" "queue-error" {
  max_message_size           = local.queue.max_message_size
  message_retention_seconds  = local.queue.message_retention_seconds
  receive_wait_time_seconds  = local.queue.receive_wait_time_seconds
  visibility_timeout_seconds = local.queue.visibility_timeout_seconds
  kms_master_key_id          = local.queue.kms_master_key_id
  policy                     = data.aws_iam_policy_document.sqs_event_error_policy.json
  tags                       = local.queue.tags
}

resource "aws_sqs_queue" "queue-dlq" {
  name                       = "${local.queue.name}-dlq"
  fifo_queue                 = false
  delay_seconds              = local.queue.delay_seconds
  max_message_size           = local.queue.max_message_size
  message_retention_seconds  = local.queue.message_retention_seconds
  receive_wait_time_seconds  = local.queue.receive_wait_time_seconds
  visibility_timeout_seconds = local.queue.visibility_timeout_seconds
  kms_master_key_id          = local.queue.kms_master_key_id
  policy                     = data.aws_iam_policy_document.sqs_event_dlq_policy.json
  tags                       = local.queue.tags

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue-error.arn
    maxReceiveCount     = 1
  })

  depends_on = [
    aws_sqs_queue.queue-error
  ]
}

resource "aws_sqs_queue" "queue" {
  fifo_queue                 = false
  name                       = "${local.queue.name}-queue"
  delay_seconds              = local.queue.delay_seconds
  max_message_size           = local.queue.max_message_size
  message_retention_seconds  = local.queue.message_retention_seconds
  receive_wait_time_seconds  = local.queue.receive_wait_time_seconds
  visibility_timeout_seconds = local.queue.visibility_timeout_seconds
  kms_master_key_id          = local.queue.kms_master_key_id
  tags                       = local.queue.tags

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue-dlq.arn
    maxReceiveCount     = local.queue.max_receive_count
  })

  depends_on = [
    aws_sqs_queue.queue-dlq
  ]
}

resource "aws_sqs_queue_policy" "sqs_event_queue_policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.sqs_event_queue_policy.json

  depends_on = [
    aws_sqs_queue.queue
  ]
}

resource "aws_sns_topic_subscription" "sentinel_subscriptions" {
  for_each = var.subscriptions

  topic_arn            = each.value.topic_arn
  protocol             = "sqs"
  endpoint             = each.value.sqs_arn
  filter_policy        = each.value.filter_policy
  filter_policy_scope  = each.value.filter_policy_scope
  raw_message_delivery = each.value.raw_message_delivery
}
