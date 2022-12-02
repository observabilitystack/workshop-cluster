# ---------------------------------------------------------------------
# Create ACME certs
# ---------------------------------------------------------------------

# Create a private key to request TLS certs with
resource "tls_private_key" "private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# Register an account with ACMEs
resource "acme_registration" "account" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.acme_email_address
}

# Request wildcard TLS cert
resource "acme_certificate" "certificate" {
  for_each = toset(var.server_names)

  key_type        = "P256"
  account_key_pem = acme_registration.account.account_key_pem
  common_name     = "*.${each.key}.${var.domain}"
  subject_alternative_names = [
    "${each.key}.${var.domain}"
  ]
  revoke_certificate_on_destroy = false

  dns_challenge {
    provider = "digitalocean"
    config = {
      DO_AUTH_TOKEN = var.do_token
    }
  }

  lifecycle {
    ignore_changes = [
      dns_challenge
    ]
  }
}
