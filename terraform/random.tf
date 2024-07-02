# [Random Password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)
resource "random_password" "vm" {
  length           = 32
  special          = true
  override_special = "#&-_+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}
