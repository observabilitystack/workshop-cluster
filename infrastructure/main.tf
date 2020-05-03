
terraform {
  required_version = "~> 0.12"
  
  # synchronize cluster state across trainers
  backend "remote" {
    organization = "o12stack"
    workspaces {
      name = "workshop-cluster-test"
    }

    # credentials are read from .terraformrc
  }
}

# ---------------------------------------------------------------------
# Create the workshop servers
# ---------------------------------------------------------------------
resource "hcloud_server" "workshop" {
  for_each    = var.server_names
  name        = each.key
  image       = "centos-8"
  server_type = "cx51"   # 8cpu
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
  value  = each.value.ipv4_address
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
  }
}

# ---------------------------------------------------------------------
# Write a local Ansible inventory
# ---------------------------------------------------------------------

# Useful for WORKSHOP PREPARATION
#
# To just create the inventory file w/o creating servers:
#   terraform apply -target=local_file.write_inventory_for_ansible
#
# To see the assignment of participants and servers:
#   ansible-playbook server-2-participant.yml 
#resource "local_file" "write_inventory_for_ansible" {
#    content     = "[workshop]\n${join("\n", slice(var.server_names, 0, var.instance_count))}"
#    filename = "./inventory/inventory"
#}

# write TLS certs into Ansible
#resource "local_file" "certificates" {
#    count    = "${var.instance_count}"
#    content  = "${element(acme_certificate.certificate.*.certificate_pem, count.index)}${element(acme_certificate.certificate.*.issuer_pem, count.index)}${element(acme_certificate.certificate.*.private_key_pem, count.index)}"
#    filename = "./roles/bootstrap/tls/files/${element(hcloud_server.workshop.*.name, count.index)}.${var.domain}.pem"
#}

