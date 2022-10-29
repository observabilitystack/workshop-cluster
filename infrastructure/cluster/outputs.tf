# ---------------------------------------------------------------------
# Write a local Ansible inventory
# ---------------------------------------------------------------------
locals {
  ansible_inventory = <<EOT
all:
  hosts:
    %{~for server in hcloud_server.workshop~}
    ${server.name}.${var.domain}:
      acme_cert: |
        ${indent(8, join("\n", [
  acme_certificate.certificate[server.name].certificate_pem,
  acme_certificate.certificate[server.name].issuer_pem,
  acme_certificate.certificate[server.name].private_key_pem
]))}
    %{~endfor~}
EOT
}

output "ansible_inventory" {
  value     = local.ansible_inventory
  sensitive = true
}
