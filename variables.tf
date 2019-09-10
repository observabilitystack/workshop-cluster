variable "instance_count" {
  default = "1"
}

variable "domain" {
  default = "k8s.o12stack.org"
}

variable "acme_email_address" {
  default = "nobody@o12stack.org"
}

# names/references of all the root keys we use to
# access and provision servers
# The SSH public keys are stored at the cloud provider
# under this name/these names
# (comma separated list)
variable "ssh_key_names" {
  default = "o12stack-torsten,o12stack-nikolaus"
}