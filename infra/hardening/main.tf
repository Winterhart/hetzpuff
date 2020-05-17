/*
* harden - Run the hardening on VM
*/
module "run-harden" {
  source = "./run-harden"
  count = "${var.node_count}"
  username = "${var.username}"
  password = "${var.password}"
  port = "${var.ssh-port}"
  ips = "${var.ips}"
}