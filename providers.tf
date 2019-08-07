# Configure the Hetzner Cloud Provider using
# a token from our enviornment
provider "hcloud" {
  version = "~> 1.10"
}

# We use Digital Ocean for DNS
provider "digitalocean" {
  version = "~> 1.4"
}

# we use the random provider to assign
# random hostnames
provider "random" {
  version = "~> 2.1"
}

# Obtain TLS certs from Let's Encrypt
provider "acme" {
  version = "~> 1.3"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
#  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

# Use this to create ACME tls private keys
provider "tls" {
  version = "~> 2.0"
}

# Use this to write ACME certs to file
provider "local" {
  version = "~> 1.2"
}