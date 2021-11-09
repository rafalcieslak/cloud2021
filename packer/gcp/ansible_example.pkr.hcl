variable "project_id" {
  type    = string
  default = "robust-shadow-329317"
}

locals {
  timestamp           = regex_replace(timestamp(), "[- TZ:]", "")
  source_image_family = "debian-11"
}

source "googlecompute" "demo" {
  disk_size           = 10
  image_description   = "Demo instance"
  image_family        = "demo-image"
  image_name          = "demo-image-${local.timestamp}"
  machine_type        = "f1-micro"
  project_id          = var.project_id
  source_image_family = local.source_image_family
  ssh_username        = "packer"
  region              = "europe-west1"
  zone                = "europe-west1-b"
}

build {
  sources = ["source.googlecompute.demo"]

  provisioner "ansible" {
    user          = "packer"
    playbook_file = "../../ansible/nginx4.yml"
  }

  provisioner "shell" {
    inline = ["sudo rm /home/packer/.ssh/authorized_keys"]
  }

}
