variable "count" {}

variable "username" {
  type = "string"
}

variable "password" {
  type = "string"
}


variable "port" {
  type = "string"
}

variable "ips" {
  type = "list"
}


resource "null_resource" "run-harden" {
  count = "${var.count}"
  triggers = {
     template = "${data.template_file.runharden.rendered}"
   }
  
  connection {
    host  = "${element(var.ips, count.index)}"
    user  = "${var.username}"
    password = "${var.password}"
    agent = true
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.runharden.rendered}"]
  }
}

data "template_file" "runharden" {
  template = "${file("${path.module}/scripts/run.sh")}"
  vars {
    pwd ="${var.password}"
  }
}
