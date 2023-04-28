terraform {
  # synchronize cluster state
  backend "remote" {
    organization = "o11ystack"
    workspaces {
      name = "workshop-devopscon-berlin-2023"
    }

    # credentials for terraform.io are read from .terraformrc
  }

  required_providers {
    acme = {
      source = "vancluever/acme"
      version = "~> 2.13.1"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.28.0"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.38.2"
    }
  }
  required_version = ">= 1.2.7"
}


# Configure the Hetzner Cloud Provider using
# a token from our enviornment
provider "hcloud" {
  token   = var.hcloud_token
}

# We use Digital Ocean for DNS
provider "digitalocean" {
  token   = var.do_token
}

# Obtain TLS certs from Let's Encrypt
provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
#  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
