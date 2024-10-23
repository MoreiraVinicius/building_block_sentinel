locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  sqs_event_queue_policy = {
    effect = "Allow"
    principals = [
      "*"
    ]
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility"
    ]
  }

  resources = [
    "*"
  ]

  sqs_topic_subscriptions_policy = {
    sid = "Sid${random_string.sns_sqs_access_id.result}"
    effect = "Allow"
    principals = [
      "*"
    ]
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:${local.aws_region}:${local.account_id}:*"
    ]
  }

  queue = {
    name = "sentinel-main"
    delay_seconds = var.queue.delay_seconds
    max_receive_count = var.queue.max_receive_count
    max_message_size = var.queue.max_message_size
    message_retention_seconds = var.queue.message_retention_seconds
    receive_wait_time_seconds = var.queue.receive_wait_time_seconds
    visibility_timeout_seconds = var.queue.visibility_timeout_seconds
    kms_master_key_id = var.queue.kms_master_key_id
    tags = merge(var.tags, { data_classification = var.queue.sqs_data_classification })
  }
}
