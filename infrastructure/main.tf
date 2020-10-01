# ---------------------------------------------------------------------
# Create the workshop servers
# ---------------------------------------------------------------------
resource "hcloud_server" "workshop" {
  for_each    = var.server_names
  name        = each.key
  image       = "centos-8"
  server_type = "cx31"
  ssh_keys    = var.ssh_key_names
}

# This creates a DNS record as a subdomain of
# the workshop domain that points to the host
resource "digitalocean_record" "hostname" {
  for_each = hcloud_server.workshop
  domain = var.domain
  type   = "A"
  name   = each.value.name
  value  = each.value.ipv4_address
}

# This creates a wildcard subdomain pointing to
# the hostname. We use this for different services
# on our workshop servers later
resource "digitalocean_record" "wildcard" {
  for_each = hcloud_server.workshop
  domain = var.domain
  type   = "CNAME"
  name   = "*.${each.value.name}"
  value  = "${each.key}.${var.domain}."
}

# ---------------------------------------------------------------------
# Create ACME certs
# ---------------------------------------------------------------------

# Create a private key to request TLS certs with
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# Register an account with ACMEs
resource "acme_registration" "account" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.acme_email_address
}

# Request wildcard TLS cert
resource "acme_certificate" "certificate" {
  for_each                  = var.server_names
  account_key_pem           = acme_registration.account.account_key_pem
  common_name               = "*.${each.key}.${var.domain}"
  subject_alternative_names = [
    "${each.key}.${var.domain}"
  ]

  dns_challenge {
    provider = "digitalocean"
    config = {
      DO_AUTH_TOKEN = var.do_token
    }
  }
}

# ---------------------------------------------------------------------
# Write a local Ansible inventory
# ---------------------------------------------------------------------
locals {
  ansible_inventory = <<EOT
all:
  hosts:
    %{~ for server in hcloud_server.workshop ~}
    ${server.name}.${var.domain}:
      acme_cert: |
        ${indent(8, join("\n", [ 
          acme_certificate.certificate[server.name].certificate_pem, 
          acme_certificate.certificate[server.name].issuer_pem, 
          acme_certificate.certificate[server.name].private_key_pem 
        ]))}
    %{~ endfor ~}
EOT
}

output "ansible_inventory" {
  value = local.ansible_inventory
} 
