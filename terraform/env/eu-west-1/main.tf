terraform {
  required_version = "1.1.6"

  backend "s3" {
    bucket  = "infra-as-code-joc"
    key     = "rds-scheduler/terraform.tfstate"
    region  = "eu-west-1"
    profile = "jose-rds-scheduler"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }

}

provider "aws" {
  #  allowed_account_ids = ["you can put here your aws account id"]
  default_tags {
    tags = {
      App       = local.app
      BuiltWith = "terraform"
      Stack     = local.stack
      TFCode    = data.external.repo_lookup.result.repo
    }
  }
  region = local.aws_region
}

data "external" "repo_lookup" {
  program = ["sh", "${path.root}/../../scripts/get-git-remote-url.sh"]
}
