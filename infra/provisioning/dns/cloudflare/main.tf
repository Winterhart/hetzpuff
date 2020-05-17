variable "count" {}

variable "email" {}

variable "token" {}

variable "domain" {}

variable "zone_id" {}

variable "hostnames" {
  type = "list"
}

variable "public_ips" {
  type = "list"
}

provider "cloudflare" {
  email   = "${var.email}"
  api_key = "${var.token}"
}

resource "cloudflare_record" "hosts" {
  count = "${var.count}"

  # domain  = "${var.domain}"
  zone_id = "${var.zone_id}"
  name    = "${element(var.hostnames, count.index)}"
  value   = "${element(var.public_ips, count.index)}"
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "domain" {
  # domain  = "${var.domain}"
  name    = "${var.domain}"
  zone_id = "${var.zone_id}"
  value   = "${element(var.public_ips, 0)}"
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "wildcard" {
  depends_on = ["cloudflare_record.domain"]

  # domain  = "${var.domain}"
  name    = "*"
  value   = "${var.domain}"
  type    = "CNAME"
  proxied = false
  zone_id = "${var.zone_id}"
}

output "domains" {
  value = ["${cloudflare_record.hosts.*.hostname}"]
}
