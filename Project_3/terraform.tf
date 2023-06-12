terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Luca_fus"
    workspaces {
      name = "Project"
    }
  }



  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}
