module "sentinel_datadog" {
  source = "./modules/datadog"
}

# resource "aws_sqs_queue" "sentinel_fila_principal" {
#   # Nome da fila
#   name = "sentinel-fila-principal"
#   # Tempo de espera da mensagem (segundos)
#   delay_seconds = 0
#   # Tempo de vida da mensagem (segundos)
#   message_retention_seconds = 86400
#   # Política de recebimento de mensagens
#   receive_wait_time_seconds = 10

#   # Configuração de redrive policy para fila de mensagens mortas
#   redrive_policy = jsonencode({
#     deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
#     maxReceiveCount     = 4
#   })

#   # Tags para identificação da fila
#   tags = {
#     Name        = "sentinel-fila-principal"
#     Project = "sentinel"
#   }
# }

# resource "aws_sqs_queue" "sentinel_fila_dlq" {
#   name = "sentinel-fila-dlq"
# }

# resource "aws_dynamodb_table" "sentinel_dynamodb_table" {
#   name           = "sentinel-table"
#   hash_key       = "id"
#   billing_mode   = "PAY_PER_REQUEST" # PROVISIONED | PAY_PER_REQUEST
#   stream_enabled = true
#   #A opção `stream_view_type` é usada para especificar o tipo de visualização de dados que será incluído no fluxo de dados (stream) de uma tabela do DynamoDB.  
#   # Opções disponíveis:
#   # 1. `NEW_IMAGE`: Isso significa que apenas as versões atualizadas dos itens serão incluídas no fluxo de dados. 
#   # Ou seja, apenas os novos valores dos atributos serão registrados.
#   # 2. `OLD_IMAGE`: Isso significa que apenas as versões antigas dos itens serão incluídas no fluxo de dados.
#   # 3. `NEW_AND_OLD_IMAGES`: Isso significa que tanto as versões atualizadas quanto as antigas dos itens serão incluídas no fluxo de dados. 
#   # 4. `KEYS_ONLY`: Isso significa que apenas as chaves dos itens serão incluídas no fluxo de dados. Nenhum valor de atributo será registrado.
#   # Por exemplo, se você estiver interessado apenas nas alterações nos valores dos atributos, pode optar por `NEW_IMAGE` ou `OLD_IMAGE`. Se precisar de ambos, pode escolher `NEW_AND_OLD_IMAGES`. Se estiver interessado apenas nas chaves dos itens, pode escolher `KEYS_ONLY`.
#   stream_view_type = "NEW_IMAGES" # NEW_IMAGE | OLD_IMAGE | NEW_AND_OLD_IMAGES | KEYS_ONLY

#   attribute {
#     name = "id"
#     type = "S"
#   }

#   ttl {
#     attribute_name = "ttl" # Definir no codigo para 86400 que é 1 dia em segundos
#     enabled        = true
#   }

#   tags = {
#     Name = "sentinel"
#   }
# }
