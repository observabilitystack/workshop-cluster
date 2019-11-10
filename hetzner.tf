
terraform {
  required_version = "~> 0.12"
  
  # synchronize cluster state across trainers
  backend "remote" {
    organization = "o12stack"
    workspaces {
      name = "wjax-k8s-workshop"
    }

    # credentials are read from .terraformrc
  }
}

# We use random pet names to name each workshop
# server: numbers are boooooring
resource "random_pet" "server" {
  count       = "${var.instance_count}"
}

# This creates the workshop servers. Increase count
# to the number of participants
resource "hcloud_server" "workshop" {
  count       = "${var.instance_count}"
  name        = "${element(random_pet.server.*.id, count.index)}"
  image       = "centos-7"
  server_type = "cx51"   # 8cpu
  ssh_keys    = "${split(",",var.ssh_key_names)}"
}

# This creates a DNS record as a subdomain of
# the workshop domain that points to the host
resource "digitalocean_record" "hostname" {
  count  = "${var.instance_count}"
  domain = "${var.domain}"
  type   = "A"
  name   = "${element(hcloud_server.workshop.*.name, count.index)}"
  value  = "${element(hcloud_server.workshop.*.ipv4_address, count.index)}"
}

# This creates a wildcard subdomain pointing to
# the hostname. We use this for different services
# on our workshop servers later
resource "digitalocean_record" "wildcard" {
  count  = "${var.instance_count}"
  domain = "${var.domain}"
  type   = "CNAME"
  name   = "*.${element(hcloud_server.workshop.*.name, count.index)}"
  value  = "${element(hcloud_server.workshop.*.name, count.index)}.${var.domain}."
  depends_on = ["acme_certificate.certificate"]  # make sure CNAME wildcard does not block DNS challenge
}

# Create a private key to request TLS certs with
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# Register an account with ACMEs
resource "acme_registration" "account" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.acme_email_address}"
}

# Request wildcard TLS cert
resource "acme_certificate" "certificate" {
  count                     = "${var.instance_count}"
  account_key_pem           = "${acme_registration.account.account_key_pem}"
  common_name               = "*.${element(hcloud_server.workshop.*.name, count.index)}.${var.domain}"
  subject_alternative_names = ["${element(hcloud_server.workshop.*.name, count.index)}.${var.domain}"]

  dns_challenge {
    provider = "digitalocean"
  }
}

# write TLS certs into Ansible
resource "local_file" "certificates" {
    count    = "${var.instance_count}"
    content  = "${element(acme_certificate.certificate.*.certificate_pem, count.index)}${element(acme_certificate.certificate.*.issuer_pem, count.index)}${element(acme_certificate.certificate.*.private_key_pem, count.index)}"
    filename = "./roles/bootstrap/tls/files/${element(hcloud_server.workshop.*.name, count.index)}.${var.domain}.pem"
}

# Write a local Ansible inventory and refrein using terraform-inventory
# (as it is horribly slow)
resource "local_file" "write_inventory_for_ansible" {
    content     = "[workshop]\n${join("\n", random_pet.server.*.id)}"
    filename = "./inventory/inventory"
}
