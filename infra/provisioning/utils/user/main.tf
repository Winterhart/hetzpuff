variable "count" {}

variable "connections" {
  type = "list"
}

variable "explicit_dependency_kube" {
  type = "string"
}

variable "explicit_dependency_wireguard" {
  type = "string"
}


variable "username" {
  type = "string"
}

variable "password" {
  type = "string"
}

variable "status" {
  default = "initialized"
}


resource "null_resource" "user" {
  count = "${var.count}"
  triggers = {
    template = "${data.template_file.user.rendered}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.user.rendered}"]
  }

  provisioner"local-exec" {
    command = <<EOT
    export ip_add="${element(var.connections, count.index)}"
    echo "{\"ip\":\"$ip_add\"}" >> "${path.module}/resources/IP.json"
    EOT
}
}

data "template_file" "user" {
  template = "${file("${path.module}/scripts/create-user.sh")}"
  vars {
    username = "${var.username}"
    password  = "${var.password}"
    status = "${var.status}"
  }
}




output "status" {
  value = "finished"
}
