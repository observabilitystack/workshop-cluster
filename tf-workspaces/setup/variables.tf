
# Feed from secrets.auto.tfvars
variable "hcloud_token" {}
variable "do_token" {}

variable "domain" {
  type = string
  default = "workshop.o11ystack.org"
}
