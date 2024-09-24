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

locals {
  aws_account_id              = data.aws_caller_identity.current.account_id
  aws_region                  = data.aws_region.current.name
}