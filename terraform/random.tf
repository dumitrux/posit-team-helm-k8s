
# [Random String](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)
resource "random_string" "kv_name" {
  length  = 4
  upper   = false
  special = false
}

resource "random_string" "psql_name" {
  length  = 4
  upper   = false
  special = false
}

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

resource "random_password" "psql" {
  length           = 32
  special          = true
  override_special = "#&-_+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}
