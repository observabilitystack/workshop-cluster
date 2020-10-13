terraform {
  # synchronize cluster state across trainers
  backend "remote" {
    organization = "o12stack"
    workspaces {
      name = "workshop-devopscon-berlin-2020"
    }

    # credentials for terraform.io are read from .terraformrc
  }

  required_providers {
    acme = {
      source = "terraform-providers/acme"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}
