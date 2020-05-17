variable "count" {}

variable "connections" {
  type = "list"
}

variable "username" {
  type = "string"
}

variable "port" {
  type = "string"
}

variable "explicit_dependency_user" {
  type = "string"
}




resource "null_resource" "harden" {
  count = "${var.count}"

  triggers = {
    template = "${data.template_file.harden.rendered}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "local-exec" {
   command = <<EOT
    echo ${var.explicit_dependency_user}
    cp "${path.module}/resources/ubuntu-example.cfg" "${path.module}/resources/ubuntu.cfg"
    sed -i "s/^\(\SSH_GRPS\s*=\s*\).*\$/\1'$USERNAME'/" "${path.module}/resources/ubuntu.cfg" 
    sed -i "s/^\(\SSH_PORT\s*=\s*\).*\$/\1'$PORT'/" "${path.module}/resources/ubuntu.cfg" 
    sed -i "s/^\(\VERBOSE\s*=\s*\).*\$/\1'Y'/" "${path.module}/resources/ubuntu.cfg" 
    sed -i "s/^\(\CHANGEME\s*=\s*\).*\$/\1'ready'/" "${path.module}/resources/ubuntu.cfg"
   EOT
   
   environment = {
     USERNAME="${var.username}"
     PORT="${var.port}"
   }
  }

  provisioner "file" {
    source = "${path.module}/resources"
    destination = "/"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.harden.rendered}"]
  }
}

data "template_file" "harden" {
  template = "${file("${path.module}/scripts/basic-harden.sh")}"
}
