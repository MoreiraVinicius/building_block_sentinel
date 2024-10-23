terraform {  
  required_providers {  
    datadog = {  
      source  = "DataDog/datadog"  
      version = "3.44.1"
    }  
    aws = {  
      source  = "hashicorp/aws"  
      version = ">= 4.40.0"  
    }  
  }  
}  

provider "aws" {
  region = var.aws_region
}