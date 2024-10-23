terraform {  
  required_providers {  
    datadog = {  
      source  = "DataDog/datadog"  
      version = "3.44.1"

    }  
  }  
}  

provider "datadog" {  
  api_key = var.datadog_api_key  
  app_key = var.datadog_app_key  
  api_url = "https://api.us5.datadoghq.com"
}