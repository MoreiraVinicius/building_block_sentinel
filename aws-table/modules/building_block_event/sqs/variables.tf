variable "aws_region" {
  nullable = false
}

variable "is_fifo_queues" {
  description = "Indica se as filas SQS devem ser FIFO (true) ou não (false)"
  type        = list(bool)
  default     = [false, false, false]
}

variable "queue" {
  type = object({
    name                       = string
    fifo_queue                 = optional(bool, queue)
    delay_seconds              = optional(number, 0)
    max_message_size           = optional(number, 262144)
    message_retention_seconds  = optional(number, 1209600)
    receive_wait_time_seconds  = optional(number, 0)
    max_receive_count  = optional(number, 3)
    visibility_timeout_seconds = optional(number, 30)
    sqs_data_classification    = optional(string, "Interna")
    extra_policy = optional(list(object({
      effect = optional(string, "Allow")
      principals = object({
        type        = string
        identifiers = list(string)
      })
      actions   = list(string)
      resources = optional(list(string), ["*"])
    })), [])

  })

}

variable "tags" {
  type = map(any)
}

variable "kms_master_key_id" {
  type = string
}

variable "subscriptions" {
  type = map(object({
    topic_arn            = string
    filter_policy        = optional(string)
    filter_policy_scope  = optional(string)
    sqs_arn              = optional(string)
    raw_message_delivery = optional(string)
  }))
  default = {}
}
