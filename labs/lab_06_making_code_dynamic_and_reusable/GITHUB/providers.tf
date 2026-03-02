terraform {
  required_version = "1.12.2"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.5.0"
    }
  }
}

provider "github" {}