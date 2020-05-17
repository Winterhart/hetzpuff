terraform {
  required_version = "= 0.11.15"
}

provider "cloudflare" {
  version = "2.2"
}

provider "hcloud" {
  version = "1.15.0"
}

provider "external" {
  version = "1.2.0"
}

provider "template" {
  version = "2.1.2"
}

provider "random" {
  version = "2.2.1"
}

provider "null" {
  version = "2.1.2"
}
