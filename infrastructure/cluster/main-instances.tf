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
      hcloud_token             = var.hcloud_token,
      terraform_ssh_public_key = tls_private_key.terraform.public_key_openssh
    })
  }
  part {
    content_type = "text/cloud-config"
    content      = file("cloud-init/docker.yaml")
  }
}

resource "hcloud_server" "workshop" {
  for_each = var.server_names

  name        = each.key
  image       = "debian-11"
  server_type = "cpx41"
  location    = "hel1"
  ssh_keys    = [hcloud_ssh_key.root.name]
  user_data   = data.cloudinit_config.workshop.rendered

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
