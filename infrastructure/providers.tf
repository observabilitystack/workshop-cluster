# Configure the Hetzner Cloud Provider using
# a token from our enviornment
provider "hcloud" {
  version = "~> 1.16"
  token   = var.hcloud_token
}

# We use Digital Ocean for DNS
provider "digitalocean" {
  version = "~> 1.17"
  token   = var.do_token
}

# we use the random provider to assign
# random hostnames
provider "random" {
  version = "~> 2.2"
}

# Obtain TLS certs from Let's Encrypt
provider "acme" {
  version = "~> 1.5"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
#  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

# Use this to create ACME tls private keys
provider "tls" {
  version = "~> 2.1"
}

# Use this to write ACME certs to file
provider "local" {
  version = "~> 1.4"
}