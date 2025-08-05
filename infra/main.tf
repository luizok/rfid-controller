terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.7.0"
    }

    null = {
      source = "hashicrop/null"
      version = "~> 3.2.4"
    }

    archive = {
      source = "hashicrop/archive"
      version = "~> 2.7.1"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      project = var.project-name
    }
  }
}

provider "null" {

}

provider "archive" {

}

terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iot_endpoint" "thing_ats_mqtt" {
    endpoint_type = "iot:Data-ATS"
}

data "http" "AmazonRootCA1" {
    url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"
    method = "GET"
}

locals {
  aws_account_id              = data.aws_caller_identity.current.account_id
  aws_region                  = data.aws_region.current.region
  openapi_path                = "./openapi.tftpl.yaml"
}