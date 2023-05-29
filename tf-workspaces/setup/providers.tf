terraform {
  # synchronize cluster state
  backend "remote" {
    organization = "o11ystack"
    workspaces {
      name = "setup-workshop-devopscon-berlin-2023"
    }
  }

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.28.1"
    }
  }
  required_version = ">= 1.2.7"
}

provider "digitalocean" {
  token   = var.do_token
}
