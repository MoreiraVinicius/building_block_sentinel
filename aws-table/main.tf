module "sentinel_datadog" {
  source = "./modules/datadog"
}

provider "aws" {  
  region = "us-east-1"  
}

resource "aws_dynamodb_table" "example" {  
  name           = "example-table"  
  hash_key       = "id_jornada"  
  range_key      = "id_transacao"

  ttl {  
    attribute_name = "TimeToLive"  # Attribute that stores TTL timestamps.  
    enabled        = true  
  }

  attribute {  
    name = "id_jornada"  
    type = "S"  
  }  

  attribute {  
    name = "id_transacao"  
    type = "S"  
  }  

  attribute {  
    name = "status_nome"  
    type = "S"  
  }  

  attribute {  
    name = "datahora"  
    type = "S"  
  }  

  attribute {  
    name = "descrição"  
    type = "S"  
  }  

  stream_enabled   = true  
  stream_view_type = "NEW_IMAGE"  

  billing_mode = "PAY_PER_REQUEST"  
}  

resource "aws_lambda_function" "dynamodb_stream_processor" {  
  filename         = "lambda_stream_processor.zip"
  function_name    = "dynamodb-stream-processor"  
  role             = aws_iam_role.lambda_exec_role.arn  
  handler          = "lambda_function.lambda_handler"  
  runtime          = "python3.8"  
}  

resource "aws_lambda_event_source_mapping" "dynamodb_event" {  
  event_source_arn = aws_dynamodb_table.example.stream_arn  
  function_name    = aws_lambda_function.dynamodb_stream_processor.arn  
  starting_position = "LATEST"  
}  

resource "aws_lambda_function" "sqs_processor" {  
  filename         = "lambda_sqs_processor.zip" 
  function_name    = "sqs-processor"  
  role             = aws_iam_role.lambda_exec_role.arn  
  handler          = "lambda_function.lambda_handler"  
  runtime          = "python3.8"  
}  

resource "aws_lambda_event_source_mapping" "sqs_event" {  
  event_source_arn  = aws_sqs_queue.queue.arn  
  function_name     = aws_lambda_function.sqs_processor.arn  
}  

resource "aws_iam_role" "lambda_exec_role" {  
  name = "lambda-exec-role"  

  assume_role_policy = jsonencode({  
    Version = "2012-10-17"  
    Statement = [  
      {  
        Action = "sts:AssumeRole"  
        Effect = "Allow"  
        Principal = {  
          Service = "lambda.amazonaws.com"  
        }  
      },  
    ]  
  })  
}  

# Apenas teste, substituir pelo modulo de acesso da empresa
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {  
  role       = aws_iam_role.lambda_exec_role.name  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"  
}  

# Apenas teste, substituir pelo modulo de acesso correspondente
resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {  
  role       = aws_iam_role.lambda_exec_role.name  
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"  
}  


# Apenas teste, substituir pelo modulo de acesso correspondente
resource "aws_iam_role_policy_attachment" "cloudwatch_put_metric_data" {  
  role       = aws_iam_role.lambda_exec_role.name  
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchPutMetricData"  
}  

# Apenas teste, substituir pelo modulo de acesso correspondente
resource "aws_iam_role_policy_attachment" "sqs_full_access" {  
  role       = aws_iam_role.lambda_exec_role.name  
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"  
}
