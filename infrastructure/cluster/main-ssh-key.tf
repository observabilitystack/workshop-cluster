# ---------------------------------------------------------------------
# Root keys for server access (access denied later anyway)
# ---------------------------------------------------------------------
resource "tls_private_key" "root" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "hcloud_ssh_key" "root" {
  name       = "workshop-root"
  public_key = tls_private_key.root.public_key_openssh
}

# ---------------------------------------------------------------------
# SSH keys for terraform deploy user
# ---------------------------------------------------------------------
resource "tls_private_key" "terraform" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}
