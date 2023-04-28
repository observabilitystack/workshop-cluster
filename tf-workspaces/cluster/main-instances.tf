# ---------------------------------------------------------------------
# Create the workshop servers
# ---------------------------------------------------------------------
data "cloudinit_config" "workshop" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("cloud-init/default.yaml", {
      workshop_domain          = var.domain,
      hcloud_token             = var.hcloud_token_ro,
      terraform_ssh_public_key = tls_private_key.terraform.public_key_openssh
    })
  }
  part {
    content_type = "text/cloud-config"
    content      = file("cloud-init/docker.yaml")
  }
}

data "hcloud_image" "image" {
  name              = "debian-11"
  with_architecture = "x86"
  most_recent       = true
}

resource "hcloud_server" "workshop" {
  for_each = local.instance_server_names

  name        = each.key
  image       = data.hcloud_image.image.id
  server_type = "cpx21"
  location    = "hel1"
  ssh_keys    = [hcloud_ssh_key.root.name]
  user_data   = data.cloudinit_config.workshop.rendered
  labels = {
    "service" : "workshop"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait --long"
    ]

    connection {
      type        = "ssh"
      user        = "terraform"
      host        = self.ipv4_address
      private_key = tls_private_key.terraform.private_key_pem
    }
  }
}

# This creates a DNS record as a subdomain of
# the workshop domain that points to the host
resource "digitalocean_record" "hostname" {
  for_each = hcloud_server.workshop

  domain = var.domain
  type   = "A"
  ttl    = 300
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
  ttl    = 300
  name   = "*.${each.value.name}"
  value  = "${each.key}.${var.domain}."
}

# ---------------------------------------------------------------------
# Write an Ansible inventory
# ---------------------------------------------------------------------
locals {
  ansible_inventory = <<EOT
all:
  hosts:
    %{~for server in hcloud_server.workshop~}
    ${server.name}.${var.domain}:
      ansible_host: ${server.ipv4_address}
      hcloud_token_ro: ${var.hcloud_token_ro}
      acme_cert: |
        ${indent(8, join("\n", [
  acme_certificate.certificate[server.name].certificate_pem,
  acme_certificate.certificate[server.name].issuer_pem
]))}
      acme_private_key: |
        ${indent(8, acme_certificate.certificate[server.name].private_key_pem)}
    %{~endfor~}
EOT
}

output "ansible_inventory" {
  value     = local.ansible_inventory
  sensitive = true
}
