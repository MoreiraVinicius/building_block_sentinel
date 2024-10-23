variable "datadog_api_key" {  
  description = "Datadog API Key"  
  type        = string  
  default = ""
}  

variable "datadog_app_key" {  
  description = "Datadog Application Key"  
  type        = string  
  default = ""
}

# curl -H "Content-Type: application/json" \
#  -H "DD-API-KEY: <sua_api_key>" \
#   "https://api.datadoghq.com/api/v1/check_run"