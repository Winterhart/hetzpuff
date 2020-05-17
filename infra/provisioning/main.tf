module "provider" {
  source = "./provider/hcloud"

  token           = "${var.hcloud_token}"
  ssh_keys        = "${var.hcloud_ssh_keys}"
  location        = "${var.hcloud_location}"
  type            = "${var.hcloud_type}"
  image           = "${var.hcloud_image}"
  hosts           = "${var.node_count}"
  hostname_format = "${var.hostname_format}"
}

module "swap" {
  source = "./service/swap"

  count       = "${var.node_count}"
  connections = "${module.provider.public_ips}"
}

module "dns" {
  source = "./dns/cloudflare"

  count      = "${var.node_count}"
  email      = "${var.cloudflare_email}"
  token      = "${var.cloudflare_token}"
  zone_id     = "${var.cloudflare_zone_id}"
  domain     = "${var.domain}"
  public_ips = "${module.provider.public_ips}"
  hostnames  = "${module.provider.hostnames}"
}

module "etcd" {
  source = "./service/etcd"

  count       = "${var.etcd_node_count}"
  connections = "${module.provider.public_ips}"
  hostnames   = "${module.provider.hostnames}"
  vpn_unit    = "${module.wireguard.vpn_unit}"
  vpn_ips     = "${module.wireguard.vpn_ips}"
  version_etc = "${var.etcd_version}"
}

module "kubernetes" {
  source = "./service/kubernetes"

  count          = "${var.node_count}"
  connections    = "${module.provider.public_ips}"
  cluster_name   = "${var.domain}"
  vpn_interface  = "${module.wireguard.vpn_interface}"
  vpn_ips        = "${module.wireguard.vpn_ips}"
  etcd_endpoints = "${module.etcd.endpoints}"
}

module "wireguard" {
  source = "./security/wireguard"

  count        = "${var.node_count}"
  connections  = "${module.provider.public_ips}"
  private_ips  = "${module.provider.private_ips}"
  hostnames    = "${module.provider.hostnames}"
  overlay_cidr = "${module.kubernetes.overlay_cidr}"
}

module "firewall" {
  source = "./security/ufw"

  count                = "${var.node_count}"
  connections          = "${module.provider.public_ips}"
  private_interface    = "${module.provider.private_network_interface}"
  vpn_interface        = "${module.wireguard.vpn_interface}"
  vpn_port             = "${module.wireguard.vpn_port}"
  kubernetes_interface = "${module.kubernetes.overlay_interface}"
    ssh_port = "${var.ssh-port}"
}



/*
* A script that will create a user & store IPs address
*/
module "user" {
  source = "./utils/user"
  count = "${var.node_count}"
  connections = "${module.provider.public_ips}"
  username = "${var.username}"
  password = "${var.password}"
  //Prevent this to run before Kubernetes is completed
  explicit_dependency_kube = "${module.kubernetes.overlay_interface}"
  explicit_dependency_wireguard = "${module.wireguard.overlay_cidr}"
}

/*
* harden - A script that do a first wave of hardening on clusters
*/
module "harden" {
  source = "./security/harden"
  count = "${var.node_count}"
  connections = "${module.provider.public_ips}"
  username = "${var.username}"
  port = "${var.ssh-port}"
  // Prevent this to run before user creation
  explicit_dependency_user = "${module.user.status}"
}